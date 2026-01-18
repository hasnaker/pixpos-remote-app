import 'package:flutter/material.dart';
import '../apple_theme.dart';

/// Apple-style Skeleton Loading Component
/// 
/// A shimmer effect skeleton loader following Apple's design language.
/// Used to indicate loading states for content areas.
class AppleSkeleton extends StatefulWidget {
  /// Width of the skeleton (null for full width)
  final double? width;
  
  /// Height of the skeleton
  final double height;
  
  /// Border radius of the skeleton
  final double? borderRadius;
  
  /// Whether the skeleton is circular
  final bool isCircle;
  
  /// Whether to show shimmer animation
  final bool animate;

  const AppleSkeleton({
    Key? key,
    this.width,
    required this.height,
    this.borderRadius,
    this.isCircle = false,
    this.animate = true,
  }) : super(key: key);

  /// Creates a text line skeleton
  factory AppleSkeleton.text({
    double? width,
    double height = 16,
    bool animate = true,
  }) {
    return AppleSkeleton(
      width: width,
      height: height,
      borderRadius: AppleTheme.radiusSmall,
      animate: animate,
    );
  }

  /// Creates a circular avatar skeleton
  factory AppleSkeleton.circle({
    double size = 40,
    bool animate = true,
  }) {
    return AppleSkeleton(
      width: size,
      height: size,
      isCircle: true,
      animate: animate,
    );
  }

  /// Creates a rectangular card skeleton
  factory AppleSkeleton.card({
    double? width,
    double height = 120,
    bool animate = true,
  }) {
    return AppleSkeleton(
      width: width,
      height: height,
      borderRadius: AppleTheme.radiusMedium,
      animate: animate,
    );
  }

  /// Creates a button skeleton
  factory AppleSkeleton.button({
    double? width,
    double height = 44,
    bool animate = true,
  }) {
    return AppleSkeleton(
      width: width ?? 120,
      height: height,
      borderRadius: AppleTheme.radiusMedium,
      animate: animate,
    );
  }

  @override
  State<AppleSkeleton> createState() => _AppleSkeletonState();
}

class _AppleSkeletonState extends State<AppleSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AppleSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final baseColor = isDark
        ? AppleTheme.darkSecondary
        : AppleTheme.lightSecondary;
    final highlightColor = isDark
        ? AppleTheme.darkTertiary
        : AppleTheme.lightBackground;

    final effectiveRadius = widget.isCircle
        ? AppleTheme.radiusRound
        : (widget.borderRadius ?? AppleTheme.radiusSmall);

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(effectiveRadius),
            gradient: widget.animate
                ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      baseColor,
                      highlightColor,
                      baseColor,
                    ],
                    stops: [
                      (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                      _shimmerAnimation.value.clamp(0.0, 1.0),
                      (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                    ],
                  )
                : null,
            color: widget.animate ? null : baseColor,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Apple-style Skeleton List Item
/// 
/// A pre-built skeleton for list items with avatar, title, and subtitle.
class AppleSkeletonListItem extends StatelessWidget {
  /// Whether to show an avatar
  final bool showAvatar;
  
  /// Whether to show a subtitle
  final bool showSubtitle;
  
  /// Whether to show a trailing element
  final bool showTrailing;
  
  /// Height of the list item
  final double height;
  
  /// Padding around the content
  final EdgeInsets? padding;

  const AppleSkeletonListItem({
    Key? key,
    this.showAvatar = true,
    this.showSubtitle = true,
    this.showTrailing = false,
    this.height = 72,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: AppleTheme.spacing16,
        vertical: AppleTheme.spacing12,
      ),
      child: Row(
        children: [
          if (showAvatar) ...[
            AppleSkeleton.circle(size: 44),
            SizedBox(width: AppleTheme.spacing12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppleSkeleton.text(width: 140, height: 16),
                if (showSubtitle) ...[
                  SizedBox(height: AppleTheme.spacing8),
                  AppleSkeleton.text(width: 200, height: 14),
                ],
              ],
            ),
          ),
          if (showTrailing) ...[
            SizedBox(width: AppleTheme.spacing12),
            AppleSkeleton(
              width: 60,
              height: 24,
              borderRadius: AppleTheme.radiusSmall,
            ),
          ],
        ],
      ),
    );
  }
}

/// Apple-style Skeleton Card
/// 
/// A pre-built skeleton for card content with image and text.
class AppleSkeletonCard extends StatelessWidget {
  /// Width of the card
  final double? width;
  
  /// Height of the card
  final double height;
  
  /// Whether to show an image area
  final bool showImage;
  
  /// Height of the image area
  final double imageHeight;
  
  /// Number of text lines to show
  final int textLines;

  const AppleSkeletonCard({
    Key? key,
    this.width,
    this.height = 200,
    this.showImage = true,
    this.imageHeight = 120,
    this.textLines = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppleTheme.darkSurface : AppleTheme.lightSurface,
        borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
        boxShadow: AppleTheme.shadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showImage)
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppleTheme.radiusMedium),
              ),
              child: AppleSkeleton(
                height: imageHeight,
                borderRadius: 0,
              ),
            ),
          Padding(
            padding: EdgeInsets.all(AppleTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppleSkeleton.text(width: 160, height: 18),
                for (int i = 0; i < textLines; i++) ...[
                  SizedBox(height: AppleTheme.spacing8),
                  AppleSkeleton.text(
                    width: i == textLines - 1 ? 120 : null,
                    height: 14,
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


/// Apple-style Skeleton Peer Card
/// 
/// A pre-built skeleton specifically for peer/connection cards.
class AppleSkeletonPeerCard extends StatelessWidget {
  /// Whether to show in grid mode
  final bool isGridMode;

  const AppleSkeletonPeerCard({
    Key? key,
    this.isGridMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isGridMode) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppleTheme.darkSurface : AppleTheme.lightSurface,
          borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
          boxShadow: AppleTheme.shadow(context),
        ),
        padding: EdgeInsets.all(AppleTheme.spacing16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppleSkeleton.circle(size: 48),
            SizedBox(height: AppleTheme.spacing12),
            AppleSkeleton.text(width: 80, height: 16),
            SizedBox(height: AppleTheme.spacing8),
            AppleSkeleton.text(width: 100, height: 12),
          ],
        ),
      );
    }

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: isDark ? AppleTheme.darkSurface : AppleTheme.lightSurface,
        borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
        boxShadow: AppleTheme.shadow(context),
      ),
      padding: EdgeInsets.all(AppleTheme.spacing12),
      child: Row(
        children: [
          AppleSkeleton.circle(size: 44),
          SizedBox(width: AppleTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppleSkeleton.text(width: 120, height: 16),
                SizedBox(height: AppleTheme.spacing6),
                AppleSkeleton.text(width: 80, height: 12),
              ],
            ),
          ),
          AppleSkeleton(
            width: 8,
            height: 8,
            isCircle: true,
          ),
        ],
      ),
    );
  }
}

/// Apple-style Skeleton Settings Section
/// 
/// A pre-built skeleton for settings sections.
class AppleSkeletonSettingsSection extends StatelessWidget {
  /// Number of items in the section
  final int itemCount;
  
  /// Whether to show section header
  final bool showHeader;

  const AppleSkeletonSettingsSection({
    Key? key,
    this.itemCount = 3,
    this.showHeader = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppleTheme.spacing16,
              vertical: AppleTheme.spacing8,
            ),
            child: AppleSkeleton.text(width: 100, height: 12),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppleTheme.darkSurface : AppleTheme.lightSurface,
            borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
          ),
          child: Column(
            children: List.generate(itemCount, (index) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppleTheme.spacing16,
                      vertical: AppleTheme.spacing14,
                    ),
                    child: Row(
                      children: [
                        AppleSkeleton(
                          width: 28,
                          height: 28,
                          borderRadius: AppleTheme.radiusSmall,
                        ),
                        SizedBox(width: AppleTheme.spacing12),
                        Expanded(
                          child: AppleSkeleton.text(width: 140, height: 16),
                        ),
                        AppleSkeleton(
                          width: 50,
                          height: 28,
                          borderRadius: AppleTheme.radiusRound,
                        ),
                      ],
                    ),
                  ),
                  if (index < itemCount - 1)
                    Divider(
                      height: 1,
                      indent: AppleTheme.spacing56,
                      color: isDark
                          ? AppleTheme.darkSeparator
                          : AppleTheme.lightSeparator,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// Apple-style Skeleton Content Wrapper
/// 
/// Wraps content and shows skeleton while loading.
class AppleSkeletonWrapper extends StatelessWidget {
  /// Whether content is loading
  final bool isLoading;
  
  /// The actual content to show when not loading
  final Widget child;
  
  /// The skeleton to show while loading
  final Widget skeleton;
  
  /// Duration of the fade transition
  final Duration fadeDuration;

  const AppleSkeletonWrapper({
    Key? key,
    required this.isLoading,
    required this.child,
    required this.skeleton,
    this.fadeDuration = AppleTheme.durationMedium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: fadeDuration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: isLoading
          ? KeyedSubtree(
              key: const ValueKey('skeleton'),
              child: skeleton,
            )
          : KeyedSubtree(
              key: const ValueKey('content'),
              child: child,
            ),
    );
  }
}

/// Apple-style Skeleton List
/// 
/// A list of skeleton items for loading states.
class AppleSkeletonList extends StatelessWidget {
  /// Number of skeleton items to show
  final int itemCount;
  
  /// Builder for each skeleton item
  final Widget Function(BuildContext context, int index)? itemBuilder;
  
  /// Spacing between items
  final double spacing;
  
  /// Padding around the list
  final EdgeInsets? padding;
  
  /// Scroll direction
  final Axis scrollDirection;

  const AppleSkeletonList({
    Key? key,
    this.itemCount = 5,
    this.itemBuilder,
    this.spacing = 12,
    this.padding,
    this.scrollDirection = Axis.vertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? EdgeInsets.all(AppleTheme.spacing16);
    
    if (scrollDirection == Axis.horizontal) {
      return SizedBox(
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: effectivePadding,
          itemCount: itemCount,
          separatorBuilder: (_, __) => SizedBox(width: spacing),
          itemBuilder: (context, index) {
            return itemBuilder?.call(context, index) ??
                AppleSkeletonPeerCard(isGridMode: true);
          },
        ),
      );
    }

    return ListView.separated(
      padding: effectivePadding,
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: spacing),
      itemBuilder: (context, index) {
        return itemBuilder?.call(context, index) ??
            const AppleSkeletonListItem();
      },
    );
  }
}

/// Apple-style Skeleton Grid
/// 
/// A grid of skeleton items for loading states.
class AppleSkeletonGrid extends StatelessWidget {
  /// Number of skeleton items to show
  final int itemCount;
  
  /// Number of columns
  final int crossAxisCount;
  
  /// Spacing between items
  final double spacing;
  
  /// Padding around the grid
  final EdgeInsets? padding;
  
  /// Aspect ratio of each item
  final double childAspectRatio;

  const AppleSkeletonGrid({
    Key? key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.spacing = 12,
    this.padding,
    this.childAspectRatio = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding ?? EdgeInsets.all(AppleTheme.spacing16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const AppleSkeletonPeerCard(isGridMode: true);
      },
    );
  }
}
