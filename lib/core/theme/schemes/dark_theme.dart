import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../extensions/theme_extensions.dart';
import '../component_themes/app_bar_theme.dart';
import '../component_themes/button_theme.dart';
import '../component_themes/card_theme.dart';
import '../component_themes/chip_theme.dart';
import '../component_themes/dialog_theme.dart';
import '../component_themes/divider_theme.dart';
import '../component_themes/icon_theme.dart';
import '../component_themes/input_theme.dart';
import '../component_themes/list_tile_theme.dart';
import '../component_themes/navigation_bar_theme.dart';
import '../component_themes/popup_menu_theme.dart';
import '../component_themes/progress_indicator_theme.dart';
import '../component_themes/scrollbar_theme.dart';
import '../component_themes/segmented_button_theme.dart';
import '../component_themes/text_selection_theme.dart';
import '../component_themes/toggle_theme.dart';
import '../component_themes/tooltip_theme.dart';

/// Dark [ColorScheme] derived from the MemoX brand palette.
const ColorScheme _darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: AppColors.primary80,
  onPrimary: AppColors.primary20,
  primaryContainer: AppColors.primary30,
  onPrimaryContainer: AppColors.primary90,
  secondary: AppColors.secondary80,
  onSecondary: AppColors.secondary20,
  secondaryContainer: AppColors.secondary30,
  onSecondaryContainer: AppColors.secondary90,
  tertiary: AppColors.tertiary80,
  onTertiary: AppColors.tertiary20,
  tertiaryContainer: AppColors.tertiary30,
  onTertiaryContainer: AppColors.tertiary90,
  error: AppColors.error80,
  onError: AppColors.error20,
  errorContainer: AppColors.error30,
  onErrorContainer: AppColors.error90,
  surface: AppColors.darkNavy10,
  onSurface: AppColors.neutral95,
  onSurfaceVariant: AppColors.neutral70,
  surfaceContainerLowest: AppColors.darkNavy5,
  surfaceContainerLow: AppColors.darkNavy15,
  surfaceContainer: AppColors.darkNavy20,
  surfaceContainerHigh: AppColors.darkNavy25,
  surfaceContainerHighest: AppColors.darkNavy30,
  surfaceDim: AppColors.darkNavy10,
  surfaceBright: AppColors.darkNavy40,
  inverseSurface: AppColors.neutral90,
  onInverseSurface: AppColors.darkNavy20,
  inversePrimary: AppColors.primary40,
  outline: AppColors.darkNavyOutline,
  outlineVariant: AppColors.darkNavyOutlineVariant,
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  surfaceTint: AppColors.primary80,
);

ThemeData buildDarkTheme() {
  const scheme = _darkScheme;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: AppTypography.fontFamily,
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
    menuButtonTheme: PopupMenuThemeBuilder.menuButton(scheme),
    textSelectionTheme: TextSelectionThemeBuilder.build(scheme),
    extensions: const [MxColorsExtension.dark],
  );
}
