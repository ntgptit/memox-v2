import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/settings/study_settings_store.dart';
import '../providers.dart';

part 'study_settings_providers.g.dart';

@riverpod
Future<StudySettingsStore> studySettingsStore(Ref ref) async {
  return StudySettingsStore(await ref.watch(sharedPreferencesProvider.future));
}
