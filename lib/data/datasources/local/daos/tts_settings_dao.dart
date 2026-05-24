import 'package:drift/drift.dart';

import '../../../../domain/services/tts_service.dart';
import '../app_database.dart';

final class TtsSettingsDao {
  const TtsSettingsDao(this._database);

  static const String settingsId = 'default';

  final AppDatabase _database;

  Future<TtsSettingsRecord?> load() => (_database.select(
    _database.ttsSettingsRecords,
  )..where((table) => table.id.equals(settingsId))).getSingleOrNull();

  Future<void> save(TtsSettings settings) => _database
      .into(_database.ttsSettingsRecords)
      .insertOnConflictUpdate(
        TtsSettingsRecordsCompanion.insert(
          id: settingsId,
          autoPlay: settings.autoPlay,
          frontLanguage: settings.frontLanguage.storageValue,
          rate: TtsSettings.normalizeRate(settings.rate),
          pitch: TtsSettings.normalizePitch(settings.pitch),
          volume: TtsSettings.normalizeVolume(settings.volume),
          frontVoiceName: Value(settings.frontVoiceName),
        ),
      );
}
