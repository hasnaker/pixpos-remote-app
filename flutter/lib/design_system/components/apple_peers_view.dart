import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../apple_theme.dart';
import '../apple_typography.dart';

/// View type for peer list display
enum ApplePeerViewType {
  /// Grid view with cards (2-4 columns)
  grid,
  /// List view with 60px minimum height items
  list,
  /// Compact tile view
  tile,
}

/// Apple-style Peers View Container
/// 
/// A container for displaying peer cards in grid, list, or tile view
/// with proper spacing, separators, and hover states.
class ApplePeersView extends StatelessWidget {
  final ApplePeerViewType viewType;
  final List<Widget> children;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final int gridColumns;
  final bool showEmptyState;
  final String emptyMessage;
  final IconData emptyIcon;

  const ApplePeersView({
    Key? key,
    required this.viewType,
    required this.children,
    this.scrollController,
    this.padding,
    this.gridColumns = 3,
    this.showEmptyState = true,
    this.emptyMessage = 'No connections found',
    this.emptyIcon = Icons.devices_other,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty && showEmptyState) {
      return _buildEmptyState(context);
    }

    switch (viewType) {
      case ApplePeerViewType.grid:
        return _buildGridView(context);
      case ApplePeerViewType.list:
        return _buildListView(context);
      case ApplePeerViewType.tile:
        return _buildTileView(context);
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            emptyIcon,
            size: 64,
            color: AppleTheme.secondaryTextColor(context).withOpacity(0.5),
          ),
          SizedBox(height: AppleTheme.spacing16),
          Text(
            emptyMessage,
            style: AppleTypography.body(context).copyWith(
              color: AppleTheme.secondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(BuildContext context) {
    final effectivePadding = padding ?? EdgeInsets.all(AppleTheme.spacing16);
    
    return GridView.builder(
      controller: scrollController,
      padding: effectivePadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridColumns,
        mainAxisSpacing: AppleTheme.spacing12,
        crossAxisSpacing: AppleTheme.spacing12,
        childAspectRatio: 220 / 140, // Card aspect ratio
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  Widget _buildListView(BuildContext context) {
    final effectivePadding = padding ?? EdgeInsets.symmetric(
      horizontal: AppleTheme.spacing16,
      vertical: AppleTheme.spacing8,
    );
    
    return ListView.builder(
      controller: scrollController,
      padding: effectivePadding,
      itemCount: children.length,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(
          bottom: index < children.length - 1 ? AppleTheme.spacing4 : 0,
        ),
        child: children[index],
      ),
    );
  }

  Widget _buildTileView(BuildContext context) {
    final effectivePadding = padding ?? EdgeInsets.all(AppleTheme.spacing16);
    
    return GridView.builder(
      controller: scrollController,
      padding: effectivePadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridColumns,
        mainAxisSpacing: AppleTheme.spacing8,
        crossAxisSpacing: AppleTheme.spacing8,
        childAspectRatio: 220 / 42, // Tile aspect ratio
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Apple-style View Type Selector
/// 
/// A segmented control for switching between grid, list, and tile views.
class ApplePeerViewSelector extends StatelessWidget {
  final ApplePeerViewType selectedType;
  final ValueChanged<ApplePeerViewType> onChanged;
  final bool showTileOption;

  const ApplePeerViewSelector({
    Key? key,
    required this.selectedType,
    required this.onChanged,
    this.showTileOption = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppleTheme.darkSecondary : AppleTheme.lightSecondary,
        borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
      ),
      padding: EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(
            context,
            ApplePeerViewType.grid,
            Icons.grid_view_rounded,
            'Grid',
          ),
          _buildOption(
            context,
            ApplePeerViewType.list,
            Icons.view_list_rounded,
            'List',
          ),
          if (showTileOption)
            _buildOption(
              context,
              ApplePeerViewType.tile,
              Icons.view_agenda_rounded,
              'Tile',
            ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    ApplePeerViewType type,
    IconData icon,
    String tooltip,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedType == type;
    
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () => onChanged(type),
        child: AnimatedContainer(
          duration: AppleTheme.durationFast,
          padding: EdgeInsets.symmetric(
            horizontal: AppleTheme.spacing12,
            vertical: AppleTheme.spacing6,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppleTheme.darkSurface : AppleTheme.lightSurface)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppleTheme.radiusSmall - 2),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isSelected
                ? AppleTheme.primaryBlue
                : AppleTheme.secondaryTextColor(context),
          ),
        ),
      ),
    );
  }
}

/// Apple-style Peer List Section Header
/// 
/// A section header for grouping peers in the list view.
class ApplePeerSectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final Widget? trailing;

  const ApplePeerSectionHeader({
    Key? key,
    required this.title,
    this.count,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppleTheme.spacing16,
        right: AppleTheme.spacing16,
        top: AppleTheme.spacing16,
        bottom: AppleTheme.spacing8,
      ),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: AppleTypography.footnoteBold(context).copyWith(
              color: AppleTheme.secondaryTextColor(context),
              letterSpacing: 0.5,
            ),
          ),
          if (count != null) ...[
            SizedBox(width: AppleTheme.spacing8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppleTheme.spacing8,
                vertical: AppleTheme.spacing2,
              ),
              decoration: BoxDecoration(
                color: AppleTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppleTheme.radiusRound),
              ),
              child: Text(
                count.toString(),
                style: AppleTypography.caption1Bold(context).copyWith(
                  color: AppleTheme.primaryBlue,
                ),
              ),
            ),
          ],
          Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Apple-style Peer List Separator
/// 
/// A separator line with proper inset for list views.
class ApplePeerSeparator extends StatelessWidget {
  final double indent;

  const ApplePeerSeparator({
    Key? key,
    this.indent = 68, // 16 + 40 (icon) + 12 (spacing)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: indent),
      height: 0.5,
      color: AppleTheme.separatorColor(context),
    );
  }
}

/// Apple-style Responsive Grid Delegate
/// 
/// A grid delegate that automatically adjusts columns based on available width.
class AppleResponsiveGridDelegate extends SliverGridDelegate {
  final double minCrossAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  const AppleResponsiveGridDelegate({
    this.minCrossAxisExtent = 220,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.childAspectRatio = 220 / 140,
  });

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final crossAxisCount = (constraints.crossAxisExtent / minCrossAxisExtent)
        .floor()
        .clamp(2, 4);
    final usableCrossAxisExtent = constraints.crossAxisExtent -
        crossAxisSpacing * (crossAxisCount - 1);
    final childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    final childMainAxisExtent = childCrossAxisExtent / childAspectRatio;

    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(AppleResponsiveGridDelegate oldDelegate) {
    return oldDelegate.minCrossAxisExtent != minCrossAxisExtent ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.childAspectRatio != childAspectRatio;
  }
}
