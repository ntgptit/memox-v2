import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _visibleButtonLabelKeys = <String>{
  'commonOk',
  'commonCancel',
  'commonCreate',
  'commonEdit',
  'commonDelete',
  'commonSort',
  'commonSave',
  'commonImport',
  'commonExport',
  'commonMove',
  'commonClear',
  'commonSelect',
  'commonSelectAll',
  'commonSaveOrder',
  'commonReorder',
  'dashboardReviewNowAction',
  'dashboardStartNewStudyAction',
  'dashboardContinueSessionAction',
  'dashboardStudyTodayAction',
  'dashboardOpenLibraryAction',
  'foldersClearSearchAction',
  'decksDuplicateAction',
  'decksExportCsvAction',
  'flashcardsOpenListAction',
  'flashcardsAddAction',
  'flashcardsSaveAndAddNext',
  'flashcardsSaveChanges',
  'flashcardsSaveAction',
  'flashcardsKeepProgressAction',
  'flashcardsResetProgressAction',
  'studyStartAction',
  'studyStartNewSessionAction',
  'studyRestartAction',
  'studyResumeAction',
  'studyContinueSessionAction',
  'studyCancelAction',
  'studyFinalizeAction',
  'studySkipAction',
  'studyViewResultAction',
  'studyResultReviewMoreAction',
  'studyResultStudyAgainAction',
  'studyRetryFinalizeAction',
  'studyHelpAction',
  'studyCheckAnswerAction',
  'studyCorrectAction',
  'studyIncorrectAction',
  'studyRememberedAction',
  'studyForgotAction',
  'studyShowAnswerAction',
  'studyShowAnswerCountdownAction',
  'studyNextAction',
  'studyMarkCorrectAction',
  'studyContinueAction',
  'studyCancelConfirmAction',
  'importLoadFile',
  'importPreviewAction',
  'sharedTryAgain',
  'sharedShowDetails',
  'sharedHideDetails',
};

const _nonButtonActionKeys = <String>{'errorUnsupportedAction'};

const _redundantEnglishActionNouns = <String>{
  'card',
  'deck',
  'finalize',
  'flashcard',
  'flashcards',
  'library',
  'progress',
  'result',
  'search',
  'session',
};

void main() {
  test('DT1 inspectL10n: classifies every visible action label key', () {
    final messages = _arbMessages('lib/l10n/app_en.arb');
    final actionKeys = messages.keys
        .where((key) => key.endsWith('Action'))
        .where((key) => !key.startsWith('@'))
        .toSet();

    final unclassified = actionKeys.difference({
      ..._visibleButtonLabelKeys,
      ..._nonButtonActionKeys,
    }).toList()..sort();

    expect(unclassified, isEmpty, reason: unclassified.join('\n'));
  });

  test(
    'DT2 inspectL10n: keeps visible button labels concise in every locale',
    () {
      final localeBudgets = <String, int>{
        'lib/l10n/app_en.arb': 3,
        'lib/l10n/app_vi.arb': 4,
      };
      final violations = <String>[];

      for (final entry in localeBudgets.entries) {
        final messages = _arbMessages(entry.key);
        for (final key in _visibleButtonLabelKeys) {
          final value = messages[key];
          if (value == null) {
            violations.add('${entry.key}: missing $key');
            continue;
          }

          final wordCount = _semanticWordCount(value);
          if (wordCount > entry.value) {
            violations.add('${entry.key}: $key has $wordCount words: "$value"');
          }
        }
      }

      expect(violations, isEmpty, reason: violations.join('\n'));
    },
  );

  test('DT3 inspectL10n: avoids redundant context nouns in action labels', () {
    final messages = _arbMessages('lib/l10n/app_en.arb');
    final violations = <String>[];

    for (final key in _visibleButtonLabelKeys.where(
      (key) => key.endsWith('Action'),
    )) {
      final value = messages[key];
      if (value == null) {
        violations.add('missing $key');
        continue;
      }

      final normalized = _normalizeLabel(value);
      for (final noun in _redundantEnglishActionNouns) {
        if (normalized.endsWith(' $noun')) {
          violations.add('$key repeats "$noun": "$value"');
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}

Map<String, String> _arbMessages(String path) {
  final decoded =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  final messages = <String, String>{};

  for (final entry in decoded.entries) {
    if (entry.key.startsWith('@') || entry.key.startsWith('@@')) {
      continue;
    }
    final value = entry.value;
    if (value is String) {
      messages[entry.key] = value;
    }
  }

  return messages;
}

int _semanticWordCount(String value) {
  return _normalizeLabel(
    value,
  ).split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
}

String _normalizeLabel(String value) {
  return value
      .replaceAll(RegExp(r'\{[^}]+\}'), ' ')
      .replaceAll(RegExp(r'[+&/.,:;!?()\[\]<>|\\-]+'), ' ')
      .trim()
      .toLowerCase();
}
