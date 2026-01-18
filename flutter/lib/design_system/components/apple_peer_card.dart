import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../apple_theme.dart';
import '../apple_typography.dart';
import 'apple_card.dart';
import 'status_indicator.dart';

/// Apple-style Peer Card for connection list
/// 
/// A modern peer card with Apple design language, status indicator,
/// and smooth hover/press animations.
class ApplePeerCard extends StatefulWidget {
  final String id;
  final String? alias;
  final String? hostname;
  final String? username;
  final String platform;
  final bool isOnline;
  final List<String> tags;
  final String? note;
  final bool isSelected;
  final bool showCheckbox;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onMorePressed;
  final Widget? platformIcon;

  const ApplePeerCard({
    Key? key,
    required this.id,
    this.alias,
    this.hostname,
    this.username,
    required this.platform,
    this.isOnline = false,
    this.tags = const [],
    this.note,
    this.isSelected = false,
    this.showCheckbox = false,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onMorePressed,
    this.platformIcon,
  }) : super(key: key);

  @override
  State<ApplePeerCard> createState() => _ApplePeerCardState();
}

class _ApplePeerCardState extends State<ApplePeerCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppleTheme.durationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _displayName {
    if (widget.alias != null && widget.alias!.isNotEmpty) {
      return widget.alias!;
    }
    return _formatId(widget.id);
  }

  String get _subtitle {
    final parts = <String>[];
    if (widget.username != null && widget.username!.isNotEmpty) {
      parts.add(widget.username!);
    }
    if (widget.hostname != null && widget.hostname!.isNotEmpty) {
      if (parts.isNotEmpty) {
        parts.add('@${widget.hostname}');
      } else {
        parts.add(widget.hostname!);
      }
    }
    return parts.join('');
  }

  String _formatId(String id) {
    // Format ID with spaces for readability (e.g., "123 456 789")
    if (id.length <= 3) return id;
    final buffer = StringBuffer();
    for (int i = 0; i < id.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(id[i]);
    }
    return buffer.toString();
  }

  Color _getPlatformColor() {
    // Generate a consistent color based on platform and id
    final hash = '${widget.id}${widget.platform}'.hashCode;
    final hue = (hash % 360).abs().toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.5, 0.6).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final platformColor = _getPlatformColor();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        onLongPress: widget.onLongPress,
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _controller.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: AnimatedContainer(
            duration: AppleTheme.durationNormal,
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: _getBackgroundColor(isDark),
              borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
              boxShadow: isDark ? AppleTheme.shadowDark : AppleTheme.shadowLight,
              border: widget.isSelected
                  ? Border.all(color: AppleTheme.primaryBlue, width: 2)
                  : Border.all(
                      color: isDark
                          ? AppleTheme.darkTertiary
                          : Colors.transparent,
                      width: 0.5,
                    ),
            ),
            transform: _isHovered
                ? (Matrix4.identity()..translate(0.0, -2.0))
                : Matrix4.identity(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Platform header with icon
                  _buildPlatformHeader(platformColor),
                  // Content section
                  _buildContent(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDark) {
    if (_isPressed) {
      return isDark
          ? AppleTheme.darkSecondary.withOpacity(0.8)
          : AppleTheme.lightBackground.withOpacity(0.8);
    }
    if (_isHovered) {
      return isDark ? AppleTheme.darkSecondary : AppleTheme.lightBackground;
    }
    return isDark ? AppleTheme.darkSurface : AppleTheme.lightSurface;
  }

  Widget _buildPlatformHeader(Color platformColor) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: platformColor.withOpacity(0.8),
      ),
      child: Stack(
        children: [
          // Platform icon centered
          Center(
            child: widget.platformIcon ??
                Icon(
                  _getPlatformIcon(),
                  size: 48,
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
          // Tags indicator (top right)
          if (widget.tags.isNotEmpty)
            Positioned(
              top: AppleTheme.spacing8,
              right: AppleTheme.spacing8,
              child: _buildTagsIndicator(),
            ),
          // Note indicator (bottom left)
          if (widget.note != null && widget.note!.isNotEmpty)
            Positioned(
              bottom: AppleTheme.spacing8,
              left: AppleTheme.spacing8,
              child: Tooltip(
                message: widget.note!,
                child: Icon(
                  Icons.note_outlined,
                  size: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTagsIndicator() {
    final displayTags = widget.tags.take(3).toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: displayTags.map((tag) {
        return Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            color: _getTagColor(tag),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
        );
      }).toList(),
    );
  }

  Color _getTagColor(String tag) {
    final hash = tag.hashCode;
    final hue = (hash % 360).abs().toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
  }

  IconData _getPlatformIcon() {
    switch (widget.platform.toLowerCase()) {
      case 'windows':
        return Icons.desktop_windows;
      case 'macos':
      case 'mac':
        return Icons.laptop_mac;
      case 'linux':
        return Icons.computer;
      case 'android':
        return Icons.phone_android;
      case 'ios':
        return Icons.phone_iphone;
      default:
        return Icons.devices;
    }
  }

  Widget _buildContent(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppleTheme.spacing12),
      child: Row(
        children: [
          // Status indicator
          StatusIndicator(
            status: widget.isOnline
                ? ConnectionStatus.connected
                : ConnectionStatus.disconnected,
            size: AppleTheme.statusIndicatorSize,
            showPulse: widget.isOnline,
          ),
          SizedBox(width: AppleTheme.spacing8),
          // Name and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _displayName,
                  style: AppleTypography.headline(context),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (_subtitle.isNotEmpty) ...[
                  SizedBox(height: AppleTheme.spacing2),
                  Text(
                    _subtitle,
                    style: AppleTypography.caption1(context).copyWith(
                      color: AppleTheme.secondaryTextColor(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),
          // Checkbox or more button
          if (widget.showCheckbox)
            _buildCheckbox(isDark)
          else if (widget.onMorePressed != null)
            _buildMoreButton(isDark),
        ],
      ),
    );
  }

  Widget _buildCheckbox(bool isDark) {
    return AnimatedContainer(
      duration: AppleTheme.durationFast,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: widget.isSelected
            ? AppleTheme.primaryBlue
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: widget.isSelected
              ? AppleTheme.primaryBlue
              : (isDark ? AppleTheme.darkTertiary : AppleTheme.lightTertiary),
          width: 2,
        ),
      ),
      child: widget.isSelected
          ? Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }

  Widget _buildMoreButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppleTheme.radiusRound),
        onTap: widget.onMorePressed,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _isHovered
                ? (isDark
                    ? AppleTheme.darkTertiary.withOpacity(0.5)
                    : AppleTheme.lightSecondary.withOpacity(0.5))
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.more_horiz,
            size: 20,
            color: AppleTheme.secondaryTextColor(context),
          ),
        ),
      ),
    );
  }
}


/// Apple-style Peer List Item for list view
/// 
/// A compact list item with 60px minimum height, status indicator,
/// and hover states.
class ApplePeerListItem extends StatefulWidget {
  final String id;
  final String? alias;
  final String? hostname;
  final String? username;
  final String platform;
  final bool isOnline;
  final List<String> tags;
  final String? note;
  final bool isSelected;
  final bool showCheckbox;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onMorePressed;
  final Widget? platformIcon;
  final bool showSeparator;

  const ApplePeerListItem({
    Key? key,
    required this.id,
    this.alias,
    this.hostname,
    this.username,
    required this.platform,
    this.isOnline = false,
    this.tags = const [],
    this.note,
    this.isSelected = false,
    this.showCheckbox = false,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onMorePressed,
    this.platformIcon,
    this.showSeparator = true,
  }) : super(key: key);

  @override
  State<ApplePeerListItem> createState() => _ApplePeerListItemState();
}

class _ApplePeerListItemState extends State<ApplePeerListItem> {
  bool _isHovered = false;
  bool _isPressed = false;

  String get _displayName {
    if (widget.alias != null && widget.alias!.isNotEmpty) {
      return widget.alias!;
    }
    return _formatId(widget.id);
  }

  String get _subtitle {
    final parts = <String>[];
    if (widget.username != null && widget.username!.isNotEmpty) {
      parts.add(widget.username!);
    }
    if (widget.hostname != null && widget.hostname!.isNotEmpty) {
      if (parts.isNotEmpty) {
        parts.add('@${widget.hostname}');
      } else {
        parts.add(widget.hostname!);
      }
    }
    return parts.join('');
  }

  String _formatId(String id) {
    if (id.length <= 3) return id;
    final buffer = StringBuffer();
    for (int i = 0; i < id.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(id[i]);
    }
    return buffer.toString();
  }

  Color _getPlatformColor() {
    final hash = '${widget.id}${widget.platform}'.hashCode;
    final hue = (hash % 360).abs().toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.5, 0.6).toColor();
  }

  IconData _getPlatformIcon() {
    switch (widget.platform.toLowerCase()) {
      case 'windows':
        return Icons.desktop_windows;
      case 'macos':
      case 'mac':
        return Icons.laptop_mac;
      case 'linux':
        return Icons.computer;
      case 'android':
        return Icons.phone_android;
      case 'ios':
        return Icons.phone_iphone;
      default:
        return Icons.devices;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final platformColor = _getPlatformColor();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            onDoubleTap: widget.onDoubleTap,
            onLongPress: widget.onLongPress,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedContainer(
              duration: AppleTheme.durationFast,
              constraints: BoxConstraints(minHeight: AppleTheme.listItemMinHeight),
              padding: EdgeInsets.symmetric(
                horizontal: AppleTheme.spacing16,
                vertical: AppleTheme.spacing12,
              ),
              decoration: BoxDecoration(
                color: _getBackgroundColor(isDark),
                borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
                border: widget.isSelected
                    ? Border.all(color: AppleTheme.primaryBlue, width: 2)
                    : null,
              ),
              child: Row(
                children: [
                  // Platform icon with color background
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: platformColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
                    ),
                    child: Center(
                      child: widget.platformIcon ??
                          Icon(
                            _getPlatformIcon(),
                            size: 24,
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ),
                  SizedBox(width: AppleTheme.spacing12),
                  // Status indicator
                  StatusIndicator(
                    status: widget.isOnline
                        ? ConnectionStatus.connected
                        : ConnectionStatus.disconnected,
                    size: AppleTheme.statusIndicatorSize,
                    showPulse: widget.isOnline,
                  ),
                  SizedBox(width: AppleTheme.spacing8),
                  // Name and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _displayName,
                          style: AppleTypography.headline(context),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        if (_subtitle.isNotEmpty) ...[
                          SizedBox(height: AppleTheme.spacing2),
                          Text(
                            _subtitle,
                            style: AppleTypography.caption1(context).copyWith(
                              color: AppleTheme.secondaryTextColor(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Note indicator
                  if (widget.note != null && widget.note!.isNotEmpty) ...[
                    SizedBox(width: AppleTheme.spacing8),
                    Tooltip(
                      message: widget.note!,
                      child: Icon(
                        Icons.note_outlined,
                        size: 16,
                        color: AppleTheme.secondaryTextColor(context),
                      ),
                    ),
                  ],
                  // Tags indicator
                  if (widget.tags.isNotEmpty) ...[
                    SizedBox(width: AppleTheme.spacing8),
                    _buildTagsIndicator(),
                  ],
                  SizedBox(width: AppleTheme.spacing8),
                  // Checkbox or more button
                  if (widget.showCheckbox)
                    _buildCheckbox(isDark)
                  else if (widget.onMorePressed != null)
                    _buildMoreButton(isDark),
                ],
              ),
            ),
          ),
        ),
        // Separator line
        if (widget.showSeparator)
          Container(
            margin: EdgeInsets.only(left: AppleTheme.spacing16 + 40 + AppleTheme.spacing12),
            height: 0.5,
            color: AppleTheme.separatorColor(context),
          ),
      ],
    );
  }

  Color _getBackgroundColor(bool isDark) {
    if (_isPressed) {
      return isDark
          ? AppleTheme.darkSecondary.withOpacity(0.8)
          : AppleTheme.lightBackground.withOpacity(0.8);
    }
    if (_isHovered) {
      return isDark
          ? AppleTheme.darkSecondary.withOpacity(0.5)
          : AppleTheme.lightBackground.withOpacity(0.5);
    }
    return Colors.transparent;
  }

  Widget _buildTagsIndicator() {
    final displayTags = widget.tags.take(3).toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: displayTags.map((tag) {
        return Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            color: _getTagColor(tag),
            shape: BoxShape.circle,
          ),
        );
      }).toList(),
    );
  }

  Color _getTagColor(String tag) {
    final hash = tag.hashCode;
    final hue = (hash % 360).abs().toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
  }

  Widget _buildCheckbox(bool isDark) {
    return AnimatedContainer(
      duration: AppleTheme.durationFast,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: widget.isSelected ? AppleTheme.primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: widget.isSelected
              ? AppleTheme.primaryBlue
              : (isDark ? AppleTheme.darkTertiary : AppleTheme.lightTertiary),
          width: 2,
        ),
      ),
      child: widget.isSelected
          ? Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }

  Widget _buildMoreButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppleTheme.radiusRound),
        onTap: widget.onMorePressed,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _isHovered
                ? (isDark
                    ? AppleTheme.darkTertiary.withOpacity(0.5)
                    : AppleTheme.lightSecondary.withOpacity(0.5))
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.more_horiz,
            size: 20,
            color: AppleTheme.secondaryTextColor(context),
          ),
        ),
      ),
    );
  }
}

/// Apple-style Peer Tile for tile view (compact grid)
/// 
/// A compact tile view with minimal height for dense layouts.
class ApplePeerTile extends StatefulWidget {
  final String id;
  final String? alias;
  final String? hostname;
  final String? username;
  final String platform;
  final bool isOnline;
  final List<String> tags;
  final bool isSelected;
  final bool showCheckbox;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onMorePressed;
  final Widget? platformIcon;

  const ApplePeerTile({
    Key? key,
    required this.id,
    this.alias,
    this.hostname,
    this.username,
    required this.platform,
    this.isOnline = false,
    this.tags = const [],
    this.isSelected = false,
    this.showCheckbox = false,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onMorePressed,
    this.platformIcon,
  }) : super(key: key);

  @override
  State<ApplePeerTile> createState() => _ApplePeerTileState();
}

class _ApplePeerTileState extends State<ApplePeerTile> {
  bool _isHovered = false;
  bool _isPressed = false;

  String get _displayName {
    if (widget.alias != null && widget.alias!.isNotEmpty) {
      return widget.alias!;
    }
    return _formatId(widget.id);
  }

  String _formatId(String id) {
    if (id.length <= 3) return id;
    final buffer = StringBuffer();
    for (int i = 0; i < id.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(id[i]);
    }
    return buffer.toString();
  }

  Color _getPlatformColor() {
    final hash = '${widget.id}${widget.platform}'.hashCode;
    final hue = (hash % 360).abs().toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.5, 0.6).toColor();
  }

  IconData _getPlatformIcon() {
    switch (widget.platform.toLowerCase()) {
      case 'windows':
        return Icons.desktop_windows;
      case 'macos':
      case 'mac':
        return Icons.laptop_mac;
      case 'linux':
        return Icons.computer;
      case 'android':
        return Icons.phone_android;
      case 'ios':
        return Icons.phone_iphone;
      default:
        return Icons.devices;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final platformColor = _getPlatformColor();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        onLongPress: widget.onLongPress,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: AppleTheme.durationFast,
          height: 42,
          padding: EdgeInsets.symmetric(
            horizontal: AppleTheme.spacing12,
            vertical: AppleTheme.spacing8,
          ),
          decoration: BoxDecoration(
            color: _getBackgroundColor(isDark),
            borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
            border: widget.isSelected
                ? Border.all(color: AppleTheme.primaryBlue, width: 2)
                : Border.all(
                    color: isDark
                        ? AppleTheme.darkTertiary.withOpacity(0.5)
                        : AppleTheme.lightSecondary.withOpacity(0.5),
                    width: 0.5,
                  ),
          ),
          child: Row(
            children: [
              // Platform icon
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: platformColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(AppleTheme.radiusXSmall),
                ),
                child: Center(
                  child: widget.platformIcon ??
                      Icon(
                        _getPlatformIcon(),
                        size: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
              ),
              SizedBox(width: AppleTheme.spacing8),
              // Status indicator
              StatusIndicator(
                status: widget.isOnline
                    ? ConnectionStatus.connected
                    : ConnectionStatus.disconnected,
                size: 6,
                showPulse: widget.isOnline,
              ),
              SizedBox(width: AppleTheme.spacing6),
              // Name
              Expanded(
                child: Text(
                  _displayName,
                  style: AppleTypography.subheadline(context),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              // Tags indicator
              if (widget.tags.isNotEmpty) ...[
                SizedBox(width: AppleTheme.spacing4),
                _buildTagsIndicator(),
              ],
              // Checkbox or more button
              if (widget.showCheckbox)
                _buildCheckbox(isDark)
              else if (widget.onMorePressed != null)
                _buildMoreButton(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDark) {
    if (_isPressed) {
      return isDark
          ? AppleTheme.darkSecondary.withOpacity(0.8)
          : AppleTheme.lightBackground.withOpacity(0.8);
    }
    if (_isHovered) {
      return isDark
          ? AppleTheme.darkSecondary.withOpacity(0.5)
          : AppleTheme.lightBackground.withOpacity(0.5);
    }
    return isDark ? AppleTheme.darkSurface : AppleTheme.lightSurface;
  }

  Widget _buildTagsIndicator() {
    final displayTags = widget.tags.take(2).toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: displayTags.map((tag) {
        return Container(
          width: 6,
          height: 6,
          margin: EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            color: _getTagColor(tag),
            shape: BoxShape.circle,
          ),
        );
      }).toList(),
    );
  }

  Color _getTagColor(String tag) {
    final hash = tag.hashCode;
    final hue = (hash % 360).abs().toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
  }

  Widget _buildCheckbox(bool isDark) {
    return Container(
      width: 20,
      height: 20,
      margin: EdgeInsets.only(left: AppleTheme.spacing4),
      decoration: BoxDecoration(
        color: widget.isSelected ? AppleTheme.primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: widget.isSelected
              ? AppleTheme.primaryBlue
              : (isDark ? AppleTheme.darkTertiary : AppleTheme.lightTertiary),
          width: 1.5,
        ),
      ),
      child: widget.isSelected
          ? Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }

  Widget _buildMoreButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppleTheme.radiusRound),
        onTap: widget.onMorePressed,
        child: Container(
          width: 24,
          height: 24,
          margin: EdgeInsets.only(left: AppleTheme.spacing4),
          child: Icon(
            Icons.more_horiz,
            size: 16,
            color: AppleTheme.secondaryTextColor(context),
          ),
        ),
      ),
    );
  }
}
