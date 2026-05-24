enum TtsState { idle, speaking, paused, error }

enum TtsLanguage {
  korean('ko-KR'),
  english('en-US');

  const TtsLanguage(this.localeTag);

  final String localeTag;

  static TtsLanguage fromStorage(
    String? value, {
    TtsLanguage fallback = TtsLanguage.korean,
  }) => switch (value) {
    'english' => TtsLanguage.english,
    'korean' => TtsLanguage.korean,
    _ => fallback,
  };

  String get storageValue => name;
}

enum TtsTextSide { front, back, note }

final class TtsVoice {
  const TtsVoice({required this.name, required this.language, this.gender});

  final String name;
  final TtsLanguage language;
  final String? gender;
}

final class TtsSettings {
  const TtsSettings({
    required this.autoPlay,
    required this.frontLanguage,
    required this.rate,
    required this.pitch,
    required this.volume,
    this.frontVoiceName,
  });

  static const double minRate = 0.3;
  static const double maxRate = 0.7;
  static const double defaultRate = 0.5;
  static const double minPitch = 0.7;
  static const double maxPitch = 1.5;
  static const double defaultPitch = 1.0;
  static const double minVolume = 0.0;
  static const double maxVolume = 1.0;
  static const double defaultVolume = 1.0;

  static const TtsSettings defaults = TtsSettings(
    autoPlay: false,
    frontLanguage: TtsLanguage.korean,
    rate: defaultRate,
    pitch: defaultPitch,
    volume: defaultVolume,
  );

  final bool autoPlay;
  final TtsLanguage frontLanguage;
  final double rate;
  final double pitch;
  final double volume;
  final String? frontVoiceName;

  TtsLanguage languageFor(TtsTextSide side) => frontLanguage;

  String? voiceNameFor(TtsTextSide side) => frontVoiceName;

  TtsSettings copyWith({
    bool? autoPlay,
    TtsLanguage? frontLanguage,
    double? rate,
    double? pitch,
    double? volume,
    String? frontVoiceName,
    bool clearFrontVoice = false,
  }) => TtsSettings(
    autoPlay: autoPlay ?? this.autoPlay,
    frontLanguage: frontLanguage ?? this.frontLanguage,
    rate: normalizeRate(rate ?? this.rate),
    pitch: normalizePitch(pitch ?? this.pitch),
    volume: normalizeVolume(volume ?? this.volume),
    frontVoiceName: clearFrontVoice
        ? null
        : frontVoiceName ?? this.frontVoiceName,
  );

  static double normalizeRate(double value) =>
      value.clamp(minRate, maxRate).toDouble();

  static double normalizePitch(double value) =>
      value.clamp(minPitch, maxPitch).toDouble();

  static double normalizeVolume(double value) =>
      value.clamp(minVolume, maxVolume).toDouble();
}

abstract interface class TtsService {
  Stream<TtsState> get state;

  Future<List<TtsVoice>> availableVoices(TtsLanguage language);

  Future<void> speak(
    String text, {
    required TtsLanguage language,
    required double rate,
    required double pitch,
    required double volume,
    String? voiceName,
  });

  Future<void> stop();

  Future<void> dispose();
}
