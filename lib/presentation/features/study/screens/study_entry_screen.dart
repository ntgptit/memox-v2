import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/di/providers.dart';
import 'package:memox/app/di/study/study_entry_diagnostic_providers.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../../domain/study/entities/empty_scope_reason.dart';
import '../../../../domain/study/entities/study_models.dart';
import '../../../shared/dialogs/mx_confirmation_dialog.dart';
import '../../../shared/dialogs/mx_dialog_resume_or_start_over.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/widgets/mx_error_state.dart';
import '../../../shared/widgets/mx_loading_state.dart';
import '../providers/study_entry_notifier.dart';
import '../providers/study_session_notifier.dart';
import '../widgets/empty_scope_screen.dart';

const String _directStartFailedLogMessage = 'Study entry direct start failed.';
const String _startResultRejectedLogMessage =
    'Study entry start result was rejected.';
const String _startNoResultNoErrorLogMessage =
    'Study entry start returned no result and no action error.';
const String _startNoResultAfterErrorLogMessage =
    'Study entry start returned no result after action error.';
const String _startNoResultErrorMessage =
    'Study entry action returned null unexpectedly.';
const String _diagnosticsFailedLogMessage = 'Study entry diagnostics failed.';

class StudyEntryScreen extends ConsumerStatefulWidget {
  const StudyEntryScreen({
    required this.entryType,
    required this.entryRefId,
    this.studyMode,
    super.key,
  });

  final String entryType;
  final String? entryRefId;
  final String? studyMode;

  @override
  ConsumerState<StudyEntryScreen> createState() => _StudyEntryScreenState();
}

class _StudyEntryScreenState extends ConsumerState<StudyEntryScreen> {
  Object? _error;
  StackTrace? _errorStackTrace;
  String? _errorDiagnostics;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startDirectly());
  }

  @override
  void didUpdateWidget(covariant StudyEntryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entryType == widget.entryType &&
        oldWidget.entryRefId == widget.entryRefId &&
        oldWidget.studyMode == widget.studyMode) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _startDirectly());
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error is EmptyScopeException) {
      return EmptyScopeScreen(
        failure: error,
        entryType: widget.entryType,
        entryRefId: widget.entryRefId,
      );
    }
    if (_error != null) {
      final l10n = AppLocalizations.of(context);
      final details = _debugDetails(
        ref.watch(appConfigProvider).exposeInternalErrorDetails,
      );
      return MxScaffold(
        title: l10n.studyEntryTitle,
        body: MxContentShell(
          width: MxContentWidth.reading,
          child: MxErrorState(
            title: l10n.sharedErrorTitle,
            message: studyErrorMessage(_error, l10n),
            details: details,
            onRetry: _startDirectly,
          ),
        ),
      );
    }

    return const MxScaffold(body: MxLoadingState());
  }

  Future<void> _startDirectly() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _error = null;
      _errorStackTrace = null;
      _errorDiagnostics = null;
    });

    try {
      final state = await ref.read(
        studyEntryStateProvider(widget.entryType, widget.entryRefId).future,
      );
      if (!mounted) {
        return;
      }

      final studyType = _defaultStudyType(state.entryType);
      final modes =
          _selectedModes(widget.studyMode) ?? _defaultModes(studyType);
      final settings = _settingsFor(studyType, state);

      // Resume gate (spec: docs/wireframes/12-study-entry-gate.md,
      // docs/business/resume/resume-session.md): any resumable session for
      // this scope must be resolved before creating another session.
      final candidate = state.resumeCandidate;
      if (candidate != null) {
        await _resolveResume(
          candidate: candidate,
          studyType: studyType,
          modes: modes,
          settings: settings,
        );
        return;
      }

      await _startNew(studyType: studyType, modes: modes, settings: settings);
    } catch (error, stackTrace) {
      _logFailure(
        message: _directStartFailedLogMessage,
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      final diagnostics = await _loadDiagnostics();
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
        _errorStackTrace = stackTrace;
        _errorDiagnostics = diagnostics;
      });
    }
  }

  /// Shows the Resume / Start-over choice and routes accordingly. Cancelling
  /// (system back, Cancel, or barrier tap) pops safely back to the caller
  /// without creating a session.
  Future<void> _resolveResume({
    required StudySessionSnapshot candidate,
    required StudyType studyType,
    required List<StudyMode> modes,
    required StudySettingsSnapshot settings,
  }) async {
    final l10n = AppLocalizations.of(context);
    final choice = await MxDialogResumeOrStartOver.show(
      context: context,
      title: l10n.studyResumeChoiceTitle,
      message: l10n.studyResumeChoiceMessage,
      resumeLabel: l10n.studyResumeChoiceResumeAction,
      startOverLabel: l10n.studyStartOverAction,
    );
    if (!mounted) {
      return;
    }
    switch (choice) {
      case null:
        _cancelGate();
      case MxResumeChoice.resume:
        context.replaceStudySession(candidate.session.id);
      case MxResumeChoice.startOver:
        await _confirmStartOver(
          candidate: candidate,
          studyType: studyType,
          modes: modes,
          settings: settings,
        );
    }
  }

  /// Second-tier discard confirmation for "Start over". Cancelling returns to
  /// the Resume / Start-over choice (spec §resume-or-start-over).
  Future<void> _confirmStartOver({
    required StudySessionSnapshot candidate,
    required StudyType studyType,
    required List<StudyMode> modes,
    required StudySettingsSnapshot settings,
  }) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await MxConfirmationDialog.show(
      context: context,
      title: l10n.studyStartNewSessionConfirmTitle,
      message: l10n.studyStartNewSessionConfirmMessage,
      confirmLabel: l10n.studyStartOverAction,
      icon: Icons.refresh_rounded,
      tone: MxConfirmationTone.danger,
    );
    if (!mounted) {
      return;
    }
    if (!confirmed) {
      await _resolveResume(
        candidate: candidate,
        studyType: studyType,
        modes: modes,
        settings: settings,
      );
      return;
    }
    await _startNew(
      studyType: studyType,
      modes: modes,
      settings: settings,
      restartedFromSessionId: candidate.session.id,
    );
  }

  /// Creates a session (fresh or restarted) and replaces the gate with it.
  Future<void> _startNew({
    required StudyType studyType,
    required List<StudyMode> modes,
    required StudySettingsSnapshot settings,
    String? restartedFromSessionId,
  }) async {
    final result = await ref
        .read(
          studyEntryActionControllerProvider(
            widget.entryType,
            widget.entryRefId,
          ).notifier,
        )
        .start(
          studyType: studyType,
          settings: settings,
          modes: modes,
          restartedFromSessionId: restartedFromSessionId,
        );
    if (!mounted) {
      return;
    }

    // A rejected start carries the original root error + stack trace. Preserve
    // it verbatim (controller stack trace first, then the action AsyncError
    // stack trace) instead of replacing it with a synthesized error.
    final error = result.error;
    if (error != null) {
      final actionState = ref.read(
        studyEntryActionControllerProvider(widget.entryType, widget.entryRefId),
      );
      final stackTrace =
          result.stackTrace ?? actionState.stackTrace ?? StackTrace.current;
      _logFailure(
        message: _startResultRejectedLogMessage,
        error: error,
        stackTrace: stackTrace,
      );
      final diagnostics = await _loadDiagnostics();
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
        _errorStackTrace = stackTrace;
        _errorDiagnostics = diagnostics;
      });
      return;
    }

    final sessionId = result.sessionId;
    if (sessionId == null) {
      // Impossible lifecycle: start() returned neither a session id nor an
      // error. The keepAlive controller + always-resolving start() contract
      // mean this branch should never be reached during a normal failure; it
      // exists only to surface a genuinely impossible state instead of
      // navigating with a null session id.
      final actionState = ref.read(
        studyEntryActionControllerProvider(widget.entryType, widget.entryRefId),
      );
      final lifecycleError =
          actionState.error ?? StateError(_startNoResultErrorMessage);
      final stackTrace = actionState.stackTrace ?? StackTrace.current;
      final message = actionState.error == null
          ? _startNoResultNoErrorLogMessage
          : _startNoResultAfterErrorLogMessage;
      _logFailure(
        message: message,
        error: lifecycleError,
        stackTrace: stackTrace,
      );
      final diagnostics = await _loadDiagnostics();
      if (!mounted) {
        return;
      }
      setState(() {
        _error = lifecycleError;
        _errorStackTrace = stackTrace;
        _errorDiagnostics = diagnostics;
      });
      return;
    }

    context.replaceStudySession(sessionId);
  }

  /// Leaves the entry gate without creating a session (resume cancelled).
  void _cancelGate() {
    unawaited(context.popRoute(fallback: context.goHome));
  }

  StudySettingsSnapshot _settingsFor(
    StudyType studyType,
    StudyEntryState state,
  ) => studyType == StudyType.newStudy
      ? state.newStudyDefaults
      : state.reviewDefaults;

  void _logFailure({
    required String message,
    required Object error,
    required StackTrace stackTrace,
  }) {
    ref
        .read(appLoggerProvider)
        .error(
          '$message entryType=${widget.entryType} '
          'entryRefId=${widget.entryRefId ?? '<null>'} '
          'studyMode=${widget.studyMode ?? '<default>'}',
          error,
          stackTrace,
        );

    if (!ref.read(appConfigProvider).exposeInternalErrorDetails) {
      return;
    }
    final localDebugPrint = debugPrint;
    localDebugPrint(
      '[StudyEntry] $message\n'
      'entryType=${widget.entryType}\n'
      'entryRefId=${widget.entryRefId ?? '<null>'}\n'
      'studyMode=${widget.studyMode ?? '<default>'}\n'
      'errorType=${error.runtimeType}\n'
      'error=$error\n'
      'stackTrace=$stackTrace',
    );
  }

  Future<String?> _loadDiagnostics() async {
    final config = ref.read(appConfigProvider);
    if (!config.exposeInternalErrorDetails) {
      return null;
    }
    try {
      return await ref
          .read(studyEntryDiagnosticServiceProvider)
          .buildFailureBlock(
            config: config,
            entryType: widget.entryType,
            entryRefId: widget.entryRefId,
            studyMode: widget.studyMode,
          );
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider)
          .error(_diagnosticsFailedLogMessage, error, stackTrace);
      return 'Study Entry diagnostics failed: ${error.runtimeType}: $error';
    }
  }

  String? _debugDetails(bool exposeInternalErrorDetails) {
    if (!exposeInternalErrorDetails) {
      return null;
    }
    final error = _error;
    if (error == null) {
      return null;
    }
    final stackTrace = _errorStackTrace
        ?.toString()
        .split('\n')
        .take(20)
        .join('\n');
    return [
      'errorType=${error.runtimeType}',
      'error=$error',
      'entryType=${widget.entryType}',
      'entryRefId=${widget.entryRefId ?? '<null>'}',
      'studyMode=${widget.studyMode ?? '<default>'}',
      if (stackTrace != null && stackTrace.isNotEmpty)
        'stackTrace:\n$stackTrace',
      if (_errorDiagnostics != null && _errorDiagnostics!.isNotEmpty)
        _errorDiagnostics!,
    ].join('\n');
  }
}

StudyType _defaultStudyType(StudyEntryType entryType) => switch (entryType) {
  StudyEntryType.today => StudyType.srsReview,
  StudyEntryType.deck || StudyEntryType.folder => StudyType.newStudy,
};

/// Default mode flow for an entry when no explicit `?mode=` override is given:
/// SRS review uses Fill only; New Study uses the full five-mode cycle.
List<StudyMode> _defaultModes(StudyType studyType) => switch (studyType) {
  StudyType.srsReview => const <StudyMode>[StudyMode.fill],
  StudyType.newStudy => const <StudyMode>[
    StudyMode.review,
    StudyMode.match,
    StudyMode.guess,
    StudyMode.recall,
    StudyMode.fill,
  ],
};

List<StudyMode>? _selectedModes(String? raw) {
  if (raw == null) {
    return null;
  }
  final mode = StudyMode.values.firstWhere(
    (value) => value.storageValue == raw,
    orElse: () => throw ArgumentError.value(raw, 'studyMode'),
  );
  return <StudyMode>[mode];
}
