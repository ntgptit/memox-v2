import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/tts_settings_dao.dart';
import 'package:memox/data/repositories/tts_settings_repository_impl.dart';
import 'package:memox/domain/services/tts_service.dart';

void main() {
  late AppDatabase database;
  late TtsSettingsRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
    repository = TtsSettingsRepositoryImpl(TtsSettingsDao(database));
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'DT1 load: returns front-only defaults when no row is persisted',
    () async {
      final settings = await repository.load();

      expect(settings.autoPlay, isFalse);
      expect(settings.frontLanguage, TtsLanguage.korean);
      expect(settings.rate, TtsSettings.defaultRate);
      expect(settings.pitch, TtsSettings.defaultPitch);
      expect(settings.volume, TtsSettings.defaultVolume);
      expect(settings.frontVoiceName, isNull);
    },
  );

  test('DT2 load: falls back and trims persisted row values', () async {
    await database
        .into(database.ttsSettingsRecords)
        .insert(
          TtsSettingsRecordsCompanion.insert(
            id: TtsSettingsDao.settingsId,
            autoPlay: true,
            frontLanguage: 'vietnamese',
            rate: 0.6,
            pitch: 1.2,
            volume: 0.8,
            frontVoiceName: const Value('   '),
          ),
        );

    final settings = await repository.load();

    expect(settings.autoPlay, isTrue);
    expect(settings.frontLanguage, TtsLanguage.korean);
    expect(settings.rate, 0.6);
    expect(settings.pitch, 1.2);
    expect(settings.volume, 0.8);
    expect(settings.frontVoiceName, isNull);
  });

  test(
    'DT1 save: writes front-only speech settings to the default row',
    () async {
      await repository.save(
        const TtsSettings(
          autoPlay: true,
          frontLanguage: TtsLanguage.english,
          rate: 0.6,
          pitch: 1.1,
          volume: 0.9,
          frontVoiceName: 'English Voice',
        ),
      );

      final row = await database
          .select(database.ttsSettingsRecords)
          .getSingle();

      expect(row.id, TtsSettingsDao.settingsId);
      expect(row.autoPlay, isTrue);
      expect(row.frontLanguage, TtsLanguage.english.storageValue);
      expect(row.rate, 0.6);
      expect(row.pitch, 1.1);
      expect(row.volume, 0.9);
      expect(row.frontVoiceName, 'English Voice');
    },
  );

  test('DT2 save: upserts the default row and clamps audio controls', () async {
    await repository.save(
      const TtsSettings(
        autoPlay: true,
        frontLanguage: TtsLanguage.english,
        rate: 0.6,
        pitch: 1.1,
        volume: 0.9,
        frontVoiceName: 'old voice',
      ),
    );

    await repository.save(
      const TtsSettings(
        autoPlay: false,
        frontLanguage: TtsLanguage.korean,
        rate: 0.1,
        pitch: 9.0,
        volume: -1.0,
      ),
    );

    final rows = await database.select(database.ttsSettingsRecords).get();

    expect(rows, hasLength(1));
    expect(rows.single.autoPlay, isFalse);
    expect(rows.single.frontLanguage, TtsLanguage.korean.storageValue);
    expect(rows.single.rate, TtsSettings.minRate);
    expect(rows.single.pitch, TtsSettings.maxPitch);
    expect(rows.single.volume, TtsSettings.minVolume);
    expect(rows.single.frontVoiceName, isNull);
  });
}
