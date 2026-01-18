import 'package:flutter/material.dart';
import '../apple_theme.dart';

/// Apple-style Mobile Tab Bar
/// 
/// A segmented control style tab bar for mobile with smooth transitions.
/// Follows Apple Human Interface Guidelines for touch targets (44px minimum).
class AppleMobileTabBar extends StatelessWidget {
  final int selectedIndex;
  final List<AppleMobileTab> tabs;
  final ValueChanged<int> onTabSelected;
  final EdgeInsets? padding;
  final double? height;

  const AppleMobileTabBar({
    Key? key,
    required this.selectedIndex,
    required this.tabs,
    required this.onTabSelected,
    this.padding,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: AppleTheme.spacing16,
        vertical: AppleTheme.spacing8,
      ),
      child: Container(
        height: height ?? AppleTheme.touchTargetMin,
        decoration: BoxDecoration(
          color: isDark ? AppleTheme.darkSecondary : AppleTheme.lightSecondary,
          borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
        ),
        padding: EdgeInsets.all(AppleTheme.spacing2),
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = index == selectedIndex;
            
            return Expanded(
              child: GestureDetector(
                onTap: () => onTabSelected(index),
                child: AnimatedContainer(
                  duration: AppleTheme.durationNormal,
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? (isDark ? AppleTheme.darkSurface : AppleTheme.lightSurface)
                      : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppleTheme.radiusSmall - 2),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ] : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (tab.icon != null) ...[
                          AnimatedDefaultTextStyle(
                            duration: AppleTheme.durationNormal,
                            style: TextStyle(
                              color: isSelected 
                                ? AppleTheme.primaryBlue
                                : (isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText),
                            ),
                            child: Icon(
                              tab.icon,
                              size: 16,
                              color: isSelected 
                                ? AppleTheme.primaryBlue
                                : (isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText),
                            ),
                          ),
                          SizedBox(width: AppleTheme.spacing4),
                        ],
                        AnimatedDefaultTextStyle(
                          duration: AppleTheme.durationNormal,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected 
                              ? (isDark ? AppleTheme.darkText : AppleTheme.lightText)
                              : (isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText),
                          ),
                          child: Text(tab.label),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Tab item for AppleMobileTabBar
class AppleMobileTab {
  final String label;
  final IconData? icon;

  const AppleMobileTab({
    required this.label,
    this.icon,
  });
}

/// Apple-style Page View with Tab Bar
/// 
/// Combines a tab bar with a page view for smooth page transitions.
class AppleMobileTabView extends StatefulWidget {
  final List<AppleMobileTab> tabs;
  final List<Widget> pages;
  final int initialIndex;
  final ValueChanged<int>? onPageChanged;

  const AppleMobileTabView({
    Key? key,
    required this.tabs,
    required this.pages,
    this.initialIndex = 0,
    this.onPageChanged,
  }) : super(key: key);

  @override
  State<AppleMobileTabView> createState() => _AppleMobileTabViewState();
}

class _AppleMobileTabViewState extends State<AppleMobileTabView> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    _pageController.animateToPage(
      index,
      duration: AppleTheme.durationMedium,
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    widget.onPageChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppleMobileTabBar(
          selectedIndex: _currentIndex,
          tabs: widget.tabs,
          onTabSelected: _onTabSelected,
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: BouncingScrollPhysics(),
            children: widget.pages,
          ),
        ),
      ],
    );
  }
}

/// Apple-style Navigation Bar (Top)
/// 
/// A navigation bar with large title support and smooth transitions.
class AppleMobileNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool largeTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AppleMobileNavBar({
    Key? key,
    required this.title,
    this.largeTitle = false,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(
    largeTitle ? AppleTheme.touchTargetMin + 52 : AppleTheme.touchTargetMin + AppleTheme.spacing16,
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppleTheme.darkSurface : AppleTheme.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppleTheme.darkSeparator : AppleTheme.lightSeparator,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: AppleTheme.touchTargetMin + AppleTheme.spacing16,
              child: Row(
                children: [
                  if (showBackButton || leading != null)
                    SizedBox(
                      width: AppleTheme.touchTargetMin + AppleTheme.spacing8,
                      child: leading ?? GestureDetector(
                        onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                        child: Container(
                          width: AppleTheme.touchTargetMin,
                          height: AppleTheme.touchTargetMin,
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppleTheme.primaryBlue,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  if (!largeTitle)
                    Expanded(
                      child: Center(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppleTheme.darkText : AppleTheme.lightText,
                          ),
                        ),
                      ),
                    ),
                  if (largeTitle)
                    Expanded(child: SizedBox()),
                  if (actions != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!.map((action) => SizedBox(
                        width: AppleTheme.touchTargetMin,
                        height: AppleTheme.touchTargetMin,
                        child: action,
                      )).toList(),
                    ),
                  SizedBox(width: AppleTheme.spacing8),
                ],
              ),
            ),
            if (largeTitle)
              Padding(
                padding: EdgeInsets.only(
                  left: AppleTheme.spacing16,
                  bottom: AppleTheme.spacing8,
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: isDark ? AppleTheme.darkText : AppleTheme.lightText,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Apple-style Animated Page Transition
/// 
/// Provides iOS-style page transitions with slide and fade effects.
class AppleMobilePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  AppleMobilePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);

            var fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Interval(0.0, 0.5, curve: Curves.easeIn),
            ));

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: AppleTheme.durationMedium,
          reverseTransitionDuration: AppleTheme.durationMedium,
        );
}
