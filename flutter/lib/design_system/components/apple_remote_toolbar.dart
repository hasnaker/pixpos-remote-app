import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../apple_theme.dart';
import '../apple_animations.dart';

/// Apple-style Remote Toolbar Theme
/// 
/// Provides consistent styling for the remote desktop toolbar
/// following Apple 2026 design language with glassmorphism effects.
class AppleToolbarTheme {
  AppleToolbarTheme._();

  // Colors
  static const Color activeColor = AppleTheme.primaryBlue;
  static const Color hoverActiveColor = Color(0xFF0A84FF);
  static Color inactiveColor = Colors.grey[700]!;
  static Color hoverInactiveColor = Colors.grey[600]!;
  static const Color dangerColor = AppleTheme.systemRed;
  static const Color hoverDangerColor = Color(0xFFFF453A);

  // Sizes - Updated to 32px per requirements
  static const double iconSize = 32.0;
  static const double buttonSize = 40.0;
  static const double buttonMargin = 4.0;
  static const double buttonRadius = 10.0;
  static const double toolbarHeight = 52.0;
  static const double toolbarRadius = AppleTheme.radiusLarge;
  static const double dividerWidth = 1.0;
  static const double dividerHeight = 24.0;

  // Glassmorphism
  static const double blurSigma = 20.0;
  static const double glassOpacityLight = 0.85;
  static const double glassOpacityDark = 0.4;

  // Tooltip delay - 500ms per requirements
  static const Duration tooltipDelay = Duration(milliseconds: 500);

  // Animation
  static const Duration animationDuration = AppleTheme.durationNormal;
  static const Curve animationCurve = Curves.easeOutCubic;
}

/// Apple-style Glass Toolbar Container
/// 
/// A floating toolbar with glassmorphism effect for remote desktop controls.
class AppleGlassToolbar extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final double? width;
  final bool showShadow;

  const AppleGlassToolbar({
    Key? key,
    required this.children,
    this.padding,
    this.width,
    this.showShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppleToolbarTheme.toolbarRadius),
        boxShadow: showShadow ? AppleTheme.shadow(context, elevated: true) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppleToolbarTheme.toolbarRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppleToolbarTheme.blurSigma,
            sigmaY: AppleToolbarTheme.blurSigma,
          ),
          child: Container(
            height: AppleToolbarTheme.toolbarHeight,
            padding: padding ?? EdgeInsets.symmetric(
              horizontal: AppleTheme.spacing12,
              vertical: AppleTheme.spacing6,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(AppleToolbarTheme.glassOpacityDark)
                  : Colors.white.withOpacity(AppleToolbarTheme.glassOpacityLight),
              borderRadius: BorderRadius.circular(AppleToolbarTheme.toolbarRadius),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

/// Apple-style Toolbar Icon Button
/// 
/// An icon button for the toolbar with proper sizing, hover states,
/// and tooltip with 500ms delay.
class AppleToolbarButton extends StatefulWidget {
  final String? assetName;
  final IconData? iconData;
  final Widget? customIcon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? activeColor;
  final Color? hoverColor;
  final bool isActive;
  final bool isDanger;
  final double? iconSize;

  const AppleToolbarButton({
    Key? key,
    this.assetName,
    this.iconData,
    this.customIcon,
    required this.tooltip,
    this.onPressed,
    this.activeColor,
    this.hoverColor,
    this.isActive = false,
    this.isDanger = false,
    this.iconSize,
  }) : super(key: key);

  @override
  State<AppleToolbarButton> createState() => _AppleToolbarButtonState();
}

class _AppleToolbarButtonState extends State<AppleToolbarButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _scaleController, 
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    if (widget.isDanger) {
      return _isHovered
          ? AppleToolbarTheme.hoverDangerColor
          : AppleToolbarTheme.dangerColor;
    }
    if (widget.isActive) {
      return _isHovered
          ? (widget.hoverColor ?? AppleToolbarTheme.hoverActiveColor)
          : (widget.activeColor ?? AppleToolbarTheme.activeColor);
    }
    return _isHovered
        ? AppleToolbarTheme.hoverInactiveColor
        : AppleToolbarTheme.inactiveColor;
  }

  Widget _buildIcon() {
    final size = widget.iconSize ?? AppleToolbarTheme.iconSize;
    
    if (widget.customIcon != null) {
      return widget.customIcon!;
    }
    
    if (widget.iconData != null) {
      return Icon(
        widget.iconData,
        color: Colors.white,
        size: size,
      );
    }
    
    if (widget.assetName != null) {
      return SvgPicture.asset(
        widget.assetName!,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        width: size,
        height: size,
      );
    }
    
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppleToolbarTheme.buttonMargin),
      child: Tooltip(
        message: widget.tooltip,
        waitDuration: AppleToolbarTheme.tooltipDelay,
        preferBelow: true,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppleTheme.darkSecondary
              : AppleTheme.lightText.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
        ),
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTapDown: (_) => _scaleController.forward(),
            onTapUp: (_) {
              _scaleController.reverse();
              widget.onPressed?.call();
            },
            onTapCancel: () => _scaleController.reverse(),
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) => Transform.scale(
                scale: _scaleAnimation.value,
                child: AnimatedContainer(
                  duration: AppleToolbarTheme.animationDuration,
                  curve: AppleToolbarTheme.animationCurve,
                  width: AppleToolbarTheme.buttonSize,
                  height: AppleToolbarTheme.buttonSize,
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(
                      AppleToolbarTheme.buttonRadius,
                    ),
                  ),
                  child: Center(child: _buildIcon()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Apple-style Toolbar Divider
/// 
/// A vertical divider for separating toolbar button groups.
class AppleToolbarDivider extends StatelessWidget {
  final double? height;
  final EdgeInsets? margin;

  const AppleToolbarDivider({
    Key? key,
    this.height,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: AppleTheme.spacing8),
      width: AppleToolbarTheme.dividerWidth,
      height: height ?? AppleToolbarTheme.dividerHeight,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.2)
            : Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppleToolbarTheme.dividerWidth / 2),
      ),
    );
  }
}

/// Apple-style Toolbar Submenu Button
/// 
/// A button that opens a submenu when pressed.
class AppleToolbarSubmenuButton extends StatefulWidget {
  final String? assetName;
  final IconData? iconData;
  final String tooltip;
  final List<Widget> Function() menuChildrenBuilder;
  final Color? activeColor;
  final bool isActive;

  const AppleToolbarSubmenuButton({
    Key? key,
    this.assetName,
    this.iconData,
    required this.tooltip,
    required this.menuChildrenBuilder,
    this.activeColor,
    this.isActive = false,
  }) : super(key: key);

  @override
  State<AppleToolbarSubmenuButton> createState() =>
      _AppleToolbarSubmenuButtonState();
}

class _AppleToolbarSubmenuButtonState extends State<AppleToolbarSubmenuButton> {
  bool _isHovered = false;

  Color get _backgroundColor {
    if (widget.isActive) {
      return _isHovered
          ? AppleToolbarTheme.hoverActiveColor
          : (widget.activeColor ?? AppleToolbarTheme.activeColor);
    }
    return _isHovered
        ? AppleToolbarTheme.hoverInactiveColor
        : AppleToolbarTheme.inactiveColor;
  }

  Widget _buildIcon() {
    if (widget.iconData != null) {
      return Icon(
        widget.iconData,
        color: Colors.white,
        size: AppleToolbarTheme.iconSize,
      );
    }
    
    if (widget.assetName != null) {
      return SvgPicture.asset(
        widget.assetName!,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        width: AppleToolbarTheme.iconSize,
        height: AppleToolbarTheme.iconSize,
      );
    }
    
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppleToolbarTheme.buttonMargin),
      child: Tooltip(
        message: widget.tooltip,
        waitDuration: AppleToolbarTheme.tooltipDelay,
        child: MenuAnchor(
          style: MenuStyle(
            backgroundColor: MaterialStatePropertyAll(
              isDark ? AppleTheme.darkSurface : AppleTheme.lightSurface,
            ),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
              ),
            ),
            elevation: MaterialStatePropertyAll(8),
            padding: MaterialStatePropertyAll(
              EdgeInsets.symmetric(vertical: AppleTheme.spacing8),
            ),
          ),
          menuChildren: widget.menuChildrenBuilder(),
          builder: (context, controller, child) {
            return MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: GestureDetector(
                onTap: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                child: AnimatedContainer(
                  duration: AppleToolbarTheme.animationDuration,
                  curve: AppleToolbarTheme.animationCurve,
                  width: AppleToolbarTheme.buttonSize,
                  height: AppleToolbarTheme.buttonSize,
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(
                      AppleToolbarTheme.buttonRadius,
                    ),
                  ),
                  child: Center(child: _buildIcon()),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


/// Apple-style Collapsible Toolbar
/// 
/// A toolbar that can collapse/expand with smooth animations.
/// Implements requirement 14.5 for smooth slide animation.
class AppleCollapsibleToolbar extends StatefulWidget {
  final List<Widget> children;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;
  final VoidCallback? onToggleFullscreen;
  final VoidCallback? onMinimize;
  final bool isFullscreen;
  final bool showMinimize;
  final Widget? dragHandle;

  const AppleCollapsibleToolbar({
    Key? key,
    required this.children,
    this.isCollapsed = false,
    this.onToggleCollapse,
    this.onToggleFullscreen,
    this.onMinimize,
    this.isFullscreen = false,
    this.showMinimize = true,
    this.dragHandle,
  }) : super(key: key);

  @override
  State<AppleCollapsibleToolbar> createState() => _AppleCollapsibleToolbarState();
}

class _AppleCollapsibleToolbarState extends State<AppleCollapsibleToolbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppleTheme.durationMedium,
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: -60.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    if (widget.isCollapsed) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AppleCollapsibleToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      if (widget.isCollapsed) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main toolbar with slide/fade animation
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: widget.isCollapsed
                      ? const SizedBox.shrink()
                      : AppleGlassToolbar(children: widget.children),
                ),
              ),
            );
          },
        ),
        // Collapse handle - always visible
        _buildCollapseHandle(context),
      ],
    );
  }

  Widget _buildCollapseHandle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
        boxShadow: AppleTheme.shadow(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppleToolbarTheme.blurSigma,
            sigmaY: AppleToolbarTheme.blurSigma,
          ),
          child: Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.5)
                  : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                if (widget.dragHandle != null) widget.dragHandle!,
                if (widget.dragHandle != null) const SizedBox(width: 4),
                
                // Fullscreen toggle
                _CollapseHandleButton(
                  icon: widget.isFullscreen
                      ? Icons.fullscreen_exit_rounded
                      : Icons.fullscreen_rounded,
                  tooltip: widget.isFullscreen ? 'Exit Fullscreen' : 'Fullscreen',
                  onPressed: widget.onToggleFullscreen,
                ),
                
                // Minimize (conditional)
                if (widget.showMinimize && widget.isFullscreen)
                  _CollapseHandleButton(
                    icon: Icons.remove_rounded,
                    tooltip: 'Minimize',
                    onPressed: widget.onMinimize,
                  ),
                
                // Collapse/Expand toggle
                _CollapseHandleButton(
                  icon: widget.isCollapsed
                      ? Icons.expand_more_rounded
                      : Icons.expand_less_rounded,
                  tooltip: widget.isCollapsed ? 'Show Toolbar' : 'Hide Toolbar',
                  onPressed: widget.onToggleCollapse,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small button for the collapse handle bar
class _CollapseHandleButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? iconColor;

  const _CollapseHandleButton({
    Key? key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.iconColor,
  }) : super(key: key);

  @override
  State<_CollapseHandleButton> createState() => _CollapseHandleButtonState();
}

class _CollapseHandleButtonState extends State<_CollapseHandleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Tooltip(
      message: widget.tooltip,
      waitDuration: AppleToolbarTheme.tooltipDelay,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: AppleTheme.durationFast,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _isHovered
                  ? (isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: widget.iconColor ??
                  (isDark
                      ? Colors.white.withOpacity(0.8)
                      : Colors.black.withOpacity(0.6)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Apple-style Floating Action Toolbar
/// 
/// A floating toolbar that appears at the top of the remote view
/// with glassmorphism effect and smooth animations.
class AppleFloatingToolbar extends StatefulWidget {
  final List<Widget> children;
  final Alignment alignment;
  final EdgeInsets? margin;
  final bool visible;
  final Duration animationDuration;

  const AppleFloatingToolbar({
    Key? key,
    required this.children,
    this.alignment = Alignment.topCenter,
    this.margin,
    this.visible = true,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  State<AppleFloatingToolbar> createState() => _AppleFloatingToolbarState();
}

class _AppleFloatingToolbarState extends State<AppleFloatingToolbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -20.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.visible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AppleFloatingToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Align(
          alignment: widget.alignment,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Padding(
                padding: widget.margin ?? const EdgeInsets.only(top: 8),
                child: AppleGlassToolbar(children: widget.children),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Drag handle widget for toolbar repositioning
class AppleToolbarDragHandle extends StatelessWidget {
  final Color? color;

  const AppleToolbarDragHandle({
    Key? key,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Icon(
      Icons.drag_indicator_rounded,
      size: 18,
      color: color ??
          (isDark
              ? Colors.white.withOpacity(0.5)
              : Colors.black.withOpacity(0.3)),
    );
  }
}
