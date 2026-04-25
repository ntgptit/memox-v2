import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ReviewPageScrollBehavior extends MaterialScrollBehavior {
  const ReviewPageScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
  };
}
