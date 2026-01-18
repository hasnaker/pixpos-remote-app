import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../apple_theme.dart';

/// Apple-style Text Field Component
/// 
/// A text field with focus states, validation, and proper styling.
class AppleTextField extends StatefulWidget {
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

  const AppleTextField({
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
  }) : super(key: key);

  @override
  State<AppleTextField> createState() => _AppleTextFieldState();
}

class _AppleTextFieldState extends State<AppleTextField> {
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
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: hasError ? AppleTheme.systemRed : labelColor,
            ),
          ),
          SizedBox(height: AppleTheme.spacing8),
        ],
        AnimatedContainer(
          duration: AppleTheme.durationNormal,
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
              contentPadding: EdgeInsets.symmetric(
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
              prefixIconConstraints: BoxConstraints(minWidth: 44),
              suffixIcon: _buildSuffixIcon(hintColor),
              suffixIconConstraints: BoxConstraints(minWidth: 44),
            ),
          ),
        ),
        if (widget.helperText != null && !hasError) ...[
          SizedBox(height: AppleTheme.spacing4),
          Text(
            widget.helperText!,
            style: TextStyle(
              fontSize: 12,
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
                  style: TextStyle(
                    fontSize: 12,
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
          child: Icon(
            Icons.cancel,
            color: hintColor,
            size: 18,
          ),
        ),
      );
    }

    // Password toggle
    if (widget.obscureText) {
      icons.add(
        GestureDetector(
          onTap: () => setState(() => _obscureText = !_obscureText),
          child: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: hintColor,
            size: 20,
          ),
        ),
      );
    }

    // Custom suffix icon
    if (widget.suffixIcon != null) {
      icons.add(
        GestureDetector(
          onTap: widget.onSuffixTap,
          child: Icon(
            widget.suffixIcon,
            color: _isFocused ? AppleTheme.primaryBlue : hintColor,
            size: 20,
          ),
        ),
      );
    }

    // Custom suffix widget
    if (widget.suffix != null) {
      icons.add(widget.suffix!);
    }

    if (icons.isEmpty) return null;

    return Padding(
      padding: EdgeInsets.only(right: AppleTheme.spacing12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: icons.map((icon) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: icon,
        )).toList(),
      ),
    );
  }
}

/// Apple-style Search Field
class AppleSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  const AppleSearchField({
    Key? key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppleTextField(
      controller: controller,
      hint: hint ?? 'Search',
      prefixIcon: Icons.search,
      showClearButton: true,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
    );
  }
}
