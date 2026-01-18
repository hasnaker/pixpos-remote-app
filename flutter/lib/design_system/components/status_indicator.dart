import 'package:flutter/material.dart';
import '../apple_theme.dart';

/// Connection status states
enum ConnectionStatus {
  /// Connected and active
  connected,
  /// Attempting to connect
  connecting,
  /// Not connected
  disconnected,
  /// Error state
  error,
  /// Away/Idle
  away,
}

/// Apple-style Status Indicator
/// 
/// A small dot indicator with optional pulse animation for status display.
class StatusIndicator extends StatefulWidget {
  final ConnectionStatus status;
  final double size;
  final bool showPulse;
  final bool showLabel;
  final String? customLabel;

  const StatusIndicator({
    Key? key,
    required this.status,
    this.size = 8,
    this.showPulse = true,
    this.showLabel = false,
    this.customLabel,
  }) : super(key: key);

  @override
  State<StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<StatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (_shouldPulse) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(StatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldPulse && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!_shouldPulse && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  Color get _color {
    switch (widget.status) {
      case ConnectionStatus.connected:
        return AppleTheme.systemGreen;
      case ConnectionStatus.connecting:
        return AppleTheme.systemYellow;
      case ConnectionStatus.disconnected:
        return AppleTheme.lightSecondaryText;
      case ConnectionStatus.error:
        return AppleTheme.systemRed;
      case ConnectionStatus.away:
        return AppleTheme.systemOrange;
    }
  }

  String get _label {
    if (widget.customLabel != null) return widget.customLabel!;
    switch (widget.status) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.error:
        return 'Error';
      case ConnectionStatus.away:
        return 'Away';
    }
  }

  bool get _shouldPulse {
    return widget.showPulse &&
        (widget.status == ConnectionStatus.connecting ||
            widget.status == ConnectionStatus.connected);
  }

  @override
  Widget build(BuildContext context) {
    final indicator = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulse ring
            if (_shouldPulse)
              Container(
                width: widget.size * _pulseAnimation.value,
                height: widget.size * _pulseAnimation.value,
                decoration: BoxDecoration(
                  color: _color.withOpacity(_opacityAnimation.value),
                  shape: BoxShape.circle,
                ),
              ),
            // Main dot
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _color.withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (!widget.showLabel) {
      return SizedBox(
        width: widget.size * 2,
        height: widget.size * 2,
        child: Center(child: indicator),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size * 2,
          height: widget.size * 2,
          child: Center(child: indicator),
        ),
        SizedBox(width: AppleTheme.spacing8),
        Text(
          _label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _color,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Apple-style Badge
/// 
/// A pill-shaped badge for counts and labels.
class AppleBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final bool isSmall;

  const AppleBadge({
    Key? key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.isSmall = false,
  }) : super(key: key);

  /// Creates a count badge (e.g., notification count)
  factory AppleBadge.count(int count, {bool isSmall = false}) {
    return AppleBadge(
      text: count > 99 ? '99+' : count.toString(),
      backgroundColor: AppleTheme.systemRed,
      textColor: Colors.white,
      isSmall: isSmall,
    );
  }

  /// Creates a status badge
  factory AppleBadge.status(String text, {Color? color}) {
    return AppleBadge(
      text: text,
      backgroundColor: color ?? AppleTheme.primaryBlue,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppleTheme.primaryBlue;
    final effectiveTextColor = textColor ?? Colors.white;
    final effectiveFontSize = fontSize ?? (isSmall ? 10.0 : 12.0);
    final padding = isSmall
        ? EdgeInsets.symmetric(horizontal: 6, vertical: 2)
        : EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(AppleTheme.radiusRound),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: effectiveFontSize,
          fontWeight: FontWeight.w600,
          color: effectiveTextColor,
        ),
      ),
    );
  }
}

/// Apple-style Online Status with Avatar
class OnlineStatusAvatar extends StatelessWidget {
  final Widget avatar;
  final ConnectionStatus status;
  final double size;
  final double indicatorSize;

  const OnlineStatusAvatar({
    Key? key,
    required this.avatar,
    required this.status,
    this.size = 40,
    this.indicatorSize = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + indicatorSize / 2,
      height: size + indicatorSize / 2,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: SizedBox(
              width: size,
              height: size,
              child: avatar,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: StatusIndicator(
                status: status,
                size: indicatorSize - 4,
                showPulse: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
