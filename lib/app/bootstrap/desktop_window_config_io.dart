import 'dart:io';

import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

const bool _isRobotTest = bool.fromEnvironment('ROBOT_TEST');
const Size _robotTestWindowSize = Size(393, 852);
const Size _defaultDesktopWindowSize = Size(1280, 720);
const Size _defaultMinimumWindowSize = Size(800, 600);

var _isDesktopWindowConfigured = false;

Future<void> configureDesktopWindowForTest() async {
  if (_isDesktopWindowConfigured) {
    return;
  }
  if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
    return;
  }

  _isDesktopWindowConfigured = true;

  await windowManager.ensureInitialized();

  final size = _isRobotTest
      ? await _resolveRobotWindowSize()
      : _defaultDesktopWindowSize;
  final options = WindowOptions(
    size: size,
    minimumSize: _isRobotTest ? size : _defaultMinimumWindowSize,
    maximumSize: _isRobotTest ? size : null,
    center: true,
    title: 'memox',
  );

  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  if (_isRobotTest) {
    await windowManager.setSize(size);
    await windowManager.setMinimumSize(size);
    await windowManager.setMaximumSize(size);
    await windowManager.center();
  }
}

Future<Size> _resolveRobotWindowSize() async {
  if (!Platform.isWindows) {
    return _robotTestWindowSize;
  }

  final display = await screenRetriever.getPrimaryDisplay();
  final displayScaleFactor = display.scaleFactor?.toDouble() ?? 1;
  final flutterScaleFactor = windowManager.getDevicePixelRatio();
  if (displayScaleFactor <= flutterScaleFactor) {
    return _robotTestWindowSize;
  }

  return _robotTestWindowSize * (displayScaleFactor / flutterScaleFactor);
}
