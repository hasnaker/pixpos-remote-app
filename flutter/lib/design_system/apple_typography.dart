import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'apple_theme.dart';

/// Apple 2026 Design System - Typography
/// 
/// This class provides all typography styles following Apple's
/// Human Interface Guidelines typography scale.
class AppleTypography {
  AppleTypography._();

  /// Get Inter font family
  static String get fontFamily => GoogleFonts.inter().fontFamily ?? 'Inter';
  
  /// Get JetBrains Mono font family
  static String get fontFamilyMono => GoogleFonts.jetBrainsMono().fontFamily ?? 'JetBrains Mono';

  // ============================================
  // DISPLAY STYLES
  // ============================================
  
  /// Large Title - 34px Bold
  /// Used for main screen titles
  static TextStyle largeTitle(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.2,
    color: AppleTheme.textColor(context),
  );
  
  /// Title 1 - 28px Bold
  /// Used for section headers
  static TextStyle title1(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.2,
    color: AppleTheme.textColor(context),
  );
  
  /// Title 2 - 22px Bold
  /// Used for subsection headers
  static TextStyle title2(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.3,
    color: AppleTheme.textColor(context),
  );
  
  /// Title 3 - 20px Semibold
  /// Used for card titles
  static TextStyle title3(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
    color: AppleTheme.textColor(context),
  );

  // ============================================
  // BODY STYLES
  // ============================================
  
  /// Headline - 17px Semibold
  /// Used for emphasized body text
  static TextStyle headline(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
    color: AppleTheme.textColor(context),
  );
  
  /// Body - 17px Regular
  /// Primary body text style
  static TextStyle body(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
    height: 1.5,
    color: AppleTheme.textColor(context),
  );
  
  /// Body Bold - 17px Semibold
  static TextStyle bodyBold(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.5,
    color: AppleTheme.textColor(context),
  );
  
  /// Callout - 16px Regular
  /// Used for secondary body text
  static TextStyle callout(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
    height: 1.4,
    color: AppleTheme.textColor(context),
  );
  
  /// Callout Bold - 16px Semibold
  static TextStyle calloutBold(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
    color: AppleTheme.textColor(context),
  );
  
  /// Subheadline - 15px Regular
  /// Used for supporting text
  static TextStyle subheadline(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    height: 1.4,
    color: AppleTheme.textColor(context),
  );
  
  /// Subheadline Bold - 15px Semibold
  static TextStyle subheadlineBold(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
    color: AppleTheme.textColor(context),
  );

  // ============================================
  // SMALL STYLES
  // ============================================
  
  /// Footnote - 13px Regular
  /// Used for footnotes and labels
  static TextStyle footnote(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
    color: AppleTheme.secondaryTextColor(context),
  );
  
  /// Footnote Bold - 13px Semibold
  static TextStyle footnoteBold(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: AppleTheme.secondaryTextColor(context),
  );
  
  /// Caption 1 - 12px Regular
  /// Used for captions and timestamps
  static TextStyle caption1(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.3,
    color: AppleTheme.secondaryTextColor(context),
  );
  
  /// Caption 1 Bold - 12px Medium
  static TextStyle caption1Bold(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.3,
    color: AppleTheme.secondaryTextColor(context),
  );
  
  /// Caption 2 - 11px Regular
  /// Used for smallest text elements
  static TextStyle caption2(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.3,
    color: AppleTheme.secondaryTextColor(context),
  );

  // ============================================
  // SPECIAL STYLES
  // ============================================
  
  /// Monospace - 28px Medium
  /// Used for connection IDs
  static TextStyle monospace(BuildContext context) => TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    letterSpacing: 2,
    height: 1.2,
    color: AppleTheme.textColor(context),
  );
  
  /// Monospace Small - 16px Regular
  /// Used for code snippets
  static TextStyle monospaceSmall(BuildContext context) => TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.4,
    color: AppleTheme.textColor(context),
  );
  
  /// Button - 17px Semibold
  /// Used for button labels
  static TextStyle button(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.2,
    color: AppleTheme.textColor(context),
  );
  
  /// Button Small - 15px Semibold
  static TextStyle buttonSmall(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.2,
    color: AppleTheme.textColor(context),
  );
  
  /// Label - 14px Medium
  /// Used for form labels
  static TextStyle label(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.3,
    color: AppleTheme.secondaryTextColor(context),
  );
  
  /// Tab Bar - 10px Medium
  /// Used for tab bar labels
  static TextStyle tabBar(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.2,
    color: AppleTheme.textColor(context),
  );

  // ============================================
  // HELPER METHODS
  // ============================================
  
  /// Get style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  /// Get style with accent color
  static TextStyle withAccent(TextStyle style) {
    return style.copyWith(color: AppleTheme.primaryBlue);
  }
  
  /// Get style with secondary color
  static TextStyle withSecondary(BuildContext context, TextStyle style) {
    return style.copyWith(color: AppleTheme.secondaryTextColor(context));
  }
  
  /// Get style with error color
  static TextStyle withError(TextStyle style) {
    return style.copyWith(color: AppleTheme.systemRed);
  }
  
  /// Get style with success color
  static TextStyle withSuccess(TextStyle style) {
    return style.copyWith(color: AppleTheme.systemGreen);
  }
}
