import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/bottom_sheets/study_scope_picker_sheet.dart';

/// Dashboard-flavored thin wrapper over the shared
/// [showStudyScopePicker]. Kept for call-site discoverability and so future
/// Dashboard-only decoration (e.g. greeting copy) can attach here without
/// touching Study Result.
Future<void> showDashboardScopePicker(
  BuildContext context,
  WidgetRef ref, {
  int? reviewCount,
}) =>
    showStudyScopePicker(context, ref, reviewCount: reviewCount);
