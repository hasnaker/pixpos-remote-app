import 'package:flutter/material.dart';
import '../apple_theme.dart';
import '../apple_typography.dart';
import 'apple_card.dart';

/// Apple-styled Desktop Settings Page Layout
/// 
/// This provides the Apple design language styling for the desktop settings page,
/// including the sidebar navigation and content area.
class AppleDesktopSettingsLayout extends StatelessWidget {
  final Widget sidebar;
  final Widget content;
  final String title;
  final VoidCallback? onBack;

  const AppleDesktopSettingsLayout({
    Key? key,
    required this.sidebar,
    required this.content,
    required this.title,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppleTheme.darkBackground : AppleTheme.lightBackground,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: AppleTheme.sidebarWidth,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isDark),
                Expanded(child: sidebar),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Container(
              color: isDark ? AppleTheme.darkBackground : AppleTheme.lightBackground,
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      height: 62,
      padding: EdgeInsets.symmetric(horizontal: AppleTheme.spacing20),
      child: Row(
        children: [
          if (onBack != null) ...[
            IconButton(
              onPressed: onBack,
              icon: Icon(
                Icons.arrow_back,
                color: AppleTheme.primaryBlue,
              ),
              splashRadius: 20,
            ),
            SizedBox(width: AppleTheme.spacing8),
          ],
          Text(
            title,
            style: AppleTypography.title2(context).copyWith(
              color: AppleTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

/// Apple-styled Settings Tab Item
/// 
/// A single tab item in the settings sidebar.
class AppleSettingsTabItem extends StatefulWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const AppleSettingsTabItem({
    Key? key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    this.onTap,
  }) : super(key: key);

  @override
  State<AppleSettingsTabItem> createState() => _AppleSettingsTabItemState();
}

class _AppleSettingsTabItemState extends State<AppleSettingsTabItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppleTheme.durationFast,
          height: 42,
          margin: EdgeInsets.symmetric(
            horizontal: AppleTheme.spacing8,
            vertical: AppleTheme.spacing2,
          ),
          padding: EdgeInsets.symmetric(horizontal: AppleTheme.spacing12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppleTheme.primaryBlue.withOpacity(0.15)
                : (_isHovered
                    ? (isDark ? AppleTheme.darkSecondary : AppleTheme.lightBackground)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
          ),
          child: Row(
            children: [
              // Selection indicator
              AnimatedContainer(
                duration: AppleTheme.durationFast,
                width: 3,
                height: 24,
                margin: EdgeInsets.only(right: AppleTheme.spacing8),
                decoration: BoxDecoration(
                  color: widget.isSelected ? AppleTheme.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Icon
              Icon(
                widget.isSelected ? widget.selectedIcon : widget.icon,
                color: widget.isSelected 
                    ? AppleTheme.primaryBlue 
                    : (isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText),
                size: 20,
              ),
              SizedBox(width: AppleTheme.spacing10),
              // Label
              Expanded(
                child: Text(
                  widget.label,
                  style: AppleTypography.subheadline(context).copyWith(
                    color: widget.isSelected 
                        ? AppleTheme.primaryBlue 
                        : (isDark ? AppleTheme.darkText : AppleTheme.lightText),
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Apple-styled Settings Content Container
/// 
/// A container for settings content with proper padding and scrolling.
class AppleSettingsContent extends StatelessWidget {
  final List<Widget> children;
  final ScrollController? scrollController;
  final EdgeInsets? padding;

  const AppleSettingsContent({
    Key? key,
    required this.children,
    this.scrollController,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: padding ?? EdgeInsets.only(bottom: AppleTheme.spacing16),
      children: children,
    );
  }
}

/// Apple-styled Settings Card (for use in settings pages)
/// 
/// A card component that matches the Apple design language for settings.
class AppleSettingsGroupCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final List<Widget>? titleActions;
  final double? width;
  final EdgeInsets? margin;

  const AppleSettingsGroupCard({
    Key? key,
    required this.title,
    required this.children,
    this.titleActions,
    this.width,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Flexible(
          child: Container(
            width: width ?? 540,
            margin: margin ?? EdgeInsets.only(
              left: AppleTheme.spacing16,
              top: AppleTheme.spacing16,
            ),
            child: AppleCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppleTheme.spacing16,
                      right: AppleTheme.spacing16,
                      top: AppleTheme.spacing12,
                      bottom: AppleTheme.spacing12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppleTypography.title3(context),
                          ),
                        ),
                        if (titleActions != null) ...titleActions!,
                      ],
                    ),
                  ),
                  // Divider
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: isDark ? AppleTheme.darkSeparator : AppleTheme.lightSeparator,
                  ),
                  // Children with spacing
                  ...children.map((child) => Padding(
                    padding: EdgeInsets.only(
                      top: AppleTheme.spacing4,
                      right: AppleTheme.spacing16,
                    ),
                    child: child,
                  )),
                  SizedBox(height: AppleTheme.spacing12),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Apple-styled Lock Overlay
/// 
/// An overlay that blocks interaction when settings are locked.
class AppleSettingsLockOverlay extends StatelessWidget {
  final bool locked;
  final String unlockText;
  final VoidCallback? onUnlock;
  final Widget child;

  const AppleSettingsLockOverlay({
    Key? key,
    required this.locked,
    required this.unlockText,
    this.onUnlock,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (!locked) return child;
    
    return Column(
      children: [
        // Unlock button
        Container(
          margin: EdgeInsets.only(
            left: AppleTheme.spacing16,
            top: AppleTheme.spacing16,
            right: AppleTheme.spacing16,
          ),
          child: AppleCard(
            padding: EdgeInsets.symmetric(
              horizontal: AppleTheme.spacing16,
              vertical: AppleTheme.spacing12,
            ),
            onTap: onUnlock,
            child: Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  color: AppleTheme.primaryBlue,
                  size: 20,
                ),
                SizedBox(width: AppleTheme.spacing12),
                Expanded(
                  child: Text(
                    unlockText,
                    style: AppleTypography.body(context).copyWith(
                      color: AppleTheme.primaryBlue,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppleTheme.primaryBlue,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        // Locked content
        Expanded(
          child: Stack(
            children: [
              Opacity(
                opacity: 0.5,
                child: IgnorePointer(child: child),
              ),
              Container(
                color: (isDark ? AppleTheme.darkBackground : AppleTheme.lightBackground)
                    .withOpacity(0.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
