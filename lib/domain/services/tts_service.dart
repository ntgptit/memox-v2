enum TtsState { idle, speaking, paused, error }

enum TtsLanguage {
  korean('ko-KR'),
  english('en-US');

  const TtsLanguage(this.localeTag);

  final String localeTag;

  static TtsLanguage fromStorage(
    String? value, {
    TtsLanguage fallback = TtsLanguage.korean,
  }) {
    return switch (value) {
      'english' => TtsLanguage.english,
      'korean' => TtsLanguage.korean,
      _ => fallback,
    };
  }

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
    this.frontVoiceName,
  });

  static const double minRate = 0.3;
  static const double maxRate = 0.7;
  static const double defaultRate = 0.5;

  static const TtsSettings defaults = TtsSettings(
    autoPlay: false,
    frontLanguage: TtsLanguage.korean,
    rate: defaultRate,
  );

  final bool autoPlay;
  final TtsLanguage frontLanguage;
  final double rate;
  final String? frontVoiceName;

  TtsLanguage languageFor(TtsTextSide side) {
    return frontLanguage;
  }

  String? voiceNameFor(TtsTextSide side) {
    return frontVoiceName;
  }

  TtsSettings copyWith({
    bool? autoPlay,
    TtsLanguage? frontLanguage,
    double? rate,
    String? frontVoiceName,
    bool clearFrontVoice = false,
  }) {
    return TtsSettings(
      autoPlay: autoPlay ?? this.autoPlay,
      frontLanguage: frontLanguage ?? this.frontLanguage,
      rate: normalizeRate(rate ?? this.rate),
      frontVoiceName: clearFrontVoice
          ? null
          : frontVoiceName ?? this.frontVoiceName,
    );
  }

  static double normalizeRate(double value) {
    return value.clamp(minRate, maxRate).toDouble();
  }
}

abstract interface class TtsService {
  Stream<TtsState> get state;

  Future<List<TtsVoice>> availableVoices(TtsLanguage language);

  Future<void> speak(
    String text, {
    required TtsLanguage language,
    required double rate,
    String? voiceName,
  });

  Future<void> stop();

  Future<void> dispose();
}
