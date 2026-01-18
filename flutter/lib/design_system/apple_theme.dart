import 'package:flutter/material.dart';

/// Apple 2026 Design System - Theme Configuration
/// 
/// This class provides all the design tokens for the PixPOS Remote app
/// following Apple's Human Interface Guidelines.
class AppleTheme {
  AppleTheme._();

  // ============================================
  // PRIMARY COLORS
  // ============================================
  
  /// Apple Blue - Primary accent color
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color primaryBlue50 = Color(0x80007AFF);
  static const Color primaryBlue20 = Color(0x33007AFF);
  
  // ============================================
  // SYSTEM COLORS
  // ============================================
  
  /// System Green - Success, Connected
  static const Color systemGreen = Color(0xFF34C759);
  
  /// System Yellow - Warning, Connecting
  static const Color systemYellow = Color(0xFFFFCC00);
  
  /// System Orange - Attention
  static const Color systemOrange = Color(0xFFFF9500);
  
  /// System Red - Error, Destructive
  static const Color systemRed = Color(0xFFFF3B30);
  
  /// System Teal
  static const Color systemTeal = Color(0xFF5AC8FA);
  
  /// System Indigo
  static const Color systemIndigo = Color(0xFF5856D6);
  
  /// System Purple
  static const Color systemPurple = Color(0xFFAF52DE);
  
  /// System Pink
  static const Color systemPink = Color(0xFFFF2D55);

  // ============================================
  // LIGHT MODE COLORS
  // ============================================
  
  /// Light mode background - System Gray 6
  static const Color lightBackground = Color(0xFFF2F2F7);
  
  /// Light mode surface - Pure white
  static const Color lightSurface = Color(0xFFFFFFFF);
  
  /// Light mode secondary background
  static const Color lightSecondary = Color(0xFFE5E5EA);
  
  /// Light mode tertiary background
  static const Color lightTertiary = Color(0xFFC7C7CC);
  
  /// Light mode quaternary
  static const Color lightQuaternary = Color(0xFFD1D1D6);
  
  /// Light mode primary text
  static const Color lightText = Color(0xFF000000);
  
  /// Light mode secondary text
  static const Color lightSecondaryText = Color(0xFF8E8E93);
  
  /// Light mode tertiary text
  static const Color lightTertiaryText = Color(0xFFC7C7CC);
  
  /// Light mode separator
  static const Color lightSeparator = Color(0xFFC6C6C8);
  
  /// Light mode opaque separator
  static const Color lightOpaqueSeparator = Color(0xFFE5E5EA);

  // ============================================
  // DARK MODE COLORS
  // ============================================
  
  /// Dark mode background - True black for OLED
  static const Color darkBackground = Color(0xFF000000);
  
  /// Dark mode elevated surface
  static const Color darkSurface = Color(0xFF1C1C1E);
  
  /// Dark mode secondary background
  static const Color darkSecondary = Color(0xFF2C2C2E);
  
  /// Dark mode tertiary background
  static const Color darkTertiary = Color(0xFF38383A);
  
  /// Dark mode quaternary
  static const Color darkQuaternary = Color(0xFF48484A);
  
  /// Dark mode primary text
  static const Color darkText = Color(0xFFFFFFFF);
  
  /// Dark mode secondary text
  static const Color darkSecondaryText = Color(0xFF8E8E93);
  
  /// Dark mode tertiary text
  static const Color darkTertiaryText = Color(0xFF48484A);
  
  /// Dark mode separator
  static const Color darkSeparator = Color(0xFF38383A);
  
  /// Dark mode opaque separator
  static const Color darkOpaqueSeparator = Color(0xFF38383A);

  // ============================================
  // SPACING SCALE (8px base unit)
  // ============================================
  
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing14 = 14.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing28 = 28.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing56 = 56.0;
  static const double spacing64 = 64.0;

  // ============================================
  // BORDER RADIUS
  // ============================================
  
  /// Extra small radius - 4px
  static const double radiusXSmall = 4.0;
  
  /// Small radius - 8px
  static const double radiusSmall = 8.0;
  
  /// Medium radius - 12px (buttons, cards)
  static const double radiusMedium = 12.0;
  
  /// Large radius - 16px
  static const double radiusLarge = 16.0;
  
  /// Extra large radius - 20px (dialogs)
  static const double radiusXLarge = 20.0;
  
  /// XXL radius - 24px
  static const double radiusXXLarge = 24.0;
  
  /// Full round - 100px (pills, circular)
  static const double radiusRound = 100.0;

  // ============================================
  // SHADOWS
  // ============================================
  
  /// Light mode subtle shadow
  static List<BoxShadow> get shadowLight => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  
  /// Light mode elevated shadow
  static List<BoxShadow> get shadowLightElevated => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];
  
  /// Dark mode shadow
  static List<BoxShadow> get shadowDark => [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  /// Dark mode elevated shadow
  static List<BoxShadow> get shadowDarkElevated => [
    BoxShadow(
      color: Colors.black.withOpacity(0.6),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // ============================================
  // ANIMATION DURATIONS
  // ============================================
  
  /// Fast animation - 100ms (micro-interactions)
  static const Duration durationFast = Duration(milliseconds: 100);
  
  /// Normal animation - 200ms (standard transitions - Requirement 15.4)
  static const Duration durationNormal = Duration(milliseconds: 200);
  
  /// Medium animation - 300ms (standard transitions - Requirement 15.4)
  static const Duration durationMedium = Duration(milliseconds: 300);
  
  /// Slow animation - 400ms (complex transitions)
  static const Duration durationSlow = Duration(milliseconds: 400);
  
  /// Extra slow animation - 500ms (spring animations with bounce)
  static const Duration durationXSlow = Duration(milliseconds: 500);
  
  /// Recommended transition duration - 250ms (middle of 200-300ms range per Requirement 15.4)
  static const Duration durationTransition = Duration(milliseconds: 250);

  // ============================================
  // BLUR VALUES
  // ============================================
  
  /// Light blur - 10px
  static const double blurLight = 10.0;
  
  /// Medium blur - 20px (standard glassmorphism)
  static const double blurMedium = 20.0;
  
  /// Heavy blur - 30px
  static const double blurHeavy = 30.0;

  // ============================================
  // OPACITY VALUES
  // ============================================
  
  /// Glass opacity light mode
  static const double glassOpacityLight = 0.7;
  
  /// Glass opacity dark mode
  static const double glassOpacityDark = 0.3;
  
  /// Disabled opacity
  static const double opacityDisabled = 0.4;
  
  /// Secondary opacity
  static const double opacitySecondary = 0.6;

  // ============================================
  // COMPONENT SIZES
  // ============================================
  
  /// Minimum touch target size
  static const double touchTargetMin = 44.0;
  
  /// Icon button size
  static const double iconButtonSize = 40.0;
  
  /// Toolbar icon size
  static const double toolbarIconSize = 32.0;
  
  /// Small icon size
  static const double iconSmall = 16.0;
  
  /// Medium icon size
  static const double iconMedium = 20.0;
  
  /// Large icon size
  static const double iconLarge = 24.0;
  
  /// Status indicator size
  static const double statusIndicatorSize = 8.0;
  
  /// Sidebar width
  static const double sidebarWidth = 240.0;
  
  /// List item minimum height
  static const double listItemMinHeight = 60.0;
  
  /// Button height small
  static const double buttonHeightSmall = 32.0;
  
  /// Button height medium
  static const double buttonHeightMedium = 44.0;
  
  /// Button height large
  static const double buttonHeightLarge = 52.0;
  
  /// Text field height
  static const double textFieldHeight = 44.0;

  // ============================================
  // HELPER METHODS
  // ============================================
  
  /// Get background color based on brightness
  static Color backgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }
  
  /// Get surface color based on brightness
  static Color surfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : lightSurface;
  }
  
  /// Get secondary color based on brightness
  static Color secondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSecondary
        : lightSecondary;
  }
  
  /// Get text color based on brightness
  static Color textColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkText
        : lightText;
  }
  
  /// Get secondary text color based on brightness
  static Color secondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSecondaryText
        : lightSecondaryText;
  }
  
  /// Get separator color based on brightness
  static Color separatorColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSeparator
        : lightSeparator;
  }
  
  /// Get shadow based on brightness
  static List<BoxShadow> shadow(BuildContext context, {bool elevated = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (elevated) {
      return isDark ? shadowDarkElevated : shadowLightElevated;
    }
    return isDark ? shadowDark : shadowLight;
  }
  
  /// Get glass opacity based on brightness
  static double glassOpacity(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? glassOpacityDark
        : glassOpacityLight;
  }
}
