// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

class TtsSettingsRecords extends Table {
  @override
  String get tableName => 'tts_settings';

  TextColumn get id => text()();

  BoolColumn get autoPlay => boolean().named('auto_play')();

  TextColumn get frontLanguage => text().named('front_language')();

  RealColumn get rate => real().check(rate.isBetweenValues(0.3, 0.7))();

  RealColumn get pitch => real().check(pitch.isBetweenValues(0.7, 1.5))();

  RealColumn get volume => real().check(volume.isBetweenValues(0.0, 1.0))();

  TextColumn get frontVoiceName =>
      text().named('front_voice_name').nullable()();

  @override
  Set<Column> get primaryKey => <Column>{id};
}
