import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoxRobot {
  const MemoxRobot(this.tester);

  final WidgetTester tester;

  Future<void> expectAppShellVisible() async {
    await waitUntilVisible(find.byType(MaterialApp));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Navigator), findsWidgets);
  }

  Future<void> expectErrorState({
    required String title,
    required String message,
  }) async {
    await waitUntilVisible(find.text(title));
    await waitUntilVisible(find.text(message));
  }

  Future<void> waitUntilVisible(Finder finder, {int maxPumps = 40}) async {
    for (var attempt = 0; attempt < maxPumps; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    fail('Timed out waiting for $finder');
  }

  Future<void> waitUntilAbsent(Finder finder, {int maxPumps = 40}) async {
    for (var attempt = 0; attempt < maxPumps; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isEmpty) {
        return;
      }
    }
    fail('Timed out waiting for $finder to disappear');
  }

  Future<void> tapVisible(Finder finder) async {
    await waitUntilVisible(finder);
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> longPressVisible(Finder finder) async {
    await waitUntilVisible(finder);
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.longPress(finder);
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> enterText(Finder finder, String text) async {
    await waitUntilVisible(finder);
    await tester.enterText(finder, text);
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> searchFor(String text) async {
    await enterText(find.byType(TextField).first, text);
  }

  Future<void> clearSearch() async {
    await enterText(find.byType(TextField).first, '');
  }
}
