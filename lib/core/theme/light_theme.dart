import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'theme_extensions.dart';
import 'component_themes/app_bar_theme.dart';
import 'component_themes/button_theme.dart';
import 'component_themes/card_theme.dart';
import 'component_themes/chip_theme.dart';
import 'component_themes/dialog_theme.dart';
import 'component_themes/divider_theme.dart';
import 'component_themes/icon_theme.dart';
import 'component_themes/input_theme.dart';
import 'component_themes/list_tile_theme.dart';
import 'component_themes/navigation_bar_theme.dart';
import 'component_themes/popup_menu_theme.dart';
import 'component_themes/progress_indicator_theme.dart';
import 'component_themes/scrollbar_theme.dart';
import 'component_themes/segmented_button_theme.dart';
import 'component_themes/text_selection_theme.dart';
import 'component_themes/toggle_theme.dart';
import 'component_themes/tooltip_theme.dart';

/// Light [ColorScheme] derived from the MemoX brand palette.
const ColorScheme _lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.lightPrimary40,
  onPrimary: AppColors.lightPrimary100,
  primaryContainer: AppColors.lightPrimary90,
  onPrimaryContainer: AppColors.lightPrimary10,
  secondary: AppColors.lightSecondary50,
  onSecondary: AppColors.lightNeutral10,
  secondaryContainer: AppColors.lightSecondary95,
  onSecondaryContainer: AppColors.lightSecondary20,
  tertiary: AppColors.lightTertiary40,
  onTertiary: AppColors.lightNeutral10,
  tertiaryContainer: AppColors.lightTertiary90,
  onTertiaryContainer: AppColors.lightTertiary20,
  error: AppColors.lightError50,
  onError: AppColors.lightPrimary100,
  errorContainer: AppColors.lightError95,
  onErrorContainer: AppColors.lightError20,
  surface: AppColors.lightSurface,
  onSurface: AppColors.lightNeutral10,
  onSurfaceVariant: AppColors.lightNeutral40,
  surfaceContainerLowest: AppColors.lightSurfaceContainerLowest,
  surfaceContainerLow: AppColors.lightSurfaceContainerLow,
  surfaceContainer: AppColors.lightSurfaceContainer,
  surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
  surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,
  surfaceDim: AppColors.lightSurfaceDim,
  surfaceBright: AppColors.lightSurfaceBright,
  inverseSurface: AppColors.lightNeutral20,
  onInverseSurface: AppColors.lightSurfaceContainerLow,
  inversePrimary: AppColors.lightPrimary70,
  outline: AppColors.lightNeutralVariant60,
  outlineVariant: AppColors.lightNeutralVariant90,
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  surfaceTint: AppColors.lightPrimary40,
);

ThemeData buildLightTheme() {
  const scheme = _lightScheme;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    canvasColor: scheme.surface,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    textTheme: AppTypography.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ),
    primaryTextTheme: AppTypography.textTheme.apply(
      bodyColor: scheme.onPrimary,
      displayColor: scheme.onPrimary,
    ),
    iconTheme: IconThemeBuilder.primary(scheme),
    primaryIconTheme: IconThemeBuilder.onPrimary(scheme),
    dividerTheme: DividerThemeBuilder.build(scheme),
    appBarTheme: AppBarThemeBuilder.build(scheme),
    cardTheme: CardThemeBuilder.build(scheme),
    chipTheme: ChipThemeBuilder.build(scheme),
    dialogTheme: DialogThemeBuilder.dialog(scheme),
    bottomSheetTheme: DialogThemeBuilder.bottomSheet(scheme),
    snackBarTheme: DialogThemeBuilder.snackbar(scheme),
    inputDecorationTheme: InputThemeBuilder.build(scheme),
    elevatedButtonTheme: ButtonThemeBuilder.filled(scheme),
    filledButtonTheme: ButtonThemeBuilder.tonal(scheme),
    outlinedButtonTheme: ButtonThemeBuilder.outlined(scheme),
    textButtonTheme: ButtonThemeBuilder.text(scheme),
    iconButtonTheme: ButtonThemeBuilder.icon(scheme),
    floatingActionButtonTheme: ButtonThemeBuilder.fab(scheme),
    navigationBarTheme: NavigationBarThemeBuilder.bar(scheme),
    navigationRailTheme: NavigationBarThemeBuilder.rail(scheme),
    progressIndicatorTheme: ProgressIndicatorThemeBuilder.build(scheme),
    segmentedButtonTheme: SegmentedButtonThemeBuilder.build(scheme),
    listTileTheme: ListTileThemeBuilder.build(scheme),
    tooltipTheme: TooltipThemeBuilder.build(scheme),
    scrollbarTheme: ScrollbarThemeBuilder.build(scheme),
    switchTheme: ToggleThemeBuilder.switchTheme(scheme),
    checkboxTheme: ToggleThemeBuilder.checkbox(scheme),
    radioTheme: ToggleThemeBuilder.radio(scheme),
    sliderTheme: ToggleThemeBuilder.slider(scheme),
    popupMenuTheme: PopupMenuThemeBuilder.build(scheme),
    menuTheme: PopupMenuThemeBuilder.menu(scheme),
    textSelectionTheme: TextSelectionThemeBuilder.build(scheme),
    extensions: const [MxColorsExtension.light],
  );
}
