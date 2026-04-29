import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'memox_robot.dart';

final class StudyRobot extends MemoxRobot {
  const StudyRobot(super.tester);

  Future<void> expectFlashcardListVisible(String front) async {
    await waitUntilVisible(find.text(front));
    await waitUntilVisible(find.text('Study now'));
  }

  Future<void> openStudyEntryFromFlashcardList() async {
    await tapVisible(find.text('Study now'));
    await waitUntilVisible(find.text('Start a study session'));
    await waitUntilVisible(find.text('Study flow'));
    await waitUntilVisible(find.text('Session settings'));
  }

  Future<void> expectDefaultStudyEntrySettings() async {
    await waitUntilVisible(find.text('New Study'));
    await waitUntilVisible(find.text('SRS Review'));
    await waitUntilVisible(find.text('Batch size: 10'));
    await waitUntilVisible(find.text('Shuffle flashcards'));
    await waitUntilVisible(find.text('Shuffle answers'));
    await waitUntilVisible(find.text('Prioritize overdue cards'));
  }

  Future<void> decreaseAndRestoreBatchSize() async {
    await tapVisible(find.byTooltip('Decrease batch size'));
    await waitUntilVisible(find.text('Batch size: 9'));
    await tapVisible(find.byTooltip('Increase batch size'));
    await waitUntilVisible(find.text('Batch size: 10'));
  }

  Future<void> selectSrsReviewFlow() async {
    await tapVisible(find.text('SRS Review'));
    await waitUntilVisible(find.text('SRS Review'));
  }

  Future<void> toggleSessionSettings() async {
    await tapVisible(find.text('Shuffle flashcards'));
    await tapVisible(find.text('Shuffle answers'));
    await tapVisible(find.text('Prioritize overdue cards'));
    await waitUntilVisible(find.text('Session settings'));
  }

  Future<void> createFlashcard({
    required String front,
    required String back,
  }) async {
    await tapVisible(find.text('Add flashcard'));
    await waitUntilVisible(find.text('New flashcard'));
    await enterText(find.byType(TextField).at(0), front);
    await enterText(find.byType(TextField).at(1), back);
    await tapVisible(find.text('Save flashcard'));
    await waitUntilVisible(find.text(front));
  }

  Future<void> startStudyFromFlashcardList() async {
    await openStudyEntryFromFlashcardList();
    await tapVisible(find.text('Study now').last);
  }

  Future<void> expectStudySessionVisible({
    required String front,
    required String back,
  }) async {
    await waitUntilVisible(find.text('Review'));
    await waitUntilVisible(find.text(front));
    await waitUntilVisible(find.text(back));
  }
}
