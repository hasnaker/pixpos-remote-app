import 'dart:ui';
import 'package:flutter/material.dart';
import '../apple_theme.dart';

/// Apple-style Glassmorphism Container
/// 
/// A container with frosted glass effect using BackdropFilter.
/// Supports both light and dark modes with appropriate opacity.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double? opacity;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final bool showBorder;
  final Color? borderColor;
  final Color? backgroundColor;

  const GlassContainer({
    Key? key,
    required this.child,
    this.blur = 20.0,
    this.opacity,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.showBorder = true,
    this.borderColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveOpacity = opacity ?? (isDark ? 0.3 : 0.7);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(AppleTheme.radiusMedium);
    
    final effectiveBackgroundColor = backgroundColor ?? 
      (isDark 
        ? Colors.white.withOpacity(0.1)
        : Colors.white.withOpacity(effectiveOpacity));
    
    final effectiveBorderColor = borderColor ??
      (isDark 
        ? Colors.white.withOpacity(0.1)
        : Colors.white.withOpacity(0.3));

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? EdgeInsets.all(AppleTheme.spacing16),
            decoration: BoxDecoration(
              color: effectiveBackgroundColor,
              borderRadius: effectiveBorderRadius,
              border: showBorder ? Border.all(
                color: effectiveBorderColor,
                width: 1,
              ) : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A glass-style navigation bar
class GlassNavBar extends StatelessWidget {
  final Widget child;
  final double height;
  final EdgeInsets? padding;

  const GlassNavBar({
    Key? key,
    required this.child,
    this.height = 56,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      height: height,
      borderRadius: BorderRadius.zero,
      padding: padding ?? EdgeInsets.symmetric(horizontal: AppleTheme.spacing16),
      showBorder: false,
      child: child,
    );
  }
}

/// A glass-style toolbar
class GlassToolbar extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const GlassToolbar({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.height,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      height: height ?? 48,
      borderRadius: borderRadius ?? BorderRadius.circular(AppleTheme.radiusLarge),
      padding: padding ?? EdgeInsets.symmetric(horizontal: AppleTheme.spacing12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        children: children,
      ),
    );
  }
}

/// A glass-style modal backdrop
class GlassModalBackdrop extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTapOutside;
  final double blur;

  const GlassModalBackdrop({
    Key? key,
    required this.child,
    this.onTapOutside,
    this.blur = 10.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapOutside,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: GestureDetector(
            onTap: () {}, // Prevent tap from propagating
            child: child,
          ),
        ),
      ),
    );
  }
}
