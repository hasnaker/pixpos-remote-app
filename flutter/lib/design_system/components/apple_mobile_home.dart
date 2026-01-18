import 'package:flutter/material.dart';
import '../apple_theme.dart';
import '../apple_typography.dart';
import 'apple_card.dart';

/// Apple-style Mobile Home Page wrapper
/// 
/// Provides consistent styling for the mobile home page with
/// proper touch targets (44px minimum) and Apple design language.
class AppleMobileHome extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final bool showAppBar;

  const AppleMobileHome({
    Key? key,
    required this.child,
    this.title,
    this.actions,
    this.bottomNavigationBar,
    this.showAppBar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppleTheme.darkBackground : AppleTheme.lightBackground,
      appBar: showAppBar ? AppBar(
        backgroundColor: isDark ? AppleTheme.darkSurface : AppleTheme.lightSurface,
        elevation: 0,
        centerTitle: true,
        title: title != null 
          ? Text(
              title!,
              style: AppleTypography.headline(context),
            )
          : null,
        actions: actions,
        toolbarHeight: AppleTheme.touchTargetMin + AppleTheme.spacing16,
      ) : null,
      bottomNavigationBar: bottomNavigationBar,
      body: child,
    );
  }
}

/// Apple-style Mobile Section Card
/// 
/// A card component for mobile sections with proper padding and styling.
class AppleMobileSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const AppleMobileSectionCard({
    Key? key,
    required this.child,
    this.margin,
    this.padding,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.symmetric(
        horizontal: AppleTheme.spacing16,
        vertical: AppleTheme.spacing8,
      ),
      child: AppleCard(
        onTap: onTap,
        padding: padding ?? EdgeInsets.all(AppleTheme.spacing16),
        child: child,
      ),
    );
  }
}

/// Apple-style Mobile List Item
/// 
/// A list item with 44px minimum touch target and proper styling.
class AppleMobileListItem extends StatefulWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final EdgeInsets? contentPadding;

  const AppleMobileListItem({
    Key? key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.contentPadding,
  }) : super(key: key);

  @override
  State<AppleMobileListItem> createState() => _AppleMobileListItemState();
}

class _AppleMobileListItemState extends State<AppleMobileListItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null ? (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      } : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: AppleTheme.durationFast,
        constraints: BoxConstraints(minHeight: AppleTheme.touchTargetMin),
        decoration: BoxDecoration(
          color: _isPressed 
            ? (isDark ? AppleTheme.darkSecondary : AppleTheme.lightSecondary)
            : Colors.transparent,
        ),
        child: Column(
          children: [
            Padding(
              padding: widget.contentPadding ?? EdgeInsets.symmetric(
                horizontal: AppleTheme.spacing16,
                vertical: AppleTheme.spacing12,
              ),
              child: Row(
                children: [
                  if (widget.leading != null) ...[
                    SizedBox(
                      width: AppleTheme.touchTargetMin,
                      height: AppleTheme.touchTargetMin,
                      child: Center(child: widget.leading),
                    ),
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
            if (widget.showDivider)
              Divider(
                height: 1,
                thickness: 0.5,
                indent: widget.leading != null 
                  ? AppleTheme.touchTargetMin + AppleTheme.spacing28
                  : AppleTheme.spacing16,
                color: isDark ? AppleTheme.darkSeparator : AppleTheme.lightSeparator,
              ),
          ],
        ),
      ),
    );
  }
}

/// Apple-style Mobile Bottom Navigation Bar
/// 
/// A bottom navigation bar with proper touch targets and styling.
class AppleMobileBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<AppleMobileNavItem> items;
  final ValueChanged<int> onTap;

  const AppleMobileBottomNav({
    Key? key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppleTheme.darkSurface : AppleTheme.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppleTheme.darkSeparator : AppleTheme.lightSeparator,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56 + AppleTheme.spacing8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;
              
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: AppleTheme.touchTargetMin,
                      minWidth: AppleTheme.touchTargetMin,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: AppleTheme.durationNormal,
                          child: Icon(
                            item.icon,
                            size: 24,
                            color: isSelected 
                              ? AppleTheme.primaryBlue
                              : (isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText),
                          ),
                        ),
                        SizedBox(height: AppleTheme.spacing4),
                        AnimatedDefaultTextStyle(
                          duration: AppleTheme.durationNormal,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected 
                              ? AppleTheme.primaryBlue
                              : (isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText),
                          ),
                          child: Text(item.label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// Navigation item for AppleMobileBottomNav
class AppleMobileNavItem {
  final IconData icon;
  final String label;

  const AppleMobileNavItem({
    required this.icon,
    required this.label,
  });
}

/// Apple-style Mobile ID Display
/// 
/// Displays the connection ID with proper styling and copy functionality.
class AppleMobileIdDisplay extends StatelessWidget {
  final String id;
  final VoidCallback? onCopy;
  final bool isLoading;

  const AppleMobileIdDisplay({
    Key? key,
    required this.id,
    this.onCopy,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppleMobileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your ID',
            style: AppleTypography.footnote(context).copyWith(
              color: isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText,
            ),
          ),
          SizedBox(height: AppleTheme.spacing8),
          Row(
            children: [
              Expanded(
                child: isLoading
                  ? _buildLoadingPlaceholder(context)
                  : Text(
                      id.isEmpty ? '...' : id,
                      style: AppleTypography.monospace(context).copyWith(
                        color: AppleTheme.primaryBlue,
                        fontSize: 24,
                        letterSpacing: 1.5,
                      ),
                    ),
              ),
              if (!isLoading && id.isNotEmpty)
                GestureDetector(
                  onTap: onCopy,
                  child: Container(
                    width: AppleTheme.touchTargetMin,
                    height: AppleTheme.touchTargetMin,
                    decoration: BoxDecoration(
                      color: AppleTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
                    ),
                    child: Icon(
                      Icons.copy_rounded,
                      color: AppleTheme.primaryBlue,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: isDark ? AppleTheme.darkSecondary : AppleTheme.lightSecondary,
        borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
      ),
    );
  }
}

/// Apple-style Mobile Connection Input
/// 
/// Input field for entering remote ID with proper touch targets.
class AppleMobileConnectionInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback? onConnect;
  final VoidCallback? onClear;
  final String? hint;

  const AppleMobileConnectionInput({
    Key? key,
    required this.controller,
    this.focusNode,
    this.onConnect,
    this.onClear,
    this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppleMobileSectionCard(
      padding: EdgeInsets.all(AppleTheme.spacing12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? AppleTheme.darkText : AppleTheme.lightText,
              ),
              decoration: InputDecoration(
                hintText: hint ?? 'Remote ID',
                hintStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppleTheme.spacing8,
                  vertical: AppleTheme.spacing12,
                ),
              ),
              keyboardType: TextInputType.visiblePassword,
              autocorrect: false,
              enableSuggestions: false,
              onSubmitted: (_) => onConnect?.call(),
            ),
          ),
          if (controller.text.isNotEmpty && onClear != null)
            GestureDetector(
              onTap: onClear,
              child: Container(
                width: AppleTheme.touchTargetMin,
                height: AppleTheme.touchTargetMin,
                child: Icon(
                  Icons.clear_rounded,
                  color: isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText,
                  size: 20,
                ),
              ),
            ),
          GestureDetector(
            onTap: onConnect,
            child: Container(
              width: AppleTheme.touchTargetMin + AppleTheme.spacing8,
              height: AppleTheme.touchTargetMin + AppleTheme.spacing8,
              decoration: BoxDecoration(
                color: AppleTheme.primaryBlue,
                borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
