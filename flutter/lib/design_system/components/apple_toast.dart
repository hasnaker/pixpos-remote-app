import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../apple_theme.dart';
import '../apple_typography.dart';
import '../apple_animations.dart';

/// Toast type variants
enum AppleToastType {
  /// Success toast with green accent
  success,
  /// Error toast with red accent
  error,
  /// Warning toast with yellow accent
  warning,
  /// Info toast with blue accent
  info,
}

/// Toast position on screen
enum AppleToastPosition {
  top,
  bottom,
}

/// Apple-style Toast Component
/// 
/// A non-intrusive notification that slides in from top or bottom.
/// Features slide-in animation and success/error variants.
/// 
/// Requirements: 9.5, 15.3
class AppleToast extends StatefulWidget {
  final String message;
  final String? title;
  final AppleToastType type;
  final Duration duration;
  final VoidCallback? onDismiss;
  final IconData? icon;
  final AppleToastPosition position;
  final bool showProgress;

  const AppleToast({
    Key? key,
    required this.message,
    this.title,
    this.type = AppleToastType.info,
    this.duration = const Duration(seconds: 3),
    this.onDismiss,
    this.icon,
    this.position = AppleToastPosition.top,
    this.showProgress = false,
  }) : super(key: key);

  @override
  State<AppleToast> createState() => _AppleToastState();
}

class _AppleToastState extends State<AppleToast> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppleTheme.durationMedium,
      vsync: this,
    );

    // Requirement 15.3: Slide-in animation
    final slideBegin = widget.position == AppleToastPosition.top
        ? const Offset(0, -1)
        : const Offset(0, 1);
    
    _slideAnimation = Tween<Offset>(
      begin: slideBegin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
    _startDismissTimer();
  }

  void _startDismissTimer() {
    _dismissTimer = Timer(widget.duration, _dismiss);
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  Color get _accentColor {
    switch (widget.type) {
      case AppleToastType.success:
        return AppleTheme.systemGreen;
      case AppleToastType.error:
        return AppleTheme.systemRed;
      case AppleToastType.warning:
        return AppleTheme.systemYellow;
      case AppleToastType.info:
        return AppleTheme.primaryBlue;
    }
  }

  IconData get _defaultIcon {
    switch (widget.type) {
      case AppleToastType.success:
        return Icons.check_circle_rounded;
      case AppleToastType.error:
        return Icons.error_rounded;
      case AppleToastType.warning:
        return Icons.warning_rounded;
      case AppleToastType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = widget.icon ?? _defaultIcon;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: _dismiss,
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null && 
                details.primaryVelocity!.abs() > 100) {
              _dismiss();
            }
          },
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: AppleTheme.spacing16,
              vertical: AppleTheme.spacing8,
            ),
            decoration: BoxDecoration(
              color: isDark 
                ? AppleTheme.darkSurface.withOpacity(0.95)
                : AppleTheme.lightSurface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
              boxShadow: isDark 
                ? AppleTheme.shadowDark 
                : AppleTheme.shadowLight,
              border: Border.all(
                color: isDark 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(AppleTheme.spacing16),
                      child: Row(
                        children: [
                          // Icon with accent color
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _accentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
                            ),
                            child: Icon(
                              icon,
                              color: _accentColor,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: AppleTheme.spacing12),
                          
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.title != null) ...[
                                  Text(
                                    widget.title!,
                                    style: AppleTypography.subheadline(context).copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: AppleTheme.spacing2),
                                ],
                                Text(
                                  widget.message,
                                  style: AppleTypography.subheadline(context).copyWith(
                                    color: widget.title != null 
                                      ? AppleTheme.secondaryTextColor(context)
                                      : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Close button
                          GestureDetector(
                            onTap: _dismiss,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isDark 
                                  ? AppleTheme.darkTertiary 
                                  : AppleTheme.lightSecondary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: AppleTheme.secondaryTextColor(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Progress indicator
                    if (widget.showProgress)
                      _ToastProgressIndicator(
                        duration: widget.duration,
                        color: _accentColor,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}

/// Progress indicator for toast auto-dismiss
class _ToastProgressIndicator extends StatefulWidget {
  final Duration duration;
  final Color color;

  const _ToastProgressIndicator({
    required this.duration,
    required this.color,
  });

  @override
  State<_ToastProgressIndicator> createState() => _ToastProgressIndicatorState();
}

class _ToastProgressIndicatorState extends State<_ToastProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: 3,
          child: LinearProgressIndicator(
            value: 1 - _controller.value,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation(widget.color),
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

/// Toast manager for showing toasts globally
class AppleToastManager {
  static final AppleToastManager _instance = AppleToastManager._internal();
  factory AppleToastManager() => _instance;
  AppleToastManager._internal();

  OverlayEntry? _currentToast;
  final List<_ToastQueueItem> _queue = [];
  bool _isShowing = false;

  /// Shows a toast notification
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    AppleToastType type = AppleToastType.info,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
    AppleToastPosition position = AppleToastPosition.top,
    bool showProgress = false,
  }) {
    _instance._showToast(
      context,
      message: message,
      title: title,
      type: type,
      duration: duration,
      icon: icon,
      position: position,
      showProgress: showProgress,
    );
  }

  /// Shows a success toast
  static void success(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AppleToastType.success,
      duration: duration,
    );
  }

  /// Shows an error toast
  static void error(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AppleToastType.error,
      duration: duration,
    );
  }

  /// Shows a warning toast
  static void warning(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AppleToastType.warning,
      duration: duration,
    );
  }

  /// Shows an info toast
  static void info(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AppleToastType.info,
      duration: duration,
    );
  }

  /// Dismisses the current toast
  static void dismiss() {
    _instance._dismissCurrent();
  }

  void _showToast(
    BuildContext context, {
    required String message,
    String? title,
    required AppleToastType type,
    required Duration duration,
    IconData? icon,
    required AppleToastPosition position,
    required bool showProgress,
  }) {
    final item = _ToastQueueItem(
      context: context,
      message: message,
      title: title,
      type: type,
      duration: duration,
      icon: icon,
      position: position,
      showProgress: showProgress,
    );

    _queue.add(item);
    _processQueue();
  }

  void _processQueue() {
    if (_isShowing || _queue.isEmpty) return;

    _isShowing = true;
    final item = _queue.removeAt(0);
    
    final overlay = Overlay.of(item.context);

    _currentToast = OverlayEntry(
      builder: (context) {
        final topPadding = MediaQuery.of(item.context).padding.top;
        final bottomPadding = MediaQuery.of(item.context).padding.bottom;

        return Positioned(
          top: item.position == AppleToastPosition.top 
            ? topPadding + AppleTheme.spacing8 
            : null,
          bottom: item.position == AppleToastPosition.bottom 
            ? bottomPadding + AppleTheme.spacing8 
            : null,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Material(
              color: Colors.transparent,
              child: AppleToast(
                message: item.message,
                title: item.title,
                type: item.type,
                duration: item.duration,
                icon: item.icon,
                position: item.position,
                showProgress: item.showProgress,
                onDismiss: () {
                  _currentToast?.remove();
                  _currentToast = null;
                  _isShowing = false;
                  _processQueue();
                },
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_currentToast!);
  }

  void _dismissCurrent() {
    _currentToast?.remove();
    _currentToast = null;
    _isShowing = false;
    _processQueue();
  }
}

class _ToastQueueItem {
  final BuildContext context;
  final String message;
  final String? title;
  final AppleToastType type;
  final Duration duration;
  final IconData? icon;
  final AppleToastPosition position;
  final bool showProgress;

  _ToastQueueItem({
    required this.context,
    required this.message,
    this.title,
    required this.type,
    required this.duration,
    this.icon,
    required this.position,
    required this.showProgress,
  });
}

/// A compact toast for simple messages (like "Copied!")
/// Requirement 9.5: Toast notification with checkmark for ID copy
class AppleCompactToast extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final Duration duration;
  final VoidCallback? onDismiss;

  const AppleCompactToast({
    Key? key,
    required this.message,
    this.icon,
    this.iconColor,
    this.duration = const Duration(seconds: 2),
    this.onDismiss,
  }) : super(key: key);

  /// Shows a compact toast centered on screen
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? iconColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Center(
        child: AppleCompactToast(
          message: message,
          icon: icon,
          iconColor: iconColor,
          duration: duration,
          onDismiss: () => entry.remove(),
        ),
      ),
    );

    overlay.insert(entry);
  }

  /// Shows a "Copied!" toast with checkmark
  static void copied(BuildContext context) {
    show(
      context,
      message: 'Copied',
      icon: Icons.check_rounded,
      iconColor: AppleTheme.systemGreen,
    );
  }

  @override
  State<AppleCompactToast> createState() => _AppleCompactToastState();
}

class _AppleCompactToastState extends State<AppleCompactToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppleAnimations.springDuration,
      vsync: this,
    );

    // Use spring curve for bouncy effect (Requirement 15.2)
    _scaleAnimation = Tween<double>(
      begin: AppleAnimations.toastAppearScale,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack, // Spring-like bounce
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
    _dismissTimer = Timer(widget.duration, _dismiss);
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppleTheme.spacing20,
              vertical: AppleTheme.spacing12,
            ),
            decoration: BoxDecoration(
              color: isDark 
                ? AppleTheme.darkSurface.withOpacity(0.9)
                : AppleTheme.lightText.withOpacity(0.85),
              borderRadius: BorderRadius.circular(AppleTheme.radiusRound),
              boxShadow: AppleTheme.shadowDark,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: widget.iconColor ?? Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: AppleTheme.spacing8),
                ],
                Text(
                  widget.message,
                  style: AppleTypography.subheadline(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}
