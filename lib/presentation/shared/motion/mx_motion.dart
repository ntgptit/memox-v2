import '../../../core/theme/tokens/app_motion.dart';

/// Presentation-safe duration aliases for feature and shared UI motion.
abstract final class MxDurations {
  static const stateChange = AppDurations.stateChange;
  static const quickTransition = AppDurations.quickTransition;
  static const fade = AppDurations.fade;
  static const pageTurn = AppDurations.pageTurn;
  static const slide = AppDurations.slide;
  static const feedbackHold = AppDurations.feedbackHold;
  static const feedbackPause = AppDurations.feedbackPause;
  static const successHold = AppDurations.successHold;
  static const skeletonPulse = AppDurations.skeletonPulse;
  static const snackbar = AppDurations.snackbar;
  static const reviewAutoSubmit = AppDurations.reviewAutoSubmit;
  static const recallAnswerTimeout = AppDurations.recallAnswerTimeout;
  static const matchTimerTick = AppDurations.matchTimerTick;
  static const guessCorrectAdvanceDelay = AppDurations.guessCorrectAdvanceDelay;
  static const guessWrongFeedbackDelay = AppDurations.guessWrongFeedbackDelay;
}
