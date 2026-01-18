import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../apple_theme.dart';
import '../apple_typography.dart';

/// Apple-style Mobile Text Field
/// 
/// A text field optimized for mobile with proper keyboard handling,
/// 44px minimum touch targets, and Apple design language.
class AppleMobileTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final bool obscureText;
  final bool readOnly;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? suffix;
  final VoidCallback? onSuffixTap;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool showClearButton;
  final bool large;
  final EdgeInsets? contentPadding;

  const AppleMobileTextField({
    Key? key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.obscureText = false,
    this.readOnly = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.onSuffixTap,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.showClearButton = false,
    this.large = false,
    this.contentPadding,
  }) : super(key: key);

  @override
  State<AppleMobileTextField> createState() => _AppleMobileTextFieldState();
}

class _AppleMobileTextFieldState extends State<AppleMobileTextField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _isFocused = false;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController();
    _obscureText = widget.obscureText;
    
    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_handleTextChange);
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _handleTextChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _controller.removeListener(_handleTextChange);
    if (widget.focusNode == null) _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    
    final backgroundColor = isDark ? AppleTheme.darkSecondary : AppleTheme.lightBackground;
    final borderColor = hasError 
      ? AppleTheme.systemRed
      : (_isFocused 
          ? AppleTheme.primaryBlue 
          : (isDark ? AppleTheme.darkTertiary : AppleTheme.lightSecondary));
    final borderWidth = _isFocused || hasError ? 2.0 : 1.0;
    
    final textColor = isDark ? AppleTheme.darkText : AppleTheme.lightText;
    final hintColor = isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText;
    final labelColor = isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppleTypography.footnote(context).copyWith(
              fontWeight: FontWeight.w500,
              color: hasError ? AppleTheme.systemRed : labelColor,
            ),
          ),
          SizedBox(height: AppleTheme.spacing8),
        ],
        AnimatedContainer(
          duration: AppleTheme.durationNormal,
          constraints: BoxConstraints(
            minHeight: AppleTheme.touchTargetMin,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            obscureText: _obscureText,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            style: TextStyle(
              fontSize: widget.large ? 18 : 16,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                fontSize: widget.large ? 18 : 16,
                fontWeight: FontWeight.w400,
                color: hintColor,
              ),
              contentPadding: widget.contentPadding ?? EdgeInsets.symmetric(
                horizontal: AppleTheme.spacing16,
                vertical: widget.large ? AppleTheme.spacing16 : AppleTheme.spacing12,
              ),
              border: InputBorder.none,
              counterText: '',
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: EdgeInsets.only(left: AppleTheme.spacing12),
                      child: Icon(
                        widget.prefixIcon,
                        color: _isFocused ? AppleTheme.primaryBlue : hintColor,
                        size: 20,
                      ),
                    )
                  : null,
              prefixIconConstraints: BoxConstraints(minWidth: AppleTheme.touchTargetMin),
              suffixIcon: _buildSuffixIcon(hintColor),
              suffixIconConstraints: BoxConstraints(minWidth: AppleTheme.touchTargetMin),
            ),
          ),
        ),
        if (widget.helperText != null && !hasError) ...[
          SizedBox(height: AppleTheme.spacing4),
          Text(
            widget.helperText!,
            style: AppleTypography.caption1(context).copyWith(
              color: labelColor,
            ),
          ),
        ],
        if (hasError) ...[
          SizedBox(height: AppleTheme.spacing4),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 14,
                color: AppleTheme.systemRed,
              ),
              SizedBox(width: AppleTheme.spacing4),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: AppleTypography.caption1(context).copyWith(
                    color: AppleTheme.systemRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon(Color hintColor) {
    final List<Widget> icons = [];

    // Clear button
    if (widget.showClearButton && _controller.text.isNotEmpty) {
      icons.add(
        GestureDetector(
          onTap: () {
            _controller.clear();
            widget.onChanged?.call('');
          },
          child: Container(
            width: AppleTheme.touchTargetMin,
            height: AppleTheme.touchTargetMin,
            child: Center(
              child: Icon(
                Icons.cancel,
                color: hintColor,
                size: 18,
              ),
            ),
          ),
        ),
      );
    }

    // Password toggle
    if (widget.obscureText) {
      icons.add(
        GestureDetector(
          onTap: () => setState(() => _obscureText = !_obscureText),
          child: Container(
            width: AppleTheme.touchTargetMin,
            height: AppleTheme.touchTargetMin,
            child: Center(
              child: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: hintColor,
                size: 20,
              ),
            ),
          ),
        ),
      );
    }

    // Custom suffix icon
    if (widget.suffixIcon != null) {
      icons.add(
        GestureDetector(
          onTap: widget.onSuffixTap,
          child: Container(
            width: AppleTheme.touchTargetMin,
            height: AppleTheme.touchTargetMin,
            child: Center(
              child: Icon(
                widget.suffixIcon,
                color: _isFocused ? AppleTheme.primaryBlue : hintColor,
                size: 20,
              ),
            ),
          ),
        ),
      );
    }

    // Custom suffix widget
    if (widget.suffix != null) {
      icons.add(widget.suffix!);
    }

    if (icons.isEmpty) return null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: icons,
    );
  }
}

/// Apple-style Mobile Search Field
/// 
/// A search field optimized for mobile with proper touch targets.
class AppleMobileSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final FocusNode? focusNode;

  const AppleMobileSearchField({
    Key? key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppleMobileTextField(
      controller: controller,
      focusNode: focusNode,
      hint: hint ?? 'Search',
      prefixIcon: Icons.search,
      showClearButton: true,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
    );
  }
}

/// Apple-style Mobile Form Section
/// 
/// A form section with proper grouping and styling.
class AppleMobileFormSection extends StatelessWidget {
  final String? header;
  final String? footer;
  final List<Widget> children;
  final EdgeInsets? padding;

  const AppleMobileFormSection({
    Key? key,
    this.header,
    this.footer,
    required this.children,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: AppleTheme.spacing16,
        vertical: AppleTheme.spacing8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) ...[
            Padding(
              padding: EdgeInsets.only(
                left: AppleTheme.spacing4,
                bottom: AppleTheme.spacing8,
              ),
              child: Text(
                header!.toUpperCase(),
                style: AppleTypography.caption1(context).copyWith(
                  color: isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppleTheme.darkSurface : AppleTheme.lightSurface,
              borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
            ),
            child: Column(
              children: children.asMap().entries.map((entry) {
                final index = entry.key;
                final child = entry.value;
                final isLast = index == children.length - 1;
                
                return Column(
                  children: [
                    child,
                    if (!isLast)
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        indent: AppleTheme.spacing16,
                        color: isDark ? AppleTheme.darkSeparator : AppleTheme.lightSeparator,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          if (footer != null) ...[
            Padding(
              padding: EdgeInsets.only(
                left: AppleTheme.spacing4,
                top: AppleTheme.spacing8,
              ),
              child: Text(
                footer!,
                style: AppleTypography.caption1(context).copyWith(
                  color: isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Apple-style Mobile Form Row
/// 
/// A form row with label and value, optimized for touch.
class AppleMobileFormRow extends StatefulWidget {
  final String label;
  final Widget? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDisclosure;

  const AppleMobileFormRow({
    Key? key,
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
    this.showDisclosure = false,
  }) : super(key: key);

  @override
  State<AppleMobileFormRow> createState() => _AppleMobileFormRowState();
}

class _AppleMobileFormRowState extends State<AppleMobileFormRow> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null ? (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      } : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: AppleTheme.durationFast,
        constraints: BoxConstraints(minHeight: AppleTheme.touchTargetMin),
        decoration: BoxDecoration(
          color: _isPressed 
            ? (isDark ? AppleTheme.darkSecondary : AppleTheme.lightSecondary)
            : Colors.transparent,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppleTheme.spacing16,
          vertical: AppleTheme.spacing12,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: AppleTypography.body(context),
              ),
            ),
            if (widget.value != null) ...[
              SizedBox(width: AppleTheme.spacing8),
              widget.value!,
            ],
            if (widget.trailing != null) ...[
              SizedBox(width: AppleTheme.spacing8),
              widget.trailing!,
            ],
            if (widget.showDisclosure) ...[
              SizedBox(width: AppleTheme.spacing8),
              Icon(
                Icons.chevron_right,
                color: isDark ? AppleTheme.darkTertiaryText : AppleTheme.lightTertiaryText,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Apple-style Mobile Switch Row
/// 
/// A form row with a switch, optimized for touch.
class AppleMobileSwitchRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  const AppleMobileSwitchRow({
    Key? key,
    required this.label,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      constraints: BoxConstraints(minHeight: AppleTheme.touchTargetMin),
      padding: EdgeInsets.symmetric(
        horizontal: AppleTheme.spacing16,
        vertical: AppleTheme.spacing12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppleTypography.body(context).copyWith(
                    color: enabled 
                      ? (isDark ? AppleTheme.darkText : AppleTheme.lightText)
                      : (isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText),
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppleTheme.spacing2),
                  Text(
                    subtitle!,
                    style: AppleTypography.caption1(context).copyWith(
                      color: isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: AppleTheme.spacing12),
          Switch.adaptive(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: AppleTheme.primaryBlue,
          ),
        ],
      ),
    );
  }
}

/// Keyboard-aware wrapper for mobile forms
/// 
/// Automatically adjusts padding when keyboard is visible.
class AppleMobileKeyboardAware extends StatelessWidget {
  final Widget child;
  final EdgeInsets? additionalPadding;

  const AppleMobileKeyboardAware({
    Key? key,
    required this.child,
    this.additionalPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return AnimatedPadding(
      duration: AppleTheme.durationNormal,
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: bottomInset > 0 ? bottomInset : 0,
      ).add(additionalPadding ?? EdgeInsets.zero),
      child: child,
    );
  }
}
