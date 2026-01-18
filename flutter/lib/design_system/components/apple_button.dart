import 'package:flutter/material.dart';
import '../apple_theme.dart';
import '../apple_animations.dart';

/// Button style variants
enum AppleButtonStyle { 
  /// Filled button with accent color background
  filled, 
  /// Outlined button with border
  outlined, 
  /// Text-only button
  text,
  /// Destructive action button (red)
  destructive,
  /// Secondary filled button (gray)
  secondary,
}

/// Button size variants
enum AppleButtonSize { 
  /// Small button - 32px height
  small, 
  /// Medium button - 44px height (default)
  medium, 
  /// Large button - 52px height
  large 
}

/// Apple-style Button Component
/// 
/// A customizable button following Apple's Human Interface Guidelines.
/// Supports multiple styles, sizes, icons, and loading states.
class AppleButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppleButtonStyle style;
  final AppleButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isExpanded;
  final Color? customColor;
  final double? width;

  const AppleButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.style = AppleButtonStyle.filled,
    this.size = AppleButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
    this.customColor,
    this.width,
  }) : super(key: key);

  /// Creates a filled primary button
  factory AppleButton.primary({
    required String text,
    VoidCallback? onPressed,
    AppleButtonSize size = AppleButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
    bool isExpanded = false,
  }) {
    return AppleButton(
      text: text,
      onPressed: onPressed,
      style: AppleButtonStyle.filled,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isExpanded: isExpanded,
    );
  }

  /// Creates an outlined secondary button
  factory AppleButton.secondary({
    required String text,
    VoidCallback? onPressed,
    AppleButtonSize size = AppleButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
    bool isExpanded = false,
  }) {
    return AppleButton(
      text: text,
      onPressed: onPressed,
      style: AppleButtonStyle.outlined,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isExpanded: isExpanded,
    );
  }

  /// Creates a destructive (red) button
  factory AppleButton.destructive({
    required String text,
    VoidCallback? onPressed,
    AppleButtonSize size = AppleButtonSize.medium,
    IconData? icon,
    bool isLoading = false,
    bool isExpanded = false,
  }) {
    return AppleButton(
      text: text,
      onPressed: onPressed,
      style: AppleButtonStyle.destructive,
      size: size,
      icon: icon,
      isLoading: isLoading,
      isExpanded: isExpanded,
    );
  }

  /// Creates a text-only button
  factory AppleButton.text({
    required String text,
    VoidCallback? onPressed,
    AppleButtonSize size = AppleButtonSize.medium,
    IconData? icon,
  }) {
    return AppleButton(
      text: text,
      onPressed: onPressed,
      style: AppleButtonStyle.text,
      size: size,
      icon: icon,
    );
  }

  @override
  State<AppleButton> createState() => _AppleButtonState();
}

class _AppleButtonState extends State<AppleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppleAnimations.springDuration,
      vsync: this,
    );
    // Use spring curve for bouncy effect (Requirement 15.2)
    _scaleAnimation = Tween<double>(
      begin: 1.0, 
      end: AppleAnimations.buttonPressScale,
    ).animate(
      CurvedAnimation(
        parent: _controller, 
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  double get _height {
    switch (widget.size) {
      case AppleButtonSize.small:
        return AppleTheme.buttonHeightSmall;
      case AppleButtonSize.medium:
        return AppleTheme.buttonHeightMedium;
      case AppleButtonSize.large:
        return AppleTheme.buttonHeightLarge;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case AppleButtonSize.small:
        return 14;
      case AppleButtonSize.medium:
        return 16;
      case AppleButtonSize.large:
        return 18;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case AppleButtonSize.small:
        return 16;
      case AppleButtonSize.medium:
        return 20;
      case AppleButtonSize.large:
        return 22;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case AppleButtonSize.small:
        return EdgeInsets.symmetric(horizontal: AppleTheme.spacing12);
      case AppleButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: AppleTheme.spacing20);
      case AppleButtonSize.large:
        return EdgeInsets.symmetric(horizontal: AppleTheme.spacing24);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    Color backgroundColor;
    Color textColor;
    Border? border;

    switch (widget.style) {
      case AppleButtonStyle.filled:
        backgroundColor = widget.customColor ?? AppleTheme.primaryBlue;
        textColor = Colors.white;
        break;
      case AppleButtonStyle.outlined:
        backgroundColor = Colors.transparent;
        textColor = widget.customColor ?? AppleTheme.primaryBlue;
        border = Border.all(
          color: widget.customColor ?? AppleTheme.primaryBlue,
          width: 1.5,
        );
        break;
      case AppleButtonStyle.text:
        backgroundColor = Colors.transparent;
        textColor = widget.customColor ?? AppleTheme.primaryBlue;
        break;
      case AppleButtonStyle.destructive:
        backgroundColor = AppleTheme.systemRed;
        textColor = Colors.white;
        break;
      case AppleButtonStyle.secondary:
        backgroundColor = isDark ? AppleTheme.darkSecondary : AppleTheme.lightSecondary;
        textColor = isDark ? AppleTheme.darkText : AppleTheme.lightText;
        break;
    }

    if (isDisabled) {
      backgroundColor = backgroundColor.withOpacity(AppleTheme.opacityDisabled);
      textColor = textColor.withOpacity(AppleTheme.opacityDisabled);
    }

    // Hover effect
    if (_isHovered && !isDisabled && widget.style == AppleButtonStyle.filled) {
      backgroundColor = Color.lerp(backgroundColor, Colors.white, 0.1)!;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) {
          setState(() => _isPressed = true);
          _controller.forward();
        },
        onTapUp: isDisabled ? null : (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
          widget.onPressed?.call();
        },
        onTapCancel: isDisabled ? null : () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: AppleTheme.durationNormal,
              curve: Curves.easeOut,
              width: widget.width ?? (widget.isExpanded ? double.infinity : null),
              height: _height,
              padding: _padding,
              decoration: BoxDecoration(
                color: _isPressed && !isDisabled
                    ? backgroundColor.withOpacity(0.8)
                    : backgroundColor,
                borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
                border: border,
              ),
              child: Row(
                mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: _iconSize,
                      height: _iconSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(textColor),
                      ),
                    )
                  else ...[
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: textColor, size: _iconSize),
                      SizedBox(width: AppleTheme.spacing8),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: _fontSize,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (widget.trailingIcon != null) ...[
                      SizedBox(width: AppleTheme.spacing8),
                      Icon(widget.trailingIcon, color: textColor, size: _iconSize),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Apple-style Icon Button
class AppleIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final String? tooltip;
  final bool isCircular;

  const AppleIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.size = 40,
    this.color,
    this.backgroundColor,
    this.tooltip,
    this.isCircular = true,
  }) : super(key: key);

  @override
  State<AppleIconButton> createState() => _AppleIconButtonState();
}

class _AppleIconButtonState extends State<AppleIconButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: AppleAnimations.springDuration,
      vsync: this,
    );
    // Use spring curve for bouncy effect (Requirement 15.2)
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppleAnimations.iconPressScale,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = widget.onPressed == null;
    
    final effectiveColor = widget.color ?? 
      (isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText);
    
    final effectiveBackgroundColor = widget.backgroundColor ??
      (_isHovered 
        ? (isDark ? AppleTheme.darkSecondary : AppleTheme.lightSecondary)
        : Colors.transparent);

    Widget button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) {
          setState(() => _isPressed = true);
          _scaleController.forward();
        },
        onTapUp: isDisabled ? null : (_) {
          setState(() => _isPressed = false);
          _scaleController.reverse();
          widget.onPressed?.call();
        },
        onTapCancel: isDisabled ? null : () {
          setState(() => _isPressed = false);
          _scaleController.reverse();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: AppleTheme.durationFast,
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: _isPressed ? effectiveBackgroundColor.withOpacity(0.8) : effectiveBackgroundColor,
                shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: widget.isCircular ? null : BorderRadius.circular(AppleTheme.radiusSmall),
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  size: widget.size * 0.5,
                  color: isDisabled 
                    ? effectiveColor.withOpacity(AppleTheme.opacityDisabled)
                    : (_isHovered ? AppleTheme.primaryBlue : effectiveColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        waitDuration: Duration(milliseconds: 500),
        child: button,
      );
    }

    return button;
  }
}
