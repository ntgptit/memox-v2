import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/settings/study_settings_store.dart';
import '../providers.dart';

part 'study_settings_providers.g.dart';

@Riverpod(keepAlive: true)
Future<StudySettingsStore> studySettingsStore(Ref ref) async =>
    StudySettingsStore(await ref.watch(sharedPreferencesProvider.future));
