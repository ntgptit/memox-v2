import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'cases/deck_flow_test.dart';
import 'cases/flashcard_flow_test.dart';
import 'cases/folder_flow_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('DT1 onOpen: initializes robot integration harness', (_) async {
    expect(binding, isA<IntegrationTestWidgetsFlutterBinding>());
  });

  registerFolderFlowTests();
  registerDeckFlowTests();
  registerFlashcardFlowTests();
}
