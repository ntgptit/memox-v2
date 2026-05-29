import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../../domain/study/entities/empty_scope_reason.dart';
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

      final resumeSessionId = state.resumeCandidate?.session.id;
      if (resumeSessionId != null) {
        context.replaceStudySession(resumeSessionId);
        return;
      }

      final studyType = _defaultStudyType(state.entryType);
      final settings = studyType == StudyType.newStudy
          ? state.newStudyDefaults
          : state.reviewDefaults;
      final selectedModes = _selectedModes(widget.studyMode);
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
            modes: selectedModes,
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
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
      });
    }
  }
}

StudyType _defaultStudyType(StudyEntryType entryType) => switch (entryType) {
  StudyEntryType.today => StudyType.srsReview,
  StudyEntryType.deck || StudyEntryType.folder => StudyType.newStudy,
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
