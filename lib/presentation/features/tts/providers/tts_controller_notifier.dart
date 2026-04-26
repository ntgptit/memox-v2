import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/tts_providers.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../domain/services/tts_service.dart';
import '../../../../domain/study/entities/study_models.dart';
import 'tts_settings_notifier.dart';

part 'tts_controller_notifier.g.dart';

@riverpod
class TtsController extends _$TtsController {
  @override
  TtsState build() {
    final service = ref.watch(ttsServiceProvider);
    final subscription = service.state.listen((nextState) {
      state = nextState;
    });
    ref.onDispose(() {
      unawaited(subscription.cancel());
      unawaited(service.stop());
    });
    return TtsState.idle;
  }

  Future<bool> speakText({
    required String text,
    required TtsLanguage language,
    TtsTextSide? side,
  }) async {
    if (side != null && side != TtsTextSide.front) {
      return false;
    }
    if (StringUtils.isBlank(text)) {
      return false;
    }
    try {
      state = TtsState.speaking;
      final settings = await ref.read(ttsSettingsProvider.future);
      if (!ref.mounted) {
        return false;
      }
      await ref
          .read(speakFlashcardUseCaseProvider)
          .speakText(
            text: text,
            language: language,
            settings: settings,
            voiceName: side == null ? null : settings.voiceNameFor(side),
          );
      return true;
    } catch (error, stackTrace) {
      _markError(error, stackTrace);
      return false;
    }
  }

  Future<bool> speakTextSide({
    required String text,
    required TtsTextSide side,
  }) async {
    if (side != TtsTextSide.front) {
      return false;
    }
    final settings = await ref.read(ttsSettingsProvider.future);
    if (!ref.mounted) {
      return false;
    }
    return speakText(
      text: text,
      language: settings.languageFor(side),
      side: side,
    );
  }

  Future<bool> speakFlashcardSide({
    required StudyFlashcardRef flashcard,
    required TtsTextSide side,
  }) async {
    if (side != TtsTextSide.front) {
      return false;
    }
    try {
      state = TtsState.speaking;
      final settings = await ref.read(ttsSettingsProvider.future);
      if (!ref.mounted) {
        return false;
      }
      await ref
          .read(speakFlashcardUseCaseProvider)
          .speakFlashcardSide(
            flashcard: flashcard,
            side: side,
            settings: settings,
          );
      return true;
    } catch (error, stackTrace) {
      _markError(error, stackTrace);
      return false;
    }
  }

  Future<bool> autoPlayTextSide({
    required String text,
    required TtsTextSide side,
  }) async {
    if (side != TtsTextSide.front) {
      return false;
    }
    final settings = await ref.read(ttsSettingsProvider.future);
    if (!ref.mounted || !settings.autoPlay) {
      return false;
    }
    return speakText(
      text: text,
      language: settings.languageFor(side),
      side: side,
    );
  }

  Future<bool> stop() async {
    try {
      await ref.read(ttsServiceProvider).stop();
      if (!ref.mounted) {
        return false;
      }
      state = TtsState.idle;
      return true;
    } catch (error, stackTrace) {
      _markError(error, stackTrace);
      return false;
    }
  }

  void _markError(Object error, StackTrace stackTrace) {
    if (!ref.mounted) {
      return;
    }
    state = TtsState.error;
  }
}

@riverpod
Future<List<TtsVoice>> ttsVoices(Ref ref, TtsLanguage language) {
  return ref.watch(ttsServiceProvider).availableVoices(language);
}
