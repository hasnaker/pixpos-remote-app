import 'package:flutter/material.dart';
import '../apple_theme.dart';
import '../apple_typography.dart';

/// Apple-style Segmented Control
/// 
/// A segmented control component following Apple's Human Interface Guidelines.
/// Features:
/// - Smooth sliding indicator animation (300ms)
/// - Support for icons and labels
/// - Hover states
/// - Light and dark mode support
class AppleSegmentedControl<T> extends StatefulWidget {
  final List<AppleSegment<T>> segments;
  final T selectedValue;
  final ValueChanged<T>? onValueChanged;
  final double? height;
  final EdgeInsets? padding;
  final bool isExpanded;

  const AppleSegmentedControl({
    Key? key,
    required this.segments,
    required this.selectedValue,
    this.onValueChanged,
    this.height,
    this.padding,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  State<AppleSegmentedControl<T>> createState() => _AppleSegmentedControlState<T>();
}

class _AppleSegmentedControlState<T> extends State<AppleSegmentedControl<T>> {
  int _hoveredIndex = -1;

  int get _selectedIndex {
    return widget.segments.indexWhere((s) => s.value == widget.selectedValue);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = widget.height ?? 32.0;
    
    return Container(
      height: height,
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isDark 
            ? AppleTheme.darkTertiary.withOpacity(0.5)
            : AppleTheme.lightSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = widget.isExpanded 
              ? constraints.maxWidth / widget.segments.length
              : null;
          
          return Stack(
            children: [
              // Sliding indicator
              AnimatedPositioned(
                duration: AppleTheme.durationMedium,
                curve: Curves.easeOutCubic,
                left: _selectedIndex >= 0 
                    ? (segmentWidth != null 
                        ? _selectedIndex * segmentWidth 
                        : _calculateIndicatorPosition(context))
                    : 0,
                top: 0,
                bottom: 0,
                child: AnimatedContainer(
                  duration: AppleTheme.durationMedium,
                  curve: Curves.easeOutCubic,
                  width: segmentWidth ?? _calculateSegmentWidth(context, _selectedIndex),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? AppleTheme.darkSecondary
                        : AppleTheme.lightSurface,
                    borderRadius: BorderRadius.circular(AppleTheme.radiusSmall - 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              // Segments
              Row(
                mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
                children: widget.segments.asMap().entries.map((entry) {
                  final index = entry.key;
                  final segment = entry.value;
                  final isSelected = segment.value == widget.selectedValue;
                  final isHovered = _hoveredIndex == index;
                  
                  return _SegmentWidget<T>(
                    segment: segment,
                    isSelected: isSelected,
                    isHovered: isHovered,
                    width: segmentWidth,
                    onTap: () {
                      if (segment.enabled) {
                        widget.onValueChanged?.call(segment.value);
                      }
                    },
                    onHover: (hovered) {
                      setState(() {
                        _hoveredIndex = hovered ? index : -1;
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  double _calculateIndicatorPosition(BuildContext context) {
    // This is a simplified calculation - in production you'd measure actual widths
    double position = 0;
    for (int i = 0; i < _selectedIndex; i++) {
      position += _calculateSegmentWidth(context, i);
    }
    return position;
  }

  double _calculateSegmentWidth(BuildContext context, int index) {
    // Estimate width based on content - in production you'd measure actual widths
    final segment = widget.segments[index];
    final hasIcon = segment.icon != null;
    final textLength = segment.label.length;
    
    double width = 16.0; // Base padding
    if (hasIcon) width += 24.0;
    width += textLength * 8.0; // Approximate character width
    
    return width.clamp(60.0, 200.0);
  }
}

class _SegmentWidget<T> extends StatelessWidget {
  final AppleSegment<T> segment;
  final bool isSelected;
  final bool isHovered;
  final double? width;
  final VoidCallback onTap;
  final ValueChanged<bool> onHover;

  const _SegmentWidget({
    Key? key,
    required this.segment,
    required this.isSelected,
    required this.isHovered,
    this.width,
    required this.onTap,
    required this.onHover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = segment.enabled;
    
    Color textColor;
    if (!isEnabled) {
      textColor = AppleTheme.secondaryTextColor(context).withOpacity(0.5);
    } else if (isSelected) {
      textColor = AppleTheme.textColor(context);
    } else {
      textColor = AppleTheme.secondaryTextColor(context);
    }

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: Container(
          width: width,
          padding: EdgeInsets.symmetric(
            horizontal: AppleTheme.spacing12,
            vertical: AppleTheme.spacing6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (segment.icon != null) ...[
                Icon(
                  segment.icon,
                  size: 16,
                  color: textColor,
                ),
                SizedBox(width: AppleTheme.spacing6),
              ],
              AnimatedDefaultTextStyle(
                duration: AppleTheme.durationFast,
                style: AppleTypography.footnote(context).copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(segment.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Represents a segment in the segmented control
class AppleSegment<T> {
  final T value;
  final String label;
  final IconData? icon;
  final bool enabled;

  const AppleSegment({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });
}

/// Apple-style Tab Bar using segmented control style
/// 
/// A tab bar component that uses the segmented control visual style.
class AppleTabBar extends StatelessWidget {
  final List<AppleTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;
  final double? height;
  final EdgeInsets? padding;

  const AppleTabBar({
    Key? key,
    required this.tabs,
    required this.selectedIndex,
    this.onTabSelected,
    this.height,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppleSegmentedControl<int>(
      segments: tabs.asMap().entries.map((entry) {
        return AppleSegment<int>(
          value: entry.key,
          label: entry.value.label,
          icon: entry.value.icon,
          enabled: entry.value.enabled,
        );
      }).toList(),
      selectedValue: selectedIndex,
      onValueChanged: onTabSelected,
      height: height,
      padding: padding,
      isExpanded: true,
    );
  }
}

/// Represents a tab item
class AppleTabItem {
  final String label;
  final IconData? icon;
  final bool enabled;

  const AppleTabItem({
    required this.label,
    this.icon,
    this.enabled = true,
  });
}
