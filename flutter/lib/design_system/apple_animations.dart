import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'apple_theme.dart';

/// Apple 2026 Design System - Animation Utilities
/// 
/// Provides spring animations and animation curves following Apple's
/// Human Interface Guidelines for bouncy, natural-feeling interactions.
/// 
/// Requirements: 15.2 (spring animations for bouncy effects)
class AppleAnimations {
  AppleAnimations._();

  // ============================================
  // SPRING CONFIGURATIONS
  // ============================================
  
  /// Default spring for most UI interactions
  /// Provides a subtle bounce that feels responsive
  static const SpringDescription defaultSpring = SpringDescription(
    mass: 1.0,
    stiffness: 400.0,
    damping: 30.0,
  );
  
  /// Bouncy spring for playful interactions
  /// More pronounced bounce for buttons, cards, etc.
  static const SpringDescription bouncySpring = SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: 20.0,
  );
  
  /// Snappy spring for quick interactions
  /// Fast response with minimal overshoot
  static const SpringDescription snappySpring = SpringDescription(
    mass: 1.0,
    stiffness: 500.0,
    damping: 35.0,
  );
  
  /// Gentle spring for subtle animations
  /// Slow, smooth motion with soft landing
  static const SpringDescription gentleSpring = SpringDescription(
    mass: 1.0,
    stiffness: 200.0,
    damping: 25.0,
  );
  
  /// Heavy spring for larger elements
  /// Feels weighty and substantial
  static const SpringDescription heavySpring = SpringDescription(
    mass: 1.5,
    stiffness: 350.0,
    damping: 40.0,
  );

  // ============================================
  // ANIMATION CURVES
  // ============================================
  
  /// Apple's standard ease-out curve
  static const Curve appleEaseOut = Curves.easeOutCubic;
  
  /// Apple's standard ease-in-out curve
  static const Curve appleEaseInOut = Curves.easeInOutCubic;
  
  /// Bouncy curve for scale animations
  static const Curve bouncyCurve = Curves.elasticOut;
  
  /// Overshoot curve for attention-grabbing animations
  static const Curve overshootCurve = Curves.easeOutBack;
  
  /// Smooth deceleration curve
  static const Curve decelerateCurve = Curves.decelerate;

  // ============================================
  // ANIMATION DURATIONS
  // ============================================
  // Requirement 15.4: Most transitions should be 200-300ms
  
  /// Micro interaction duration (100ms) - for very quick feedback
  static const Duration microDuration = Duration(milliseconds: 100);
  
  /// Fast animation duration (150ms) - for quick transitions
  static const Duration fastDuration = Duration(milliseconds: 150);
  
  /// Standard animation duration (200ms) - lower bound of recommended range
  /// Requirement 15.4: 200-300ms for most transitions
  static const Duration standardDuration = Duration(milliseconds: 200);
  
  /// Recommended transition duration (250ms) - middle of recommended range
  /// Requirement 15.4: 200-300ms for most transitions
  static const Duration transitionDuration = Duration(milliseconds: 250);
  
  /// Medium animation duration (300ms) - upper bound of recommended range
  /// Requirement 15.4: 200-300ms for most transitions
  static const Duration mediumDuration = Duration(milliseconds: 300);
  
  /// Slow animation duration (400ms) - for complex transitions
  static const Duration slowDuration = Duration(milliseconds: 400);
  
  /// Spring animation duration (500ms) - allows time for bounce effect
  /// Used for spring animations that need extra time for overshoot
  static const Duration springDuration = Duration(milliseconds: 500);

  // ============================================
  // SCALE VALUES
  // ============================================
  
  /// Button press scale (0.97)
  static const double buttonPressScale = 0.97;
  
  /// Card press scale (0.98)
  static const double cardPressScale = 0.98;
  
  /// Icon press scale (0.9)
  static const double iconPressScale = 0.9;
  
  /// Dialog appear scale (0.95)
  static const double dialogAppearScale = 0.95;
  
  /// Toast appear scale (0.8)
  static const double toastAppearScale = 0.8;

  // ============================================
  // HELPER METHODS
  // ============================================
  
  /// Creates a spring simulation for custom animations
  static SpringSimulation createSpringSimulation({
    SpringDescription spring = defaultSpring,
    double start = 0.0,
    double end = 1.0,
    double velocity = 0.0,
  }) {
    return SpringSimulation(spring, start, end, velocity);
  }
  
  /// Gets the appropriate spring for a given animation type
  static SpringDescription springForType(AppleSpringType type) {
    switch (type) {
      case AppleSpringType.defaultSpring:
        return defaultSpring;
      case AppleSpringType.bouncy:
        return bouncySpring;
      case AppleSpringType.snappy:
        return snappySpring;
      case AppleSpringType.gentle:
        return gentleSpring;
      case AppleSpringType.heavy:
        return heavySpring;
    }
  }
}

/// Spring animation types
enum AppleSpringType {
  defaultSpring,
  bouncy,
  snappy,
  gentle,
  heavy,
}

/// A custom spring curve that can be used with standard Flutter animations
class SpringCurve extends Curve {
  final SpringDescription spring;
  
  const SpringCurve({
    this.spring = const SpringDescription(
      mass: 1.0,
      stiffness: 400.0,
      damping: 30.0,
    ),
  });
  
  /// Creates a bouncy spring curve
  factory SpringCurve.bouncy() => const SpringCurve(
    spring: SpringDescription(
      mass: 1.0,
      stiffness: 300.0,
      damping: 20.0,
    ),
  );
  
  /// Creates a snappy spring curve
  factory SpringCurve.snappy() => const SpringCurve(
    spring: SpringDescription(
      mass: 1.0,
      stiffness: 500.0,
      damping: 35.0,
    ),
  );
  
  @override
  double transformInternal(double t) {
    // Simulate spring physics
    final simulation = SpringSimulation(spring, 0.0, 1.0, 0.0);
    return simulation.x(t * 0.5); // Scale time for reasonable duration
  }
}

/// Animated scale widget with spring physics
/// 
/// Provides a bouncy scale animation for interactive elements.
class AppleSpringScale extends StatefulWidget {
  final Widget child;
  final bool isPressed;
  final double pressedScale;
  final AppleSpringType springType;
  final Duration duration;
  final VoidCallback? onAnimationComplete;

  const AppleSpringScale({
    Key? key,
    required this.child,
    this.isPressed = false,
    this.pressedScale = 0.97,
    this.springType = AppleSpringType.bouncy,
    this.duration = const Duration(milliseconds: 250), // Requirement 15.4: 200-300ms
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<AppleSpringScale> createState() => _AppleSpringScaleState();
}

class _AppleSpringScaleState extends State<AppleSpringScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _updateAnimation();
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });
  }

  void _updateAnimation() {
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeOutBack,
    ));
  }

  @override
  void didUpdateWidget(AppleSpringScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.pressedScale != oldWidget.pressedScale) {
      _updateAnimation();
    }
    
    if (widget.isPressed != oldWidget.isPressed) {
      if (widget.isPressed) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Animated bounce widget for attention-grabbing effects
class AppleBounce extends StatefulWidget {
  final Widget child;
  final bool animate;
  final double bounceHeight;
  final Duration duration;
  final int repeatCount;

  const AppleBounce({
    Key? key,
    required this.child,
    this.animate = true,
    this.bounceHeight = 8.0,
    this.duration = const Duration(milliseconds: 600),
    this.repeatCount = 1,
  }) : super(key: key);

  @override
  State<AppleBounce> createState() => _AppleBounceState();
}

class _AppleBounceState extends State<AppleBounce>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  int _currentRepeat = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -widget.bounceHeight)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -widget.bounceHeight, end: 0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 70,
      ),
    ]).animate(_controller);
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _currentRepeat++;
        if (_currentRepeat < widget.repeatCount) {
          _controller.reset();
          _controller.forward();
        }
      }
    });
    
    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AppleBounce oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _currentRepeat = 0;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _bounceAnimation.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Animated shake widget for error feedback
class AppleShake extends StatefulWidget {
  final Widget child;
  final bool animate;
  final double shakeOffset;
  final Duration duration;

  const AppleShake({
    Key? key,
    required this.child,
    this.animate = false,
    this.shakeOffset = 10.0,
    this.duration = const Duration(milliseconds: 300), // Requirement 15.4: 200-300ms
  }) : super(key: key);

  @override
  State<AppleShake> createState() => _AppleShakeState();
}

class _AppleShakeState extends State<AppleShake>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: widget.shakeOffset), weight: 1),
      TweenSequenceItem(tween: Tween(begin: widget.shakeOffset, end: -widget.shakeOffset), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -widget.shakeOffset, end: widget.shakeOffset * 0.5), weight: 2),
      TweenSequenceItem(tween: Tween(begin: widget.shakeOffset * 0.5, end: -widget.shakeOffset * 0.5), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -widget.shakeOffset * 0.5, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AppleShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeAnimation.value, 0),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Animated pulse widget for attention effects
class ApplePulse extends StatefulWidget {
  final Widget child;
  final bool animate;
  final double minScale;
  final double maxScale;
  final Duration duration;

  const ApplePulse({
    Key? key,
    required this.child,
    this.animate = true,
    this.minScale = 1.0,
    this.maxScale = 1.05,
    this.duration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  State<ApplePulse> createState() => _ApplePulseState();
}

class _ApplePulseState extends State<ApplePulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ApplePulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) => Transform.scale(
        scale: _pulseAnimation.value,
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Animated appear widget with spring physics
class AppleSpringAppear extends StatefulWidget {
  final Widget child;
  final bool visible;
  final Duration duration;
  final Offset slideOffset;
  final double initialScale;
  final AppleSpringType springType;

  const AppleSpringAppear({
    Key? key,
    required this.child,
    this.visible = true,
    this.duration = const Duration(milliseconds: 300), // Requirement 15.4: 200-300ms
    this.slideOffset = const Offset(0, 20),
    this.initialScale = 0.95,
    this.springType = AppleSpringType.bouncy,
  }) : super(key: key);

  @override
  State<AppleSpringAppear> createState() => _AppleSpringAppearState();
}

class _AppleSpringAppearState extends State<AppleSpringAppear>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: widget.initialScale,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    if (widget.visible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AppleSpringAppear oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _fadeAnimation.value,
        child: Transform.translate(
          offset: _slideAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        ),
      ),
      child: widget.child,
    );
  }
}
