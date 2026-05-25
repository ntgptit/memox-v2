import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';

import '../screens/account_settings_screen.dart';
import '../screens/audio_speech_settings_screen.dart';
import '../screens/learning_settings_screen.dart';
import '../screens/settings_screen.dart';

List<RouteBase> settingsBranchRoutes() => [
  GoRoute(
    path: RoutePaths.settings,
    name: RouteNames.settings,
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: SettingsScreen()),
    routes: [
      GoRoute(
        path: RoutePaths.settingsAccountSegment,
        name: RouteNames.settingsAccount,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: AccountSettingsScreen()),
      ),
      GoRoute(
        path: RoutePaths.settingsLearningSegment,
        name: RouteNames.settingsLearning,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LearningSettingsScreen()),
      ),
      GoRoute(
        path: RoutePaths.settingsAudioSpeechSegment,
        name: RouteNames.settingsAudioSpeech,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: AudioSpeechSettingsScreen()),
      ),
    ],
  ),
];
