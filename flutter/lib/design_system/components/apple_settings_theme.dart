import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import '../apple_theme.dart';
import '../apple_typography.dart';

/// Apple-styled Settings Theme for settings_ui package
/// 
/// This provides Apple design language styling for the settings_ui package
/// used in mobile settings pages.
class AppleSettingsTheme {
  AppleSettingsTheme._();

  /// Get the Apple-styled settings theme for light mode
  static SettingsThemeData lightTheme(BuildContext context) {
    return SettingsThemeData(
      settingsListBackground: AppleTheme.lightBackground,
      settingsSectionBackground: AppleTheme.lightSurface,
      dividerColor: AppleTheme.lightSeparator,
      tileHighlightColor: AppleTheme.lightBackground,
      leadingIconsColor: AppleTheme.primaryBlue,
      titleTextColor: AppleTheme.lightText,
      settingsTileTextColor: AppleTheme.lightText,
      tileDescriptionTextColor: AppleTheme.lightSecondaryText,
      inactiveTitleColor: AppleTheme.lightSecondaryText,
      inactiveSubtitleColor: AppleTheme.lightTertiaryText,
    );
  }

  /// Get the Apple-styled settings theme for dark mode
  static SettingsThemeData darkTheme(BuildContext context) {
    return SettingsThemeData(
      settingsListBackground: AppleTheme.darkBackground,
      settingsSectionBackground: AppleTheme.darkSurface,
      dividerColor: AppleTheme.darkSeparator,
      tileHighlightColor: AppleTheme.darkSecondary,
      leadingIconsColor: AppleTheme.primaryBlue,
      titleTextColor: AppleTheme.darkText,
      settingsTileTextColor: AppleTheme.darkText,
      tileDescriptionTextColor: AppleTheme.darkSecondaryText,
      inactiveTitleColor: AppleTheme.darkSecondaryText,
      inactiveSubtitleColor: AppleTheme.darkTertiaryText,
    );
  }

  /// Get the appropriate theme based on brightness
  static SettingsThemeData getTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkTheme(context) : lightTheme(context);
  }

  /// Get the Apple-styled section decoration
  static BoxDecoration sectionDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BoxDecoration(
      color: isDark ? AppleTheme.darkSurface : AppleTheme.lightSurface,
      borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
      boxShadow: isDark ? AppleTheme.shadowDark : AppleTheme.shadowLight,
    );
  }

  /// Get the Apple-styled title text style
  static TextStyle titleStyle(BuildContext context) {
    return AppleTypography.body(context);
  }

  /// Get the Apple-styled subtitle text style
  static TextStyle subtitleStyle(BuildContext context) {
    return AppleTypography.footnote(context);
  }

  /// Get the Apple-styled section title text style
  static TextStyle sectionTitleStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText,
      letterSpacing: 0.5,
    );
  }
}

/// Apple-styled Settings List wrapper
/// 
/// A wrapper around SettingsList that applies Apple styling.
class AppleSettingsList extends StatelessWidget {
  final List<AbstractSettingsSection> sections;
  final ScrollController? scrollController;
  final EdgeInsets? contentPadding;
  final bool shrinkWrap;

  const AppleSettingsList({
    Key? key,
    required this.sections,
    this.scrollController,
    this.contentPadding,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SettingsList(
      sections: sections,
      shrinkWrap: shrinkWrap,
      contentPadding: contentPadding ?? EdgeInsets.all(AppleTheme.spacing16),
      lightTheme: AppleSettingsTheme.lightTheme(context),
      darkTheme: AppleSettingsTheme.darkTheme(context),
      platform: DevicePlatform.iOS, // Use iOS styling for Apple look
    );
  }
}

/// Apple-styled Settings Section wrapper for settings_ui package
class AppleSettingsUiSection extends AbstractSettingsSection {
  final String? title;
  final List<AbstractSettingsTile> tiles;
  final EdgeInsetsDirectional? margin;

  const AppleSettingsUiSection({
    this.title,
    required this.tiles,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: title != null 
          ? Text(
              title!,
              style: AppleSettingsTheme.sectionTitleStyle(context),
            )
          : null,
      tiles: tiles,
      margin: margin ?? EdgeInsetsDirectional.only(
        top: AppleTheme.spacing16,
        start: AppleTheme.spacing16,
        end: AppleTheme.spacing16,
      ),
    );
  }
}
