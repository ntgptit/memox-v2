import 'package:integration_test/integration_test.dart';

import 'cases/app_shell_case.dart';
import 'cases/coverage_expansion_case.dart';
import 'cases/deck_flow_case.dart';
import 'cases/flashcard_flow_case.dart';
import 'cases/folder_flow_case.dart';
import 'cases/study_flow_case.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  appShellTests();
  folderFlowTests();
  deckFlowTests();
  flashcardFlowTests();
  studyFlowTests();
  coverageExpansionTests();
}
