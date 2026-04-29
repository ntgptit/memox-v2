import 'package:flutter_test/flutter_test.dart';

import '../robots/memox_robot.dart';
import '../test_app.dart';

void appShellTests() {
  testWidgets('DT1 onOpen: boots MemoX app shell with integration binding', (
    tester,
  ) async {
    await pumpTestApp(tester);

    await MemoxRobot(tester).expectAppShellVisible();

    expect(tester.takeException(), isNull);
  });

  testWidgets('DT2 onOpen: boots MemoX app shell on compact surface size', (
    tester,
  ) async {
    await pumpTestApp(tester, surfaceSize: integrationTestCompactSurfaceSize);

    await MemoxRobot(tester).expectAppShellVisible();

    expect(tester.takeException(), isNull);
  });

  testWidgets('DT8 onOpen: renders router error for unknown initial route', (
    tester,
  ) async {
    await pumpTestApp(tester, initialLocation: '/unknown-route');

    await MemoxRobot(tester).expectErrorState(
      title: 'Navigation error',
      message: 'Something went wrong.',
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('DT2 onNavigate: switches between top-level shell destinations', (
    tester,
  ) async {
    await pumpTestApp(tester, surfaceSize: integrationTestCompactSurfaceSize);

    final robot = MemoxRobot(tester);
    await robot.waitUntilVisible(find.text('No folders yet'));
    await robot.tapVisible(find.text('Home'));
    await robot.waitUntilVisible(find.text("Today's study focus"));
    await robot.tapVisible(find.text('Progress'));
    await robot.waitUntilVisible(find.text('No active study sessions'));
    await robot.tapVisible(find.text('Settings'));
    await robot.waitUntilVisible(find.text('Appearance'));
    await robot.tapVisible(find.text('Library'));
    await robot.waitUntilVisible(find.text('No folders yet'));

    expect(tester.takeException(), isNull);
  });
}
