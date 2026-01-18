import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../apple_theme.dart';

/// Apple-style Circular Progress Indicator
/// 
/// A customizable circular progress indicator following Apple's design language.
/// Supports both determinate and indeterminate states with smooth animations.
class AppleProgressIndicator extends StatefulWidget {
  /// The progress value (0.0 to 1.0). If null, shows indeterminate animation.
  final double? value;
  
  /// The size of the indicator
  final double size;
  
  /// The stroke width of the progress arc
  final double strokeWidth;
  
  /// The color of the progress indicator (defaults to accent blue)
  final Color? color;
  
  /// The background track color
  final Color? trackColor;
  
  /// Whether to show the percentage text in the center
  final bool showPercentage;
  
  /// Custom label to show instead of percentage
  final String? label;

  const AppleProgressIndicator({
    Key? key,
    this.value,
    this.size = 32,
    this.strokeWidth = 3,
    this.color,
    this.trackColor,
    this.showPercentage = false,
    this.label,
  }) : super(key: key);

  /// Creates a small progress indicator (20px)
  factory AppleProgressIndicator.small({
    double? value,
    Color? color,
  }) {
    return AppleProgressIndicator(
      value: value,
      size: 20,
      strokeWidth: 2,
      color: color,
    );
  }

  /// Creates a medium progress indicator (32px)
  factory AppleProgressIndicator.medium({
    double? value,
    Color? color,
    bool showPercentage = false,
  }) {
    return AppleProgressIndicator(
      value: value,
      size: 32,
      strokeWidth: 3,
      color: color,
      showPercentage: showPercentage,
    );
  }

  /// Creates a large progress indicator (48px)
  factory AppleProgressIndicator.large({
    double? value,
    Color? color,
    bool showPercentage = false,
    String? label,
  }) {
    return AppleProgressIndicator(
      value: value,
      size: 48,
      strokeWidth: 4,
      color: color,
      showPercentage: showPercentage,
      label: label,
    );
  }

  @override
  State<AppleProgressIndicator> createState() => _AppleProgressIndicatorState();
}

class _AppleProgressIndicatorState extends State<AppleProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    // Only animate for indeterminate state
    if (widget.value == null) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AppleProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.value != null && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = widget.color ?? AppleTheme.primaryBlue;
    final effectiveTrackColor = widget.trackColor ??
        (isDark
            ? AppleTheme.darkTertiary.withOpacity(0.3)
            : AppleTheme.lightSecondary.withOpacity(0.5));

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _CircularTrackPainter(
              color: effectiveTrackColor,
              strokeWidth: widget.strokeWidth,
            ),
          ),
          // Progress arc
          if (widget.value != null)
            // Determinate progress
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: widget.value!),
              duration: AppleTheme.durationMedium,
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _CircularProgressPainter(
                    progress: value,
                    color: effectiveColor,
                    strokeWidth: widget.strokeWidth,
                  ),
                );
              },
            )
          else
            // Indeterminate progress with rotation
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _IndeterminateProgressPainter(
                      color: effectiveColor,
                      strokeWidth: widget.strokeWidth,
                    ),
                  ),
                );
              },
            ),
          // Percentage or label text
          if (widget.showPercentage && widget.value != null)
            Text(
              '${(widget.value! * 100).toInt()}%',
              style: TextStyle(
                fontSize: widget.size * 0.25,
                fontWeight: FontWeight.w600,
                color: isDark ? AppleTheme.darkText : AppleTheme.lightText,
              ),
            )
          else if (widget.label != null)
            Text(
              widget.label!,
              style: TextStyle(
                fontSize: widget.size * 0.2,
                fontWeight: FontWeight.w500,
                color: isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Painter for the background track
class _CircularTrackPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _CircularTrackPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_CircularTrackPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for determinate progress arc
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for indeterminate progress arc
class _IndeterminateProgressPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _IndeterminateProgressPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    // Draw a partial arc that creates the spinning effect
    const startAngle = -math.pi / 2;
    const sweepAngle = math.pi * 0.75; // 3/4 of a circle

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_IndeterminateProgressPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}


/// Apple-style Linear Progress Indicator
/// 
/// A horizontal progress bar following Apple's design language.
class AppleLinearProgressIndicator extends StatelessWidget {
  /// The progress value (0.0 to 1.0). If null, shows indeterminate animation.
  final double? value;
  
  /// The height of the progress bar
  final double height;
  
  /// The color of the progress indicator
  final Color? color;
  
  /// The background track color
  final Color? trackColor;
  
  /// Border radius of the progress bar
  final double? borderRadius;

  const AppleLinearProgressIndicator({
    Key? key,
    this.value,
    this.height = 4,
    this.color,
    this.trackColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = color ?? AppleTheme.primaryBlue;
    final effectiveTrackColor = trackColor ??
        (isDark
            ? AppleTheme.darkTertiary.withOpacity(0.3)
            : AppleTheme.lightSecondary);
    final effectiveRadius = borderRadius ?? height / 2;

    return ClipRRect(
      borderRadius: BorderRadius.circular(effectiveRadius),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            // Background track
            Container(
              decoration: BoxDecoration(
                color: effectiveTrackColor,
                borderRadius: BorderRadius.circular(effectiveRadius),
              ),
            ),
            // Progress bar
            if (value != null)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: value!),
                duration: AppleTheme.durationMedium,
                curve: Curves.easeOutCubic,
                builder: (context, animatedValue, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: animatedValue.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: effectiveColor,
                        borderRadius: BorderRadius.circular(effectiveRadius),
                      ),
                    ),
                  );
                },
              )
            else
              _IndeterminateLinearProgress(
                color: effectiveColor,
                borderRadius: effectiveRadius,
              ),
          ],
        ),
      ),
    );
  }
}

/// Indeterminate linear progress animation
class _IndeterminateLinearProgress extends StatefulWidget {
  final Color color;
  final double borderRadius;

  const _IndeterminateLinearProgress({
    required this.color,
    required this.borderRadius,
  });

  @override
  State<_IndeterminateLinearProgress> createState() =>
      _IndeterminateLinearProgressState();
}

class _IndeterminateLinearProgressState
    extends State<_IndeterminateLinearProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _positionAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: -0.5, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_controller);

    _widthAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.2, end: 0.5)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.5,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.5, end: 0.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.5,
      ),
    ]).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Align(
          alignment: Alignment(_positionAnimation.value * 2 - 1, 0),
          child: FractionallySizedBox(
            widthFactor: _widthAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
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

/// Apple-style Progress with Completion Animation
/// 
/// Shows a checkmark animation when progress completes.
class AppleProgressWithCompletion extends StatefulWidget {
  /// The progress value (0.0 to 1.0)
  final double value;
  
  /// The size of the indicator
  final double size;
  
  /// The color of the progress indicator
  final Color? color;
  
  /// Callback when completion animation finishes
  final VoidCallback? onComplete;

  const AppleProgressWithCompletion({
    Key? key,
    required this.value,
    this.size = 48,
    this.color,
    this.onComplete,
  }) : super(key: key);

  @override
  State<AppleProgressWithCompletion> createState() =>
      _AppleProgressWithCompletionState();
}

class _AppleProgressWithCompletionState
    extends State<AppleProgressWithCompletion>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkAnimation;
  bool _showCheck = false;
  bool _completionTriggered = false;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      duration: AppleTheme.durationMedium,
      vsync: this,
    );

    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    _checkController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _checkCompletion();
  }

  @override
  void didUpdateWidget(AppleProgressWithCompletion oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkCompletion();
  }

  void _checkCompletion() {
    if (widget.value >= 1.0 && !_completionTriggered) {
      _completionTriggered = true;
      Future.delayed(AppleTheme.durationNormal, () {
        if (mounted) {
          setState(() => _showCheck = true);
          _checkController.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? AppleTheme.primaryBlue;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!_showCheck)
            AppleProgressIndicator(
              value: widget.value,
              size: widget.size,
              color: effectiveColor,
              strokeWidth: 4,
              showPercentage: widget.size >= 48,
            ),
          if (_showCheck)
            ScaleTransition(
              scale: _checkAnimation,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: AppleTheme.systemGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: widget.size * 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }
}

/// Apple-style Activity Indicator (iOS-style spinner)
/// 
/// A classic iOS-style activity indicator with rotating segments.
class AppleActivityIndicator extends StatefulWidget {
  /// The size of the indicator
  final double size;
  
  /// The color of the indicator
  final Color? color;
  
  /// Whether the indicator is animating
  final bool animating;

  const AppleActivityIndicator({
    Key? key,
    this.size = 20,
    this.color,
    this.animating = true,
  }) : super(key: key);

  @override
  State<AppleActivityIndicator> createState() => _AppleActivityIndicatorState();
}

class _AppleActivityIndicatorState extends State<AppleActivityIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    if (widget.animating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AppleActivityIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animating && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animating && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = widget.color ??
        (isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _ActivityIndicatorPainter(
              color: effectiveColor,
              progress: _controller.value,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Painter for iOS-style activity indicator
class _ActivityIndicatorPainter extends CustomPainter {
  final Color color;
  final double progress;
  static const int _segmentCount = 12;

  _ActivityIndicatorPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentLength = radius * 0.35;
    final segmentWidth = radius * 0.12;
    final innerRadius = radius * 0.4;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * 2 * math.pi);

    for (int i = 0; i < _segmentCount; i++) {
      final opacity = (1.0 - (i / _segmentCount)).clamp(0.2, 1.0);
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..strokeWidth = segmentWidth
        ..strokeCap = StrokeCap.round;

      final angle = (i / _segmentCount) * 2 * math.pi - math.pi / 2;
      final startX = math.cos(angle) * innerRadius;
      final startY = math.sin(angle) * innerRadius;
      final endX = math.cos(angle) * (innerRadius + segmentLength);
      final endY = math.sin(angle) * (innerRadius + segmentLength);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ActivityIndicatorPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
