import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../../domain/study/entities/empty_scope_reason.dart';
import '../../../../domain/study/entities/study_models.dart';
import '../../../../domain/study/strategy/study_strategy.dart';
import '../../../shared/dialogs/mx_confirmation_dialog.dart';
import '../../../shared/dialogs/mx_dialog_resume_or_start_over.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/widgets/mx_error_state.dart';
import '../../../shared/widgets/mx_loading_state.dart';
import '../providers/study_entry_notifier.dart';
import '../providers/study_session_notifier.dart';
import '../widgets/empty_scope_screen.dart';

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
      return MxScaffold(
        title: l10n.studyEntryTitle,
        body: MxContentShell(
          width: MxContentWidth.reading,
          child: MxErrorState(
            title: l10n.sharedErrorTitle,
            message: studyErrorMessage(_error),
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
    });

    try {
      final state = await ref.read(
        studyEntryStateProvider(widget.entryType, widget.entryRefId).future,
      );
      if (!mounted) {
        return;
      }

      final studyType = _defaultStudyType(state.entryType);
      final modes = _selectedModes(widget.studyMode) ?? _defaultModes(studyType);
      final intendedFlow = studyFlowForModes(studyType, modes);
      final settings = _settingsFor(studyType, state);

      // Resume gate (spec: docs/wireframes/12-study-entry-gate.md,
      // docs/business/resume/resume-session.md): only offer resume when a
      // resumable session matches BOTH this scope AND the requested mode flow.
      // A different mode flow falls through to a fresh start.
      final candidate = state.resumeCandidate;
      if (candidate != null &&
          candidate.session.studyFlow == intendedFlow) {
        await _resolveResume(
          candidate: candidate,
          studyType: studyType,
          modes: modes,
          settings: settings,
        );
        return;
      }

      await _startNew(studyType: studyType, modes: modes, settings: settings);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
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

    final error = result?.error;
    if (error != null) {
      setState(() {
        _error = error;
      });
      return;
    }

    final sessionId = result?.sessionId;
    if (sessionId == null) {
      setState(() {
        _error = StateError('Study session was not started.');
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
