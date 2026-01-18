import 'dart:ui';
import 'package:flutter/material.dart';
import '../apple_theme.dart';
import '../apple_typography.dart';
import '../apple_animations.dart';
import 'apple_button.dart';

/// Dialog action button configuration
class AppleDialogAction {
  final String text;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isDefault;

  const AppleDialogAction({
    required this.text,
    this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
  });
}

/// Apple-style Dialog Component
/// 
/// A modal dialog following Apple's Human Interface Guidelines.
/// Features blur backdrop, scale animation, and styled action buttons.
/// 
/// Requirements: 11.1, 11.2, 11.3, 11.4, 11.5
class AppleDialog extends StatefulWidget {
  final String? title;
  final String? message;
  final Widget? content;
  final List<AppleDialogAction> actions;
  final bool showCloseButton;
  final double? maxWidth;
  final EdgeInsets? contentPadding;

  const AppleDialog({
    Key? key,
    this.title,
    this.message,
    this.content,
    this.actions = const [],
    this.showCloseButton = false,
    this.maxWidth,
    this.contentPadding,
  }) : super(key: key);

  /// Shows the dialog with animation
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    Widget? content,
    List<AppleDialogAction> actions = const [],
    bool showCloseButton = false,
    bool barrierDismissible = true,
    double? maxWidth,
    EdgeInsets? contentPadding,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: AppleTheme.durationMedium,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AppleDialog(
          title: title,
          message: message,
          content: content,
          actions: actions,
          showCloseButton: showCloseButton,
          maxWidth: maxWidth,
          contentPadding: contentPadding,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return _AppleDialogTransition(
          animation: animation,
          child: child,
        );
      },
    );
  }

  /// Shows a simple alert dialog
  static Future<void> alert({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = 'OK',
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      actions: [
        AppleDialogAction(
          text: buttonText,
          isDefault: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  /// Shows a confirmation dialog
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    String? message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return show<bool>(
      context: context,
      title: title,
      message: message,
      actions: [
        AppleDialogAction(
          text: cancelText,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppleDialogAction(
          text: confirmText,
          isDestructive: isDestructive,
          isDefault: !isDestructive,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }

  @override
  State<AppleDialog> createState() => _AppleDialogState();
}

class _AppleDialogState extends State<AppleDialog> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = widget.maxWidth ?? 320.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: screenSize.height * 0.85,
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.all(AppleTheme.spacing24),
            decoration: BoxDecoration(
              // Requirement 11.1: 20px border radius
              borderRadius: BorderRadius.circular(AppleTheme.radiusXLarge),
              color: isDark 
                ? AppleTheme.darkSurface.withOpacity(0.95)
                : AppleTheme.lightSurface.withOpacity(0.95),
              boxShadow: isDark 
                ? AppleTheme.shadowDarkElevated 
                : AppleTheme.shadowLightElevated,
              border: Border.all(
                color: isDark 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppleTheme.radiusXLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with optional close button
                  if (widget.showCloseButton)
                    _buildHeader(context, isDark),
                  
                  // Content area - Requirement 11.4: 24px padding
                  Flexible(
                    child: SingleChildScrollView(
                      padding: widget.contentPadding ?? EdgeInsets.all(AppleTheme.spacing24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.title != null) ...[
                            Text(
                              widget.title!,
                              style: AppleTypography.headline(context).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (widget.message != null || widget.content != null)
                              SizedBox(height: AppleTheme.spacing12),
                          ],
                          if (widget.message != null) ...[
                            Text(
                              widget.message!,
                              style: AppleTypography.body(context).copyWith(
                                color: AppleTheme.secondaryTextColor(context),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (widget.content != null)
                              SizedBox(height: AppleTheme.spacing16),
                          ],
                          if (widget.content != null)
                            widget.content!,
                        ],
                      ),
                    ),
                  ),
                  
                  // Action buttons - Requirement 11.3: centered with 12px gap
                  if (widget.actions.isNotEmpty)
                    _buildActions(context, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: AppleTheme.spacing8,
        right: AppleTheme.spacing8,
      ),
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDark 
              ? AppleTheme.darkTertiary 
              : AppleTheme.lightSecondary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close,
            size: 16,
            color: isDark 
              ? AppleTheme.darkSecondaryText 
              : AppleTheme.lightSecondaryText,
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isDark) {
    // For 2 actions, show side by side
    // For more or 1, show stacked
    final shouldStack = widget.actions.length != 2;

    if (shouldStack) {
      return Container(
        padding: EdgeInsets.fromLTRB(
          AppleTheme.spacing24,
          0,
          AppleTheme.spacing24,
          AppleTheme.spacing24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.actions.map((action) {
            return Padding(
              padding: EdgeInsets.only(
                top: widget.actions.indexOf(action) > 0 
                  ? AppleTheme.spacing12 
                  : 0,
              ),
              child: _buildActionButton(context, action, isExpanded: true),
            );
          }).toList(),
        ),
      );
    }

    // Side by side layout for 2 buttons
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppleTheme.spacing24,
        0,
        AppleTheme.spacing24,
        AppleTheme.spacing24,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(context, widget.actions[0]),
          ),
          SizedBox(width: AppleTheme.spacing12), // Requirement 11.3: 12px gap
          Expanded(
            child: _buildActionButton(context, widget.actions[1]),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, 
    AppleDialogAction action, {
    bool isExpanded = false,
  }) {
    if (action.isDestructive) {
      return AppleButton.destructive(
        text: action.text,
        onPressed: action.onPressed,
        isExpanded: isExpanded,
      );
    }
    
    if (action.isDefault) {
      return AppleButton.primary(
        text: action.text,
        onPressed: action.onPressed,
        isExpanded: isExpanded,
      );
    }
    
    return AppleButton.secondary(
      text: action.text,
      onPressed: action.onPressed,
      isExpanded: isExpanded,
    );
  }
}

/// Dialog transition with blur backdrop and scale animation
/// Requirements: 11.1 (blur backdrop), 11.2 (scale animation), 11.5 (fade-out with scale-down), 15.2 (spring animations)
class _AppleDialogTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _AppleDialogTransition({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Requirement 11.2: Scale from 0.95 to 1.0 with spring bounce (Requirement 15.2)
    final scaleAnimation = Tween<double>(
      begin: AppleAnimations.dialogAppearScale,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack, // Spring-like bounce effect
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ));

    // Requirement 11.1: Blur backdrop with 20px radius
    final blurAnimation = Tween<double>(
      begin: 0.0,
      end: AppleTheme.blurMedium,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ));

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Stack(
          children: [
            // Blur backdrop
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blurAnimation.value,
                  sigmaY: blurAnimation.value,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.3 * fadeAnimation.value),
                ),
              ),
            ),
            // Dialog with scale and fade
            FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A sheet-style dialog that slides up from the bottom
class AppleActionSheet extends StatelessWidget {
  final String? title;
  final String? message;
  final List<AppleDialogAction> actions;
  final AppleDialogAction? cancelAction;

  const AppleActionSheet({
    Key? key,
    this.title,
    this.message,
    this.actions = const [],
    this.cancelAction,
  }) : super(key: key);

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    List<AppleDialogAction> actions = const [],
    AppleDialogAction? cancelAction,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AppleActionSheet(
        title: title,
        message: message,
        actions: actions,
        cancelAction: cancelAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppleTheme.spacing8,
          AppleTheme.spacing8,
          AppleTheme.spacing8,
          AppleTheme.spacing8 + bottomPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main action sheet
            Container(
              decoration: BoxDecoration(
                color: isDark 
                  ? AppleTheme.darkSurface.withOpacity(0.95)
                  : AppleTheme.lightSurface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(AppleTheme.radiusLarge),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppleTheme.radiusLarge),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      if (title != null || message != null)
                        Container(
                          padding: EdgeInsets.all(AppleTheme.spacing16),
                          child: Column(
                            children: [
                              if (title != null)
                                Text(
                                  title!,
                                  style: AppleTypography.footnote(context).copyWith(
                                    color: AppleTheme.secondaryTextColor(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              if (message != null) ...[
                                if (title != null) SizedBox(height: AppleTheme.spacing4),
                                Text(
                                  message!,
                                  style: AppleTypography.footnote(context).copyWith(
                                    color: AppleTheme.secondaryTextColor(context),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      
                      // Actions
                      ...actions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final action = entry.value;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (index > 0 || title != null || message != null)
                              Divider(
                                height: 0.5,
                                thickness: 0.5,
                                color: AppleTheme.separatorColor(context),
                              ),
                            _ActionSheetButton(
                              action: action,
                              onTap: () {
                                Navigator.of(context).pop();
                                action.onPressed?.call();
                              },
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            
            // Cancel button
            if (cancelAction != null) ...[
              SizedBox(height: AppleTheme.spacing8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark 
                    ? AppleTheme.darkSurface
                    : AppleTheme.lightSurface,
                  borderRadius: BorderRadius.circular(AppleTheme.radiusLarge),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppleTheme.radiusLarge),
                  child: _ActionSheetButton(
                    action: cancelAction!,
                    isCancel: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      cancelAction!.onPressed?.call();
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionSheetButton extends StatefulWidget {
  final AppleDialogAction action;
  final VoidCallback onTap;
  final bool isCancel;

  const _ActionSheetButton({
    required this.action,
    required this.onTap,
    this.isCancel = false,
  });

  @override
  State<_ActionSheetButton> createState() => _ActionSheetButtonState();
}

class _ActionSheetButtonState extends State<_ActionSheetButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color textColor;
    FontWeight fontWeight;
    
    if (widget.action.isDestructive) {
      textColor = AppleTheme.systemRed;
      fontWeight = FontWeight.w400;
    } else if (widget.isCancel || widget.action.isDefault) {
      textColor = AppleTheme.primaryBlue;
      fontWeight = FontWeight.w600;
    } else {
      textColor = AppleTheme.primaryBlue;
      fontWeight = FontWeight.w400;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: AppleTheme.durationFast,
        color: _isPressed 
          ? (isDark ? AppleTheme.darkSecondary : AppleTheme.lightSecondary)
          : Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: AppleTheme.spacing16),
        child: Center(
          child: Text(
            widget.action.text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: fontWeight,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
