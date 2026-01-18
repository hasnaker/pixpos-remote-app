import 'package:flutter/material.dart';
import '../apple_theme.dart';
import '../apple_typography.dart';

/// Apple-style Sidebar Navigation Item
class AppleSidebarItem {
  final String key;
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool enabled;

  const AppleSidebarItem({
    required this.key,
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.onTap,
    this.trailing,
    this.enabled = true,
  });
}

/// Apple-style Sidebar Navigation
/// 
/// A sidebar navigation component following Apple's Human Interface Guidelines.
/// Features:
/// - 240px width
/// - Active item highlight with accent color
/// - Smooth transitions (300ms)
/// - Support for icons and labels
class AppleSidebar extends StatelessWidget {
  final List<AppleSidebarItem> items;
  final String? selectedKey;
  final ValueChanged<String>? onItemSelected;
  final Widget? header;
  final Widget? footer;
  final double width;
  final EdgeInsets? padding;

  const AppleSidebar({
    Key? key,
    required this.items,
    this.selectedKey,
    this.onItemSelected,
    this.header,
    this.footer,
    this.width = 240.0,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isDark ? AppleTheme.darkSurface : AppleTheme.lightSurface,
        border: Border(
          right: BorderSide(
            color: isDark ? AppleTheme.darkSeparator : AppleTheme.lightSeparator,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          if (header != null) header!,
          Expanded(
            child: ListView.builder(
              padding: padding ?? EdgeInsets.symmetric(
                horizontal: AppleTheme.spacing12,
                vertical: AppleTheme.spacing8,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item.key == selectedKey;
                
                return _AppleSidebarItemWidget(
                  item: item,
                  isSelected: isSelected,
                  onTap: () {
                    if (item.enabled) {
                      item.onTap?.call();
                      onItemSelected?.call(item.key);
                    }
                  },
                );
              },
            ),
          ),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

class _AppleSidebarItemWidget extends StatefulWidget {
  final AppleSidebarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _AppleSidebarItemWidget({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_AppleSidebarItemWidget> createState() => _AppleSidebarItemWidgetState();
}

class _AppleSidebarItemWidgetState extends State<_AppleSidebarItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = widget.item.enabled;
    
    // Determine background color
    Color backgroundColor;
    if (widget.isSelected) {
      backgroundColor = AppleTheme.primaryBlue.withOpacity(0.15);
    } else if (_isHovered && isEnabled) {
      backgroundColor = isDark 
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.03);
    } else {
      backgroundColor = Colors.transparent;
    }
    
    // Determine icon and text color
    Color iconColor;
    Color textColor;
    if (!isEnabled) {
      iconColor = AppleTheme.secondaryTextColor(context).withOpacity(0.5);
      textColor = AppleTheme.secondaryTextColor(context).withOpacity(0.5);
    } else if (widget.isSelected) {
      iconColor = AppleTheme.primaryBlue;
      textColor = AppleTheme.primaryBlue;
    } else {
      iconColor = AppleTheme.secondaryTextColor(context);
      textColor = AppleTheme.textColor(context);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isEnabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: AppleTheme.durationNormal,
          curve: Curves.easeOut,
          margin: EdgeInsets.only(bottom: AppleTheme.spacing4),
          padding: EdgeInsets.symmetric(
            horizontal: AppleTheme.spacing12,
            vertical: AppleTheme.spacing10,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: AppleTheme.durationFast,
                child: Icon(
                  widget.isSelected 
                      ? (widget.item.selectedIcon ?? widget.item.icon)
                      : widget.item.icon,
                  key: ValueKey(widget.isSelected),
                  size: AppleTheme.iconMedium,
                  color: iconColor,
                ),
              ),
              SizedBox(width: AppleTheme.spacing12),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: AppleTypography.subheadline(context).copyWith(
                    color: textColor,
                    fontWeight: widget.isSelected 
                        ? FontWeight.w600 
                        : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.item.trailing != null) ...[
                SizedBox(width: AppleTheme.spacing8),
                widget.item.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Apple-style Sidebar Section Header
class AppleSidebarSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const AppleSidebarSectionHeader({
    Key? key,
    required this.title,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppleTheme.spacing12,
        right: AppleTheme.spacing12,
        top: AppleTheme.spacing16,
        bottom: AppleTheme.spacing8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: AppleTypography.caption1Bold(context).copyWith(
                color: AppleTheme.secondaryTextColor(context),
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Apple-style Sidebar Divider
class AppleSidebarDivider extends StatelessWidget {
  final EdgeInsets? margin;

  const AppleSidebarDivider({
    Key? key,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(
        horizontal: AppleTheme.spacing12,
        vertical: AppleTheme.spacing8,
      ),
      height: 0.5,
      color: AppleTheme.separatorColor(context),
    );
  }
}
