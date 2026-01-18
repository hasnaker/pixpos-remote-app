import 'package:flutter/material.dart';
import '../apple_theme.dart';
import '../apple_animations.dart';

/// Apple-style Card Component
/// 
/// A card with subtle shadows, hover effects, and proper dark mode support.
class AppleCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool elevated;
  final bool showBorder;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const AppleCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.elevated = true,
    this.showBorder = false,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<AppleCard> createState() => _AppleCardState();
}

class _AppleCardState extends State<AppleCard>
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
      end: AppleAnimations.cardPressScale,
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
    
    final effectiveBackgroundColor = widget.backgroundColor ??
      (isDark ? AppleTheme.darkSurface : AppleTheme.lightSurface);
    
    final hoverBackgroundColor = isDark 
      ? AppleTheme.darkSecondary 
      : AppleTheme.lightBackground;
    
    final effectiveBorderRadius = widget.borderRadius ?? 
      BorderRadius.circular(AppleTheme.radiusMedium);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: widget.onTap != null ? (_) {
          setState(() => _isPressed = true);
          _scaleController.forward();
        } : null,
        onTapUp: widget.onTap != null ? (_) {
          setState(() => _isPressed = false);
          _scaleController.reverse();
        } : null,
        onTapCancel: widget.onTap != null ? () {
          setState(() => _isPressed = false);
          _scaleController.reverse();
        } : null,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: widget.onTap != null ? _scaleAnimation.value : 1.0,
            child: AnimatedContainer(
              duration: AppleTheme.durationNormal,
              curve: Curves.easeOut,
              width: widget.width,
              height: widget.height,
              margin: widget.margin,
              padding: widget.padding ?? EdgeInsets.all(AppleTheme.spacing16),
              decoration: BoxDecoration(
                color: _isPressed 
                  ? hoverBackgroundColor.withOpacity(0.8)
                  : (_isHovered && widget.onTap != null 
                      ? hoverBackgroundColor 
                      : effectiveBackgroundColor),
                borderRadius: effectiveBorderRadius,
                boxShadow: widget.elevated
                    ? (isDark 
                        ? (_isHovered ? AppleTheme.shadowDarkElevated : AppleTheme.shadowDark)
                        : (_isHovered ? AppleTheme.shadowLightElevated : AppleTheme.shadowLight))
                    : null,
                border: (widget.showBorder || isDark) ? Border.all(
                  color: isDark ? AppleTheme.darkTertiary : AppleTheme.lightSecondary,
                  width: 0.5,
                ) : null,
              ),
              transform: _isHovered && widget.onTap != null
                  ? (Matrix4.identity()..translate(0.0, -2.0))
                  : Matrix4.identity(),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Apple-style List Card (for list items)
class AppleListCard extends StatefulWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double minHeight;

  const AppleListCard({
    Key? key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    this.minHeight = 60,
  }) : super(key: key);

  @override
  State<AppleListCard> createState() => _AppleListCardState();
}

class _AppleListCardState extends State<AppleListCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppleTheme.durationFast,
          constraints: BoxConstraints(minHeight: widget.minHeight),
          padding: widget.padding ?? EdgeInsets.symmetric(
            horizontal: AppleTheme.spacing16,
            vertical: AppleTheme.spacing12,
          ),
          decoration: BoxDecoration(
            color: _isHovered && widget.onTap != null
              ? (isDark ? AppleTheme.darkSecondary : AppleTheme.lightBackground)
              : Colors.transparent,
            borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
          ),
          child: Row(
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                SizedBox(width: AppleTheme.spacing12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.title,
                    if (widget.subtitle != null) ...[
                      SizedBox(height: AppleTheme.spacing4),
                      widget.subtitle!,
                    ],
                  ],
                ),
              ),
              if (widget.trailing != null) ...[
                SizedBox(width: AppleTheme.spacing12),
                widget.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Apple-style Section Card (grouped content)
class AppleSectionCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool showDividers;

  const AppleSectionCard({
    Key? key,
    this.title,
    required this.children,
    this.padding,
    this.margin,
    this.showDividers = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: margin ?? EdgeInsets.symmetric(vertical: AppleTheme.spacing8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: EdgeInsets.only(
                left: AppleTheme.spacing16,
                bottom: AppleTheme.spacing8,
              ),
              child: Text(
                title!.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          AppleCard(
            padding: padding ?? EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (showDividers && i < children.length - 1)
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: AppleTheme.spacing16,
                      color: isDark ? AppleTheme.darkSeparator : AppleTheme.lightSeparator,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
