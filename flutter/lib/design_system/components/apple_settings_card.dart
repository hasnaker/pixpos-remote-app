import 'package:flutter/material.dart';
import '../apple_theme.dart';
import '../apple_typography.dart';
import 'apple_card.dart';

/// Apple-style Settings Card
/// 
/// A card component specifically designed for settings pages,
/// replacing the existing _Card widget with Apple design language.
class AppleSettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final List<Widget>? titleSuffix;
  final EdgeInsets? margin;
  final double? width;

  const AppleSettingsCard({
    Key? key,
    required this.title,
    required this.children,
    this.titleSuffix,
    this.margin,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width ?? 540,
      margin: margin ?? EdgeInsets.only(
        left: AppleTheme.spacing16,
        top: AppleTheme.spacing16,
      ),
      child: AppleCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Padding(
              padding: EdgeInsets.only(
                left: AppleTheme.spacing16,
                right: AppleTheme.spacing16,
                top: AppleTheme.spacing12,
                bottom: AppleTheme.spacing12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppleTypography.title3(context),
                    ),
                  ),
                  if (titleSuffix != null) ...titleSuffix!,
                ],
              ),
            ),
            // Divider
            Divider(
              height: 1,
              thickness: 0.5,
              color: isDark ? AppleTheme.darkSeparator : AppleTheme.lightSeparator,
            ),
            // Children with spacing
            ...children.map((child) => Padding(
              padding: EdgeInsets.only(
                top: AppleTheme.spacing4,
                right: AppleTheme.spacing16,
              ),
              child: child,
            )),
            SizedBox(height: AppleTheme.spacing12),
          ],
        ),
      ),
    );
  }
}

/// Apple-style Settings Option Checkbox
/// 
/// A checkbox option for settings, replacing the existing _OptionCheckBox.
class AppleSettingsCheckbox extends StatefulWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final Icon? checkedIcon;
  final String? tooltip;

  const AppleSettingsCheckbox({
    Key? key,
    required this.label,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.checkedIcon,
    this.tooltip,
  }) : super(key: key);

  @override
  State<AppleSettingsCheckbox> createState() => _AppleSettingsCheckboxState();
}

class _AppleSettingsCheckboxState extends State<AppleSettingsCheckbox> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveOpacity = widget.enabled ? 1.0 : AppleTheme.opacityDisabled;
    
    Widget content = MouseRegion(
      onEnter: widget.enabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.enabled ? (_) => setState(() => _isHovered = false) : null,
      cursor: widget.enabled && widget.onChanged != null 
          ? SystemMouseCursors.click 
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.enabled && widget.onChanged != null 
            ? () => widget.onChanged!(!widget.value) 
            : null,
        child: AnimatedContainer(
          duration: AppleTheme.durationFast,
          padding: EdgeInsets.symmetric(
            horizontal: AppleTheme.spacing12,
            vertical: AppleTheme.spacing8,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? (isDark ? AppleTheme.darkSecondary : AppleTheme.lightBackground)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
          ),
          child: Opacity(
            opacity: effectiveOpacity,
            child: Row(
              children: [
                _buildCheckbox(isDark),
                SizedBox(width: AppleTheme.spacing8),
                if (widget.checkedIcon != null && widget.value) ...[
                  widget.checkedIcon!,
                  SizedBox(width: AppleTheme.spacing4),
                ],
                Expanded(
                  child: Text(
                    widget.label,
                    style: AppleTypography.subheadline(context).copyWith(
                      color: isDark ? AppleTheme.darkText : AppleTheme.lightText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        waitDuration: Duration(milliseconds: 500),
        child: content,
      );
    }

    return content;
  }

  Widget _buildCheckbox(bool isDark) {
    return AnimatedContainer(
      duration: AppleTheme.durationFast,
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: widget.value ? AppleTheme.primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: widget.value 
              ? AppleTheme.primaryBlue 
              : (isDark ? AppleTheme.darkTertiary : AppleTheme.lightTertiary),
          width: 1.5,
        ),
      ),
      child: widget.value
          ? Icon(
              Icons.check,
              color: Colors.white,
              size: 14,
            )
          : null,
    );
  }
}

/// Apple-style Settings Radio Button
/// 
/// A radio button option for settings, replacing the existing _Radio.
class AppleSettingsRadio<T> extends StatefulWidget {
  final T value;
  final T groupValue;
  final String label;
  final ValueChanged<T>? onChanged;
  final bool enabled;
  final bool autoNewLine;

  const AppleSettingsRadio({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.label,
    this.onChanged,
    this.enabled = true,
    this.autoNewLine = true,
  }) : super(key: key);

  @override
  State<AppleSettingsRadio<T>> createState() => _AppleSettingsRadioState<T>();
}

class _AppleSettingsRadioState<T> extends State<AppleSettingsRadio<T>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = widget.value == widget.groupValue;
    final effectiveOpacity = widget.enabled ? 1.0 : AppleTheme.opacityDisabled;
    
    return MouseRegion(
      onEnter: widget.enabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.enabled ? (_) => setState(() => _isHovered = false) : null,
      cursor: widget.enabled && widget.onChanged != null 
          ? SystemMouseCursors.click 
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.enabled && widget.onChanged != null 
            ? () => widget.onChanged!(widget.value) 
            : null,
        child: AnimatedContainer(
          duration: AppleTheme.durationFast,
          padding: EdgeInsets.symmetric(
            horizontal: AppleTheme.spacing12,
            vertical: AppleTheme.spacing8,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? (isDark ? AppleTheme.darkSecondary : AppleTheme.lightBackground)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
          ),
          child: Opacity(
            opacity: effectiveOpacity,
            child: Row(
              mainAxisSize: widget.autoNewLine ? MainAxisSize.max : MainAxisSize.min,
              children: [
                _buildRadio(isDark, isSelected),
                SizedBox(width: AppleTheme.spacing8),
                widget.autoNewLine
                    ? Expanded(
                        child: Text(
                          widget.label,
                          style: AppleTypography.subheadline(context).copyWith(
                            color: isDark ? AppleTheme.darkText : AppleTheme.lightText,
                          ),
                        ),
                      )
                    : Text(
                        widget.label,
                        style: AppleTypography.subheadline(context).copyWith(
                          color: isDark ? AppleTheme.darkText : AppleTheme.lightText,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadio(bool isDark, bool isSelected) {
    return AnimatedContainer(
      duration: AppleTheme.durationFast,
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isSelected ? AppleTheme.primaryBlue : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected 
              ? AppleTheme.primaryBlue 
              : (isDark ? AppleTheme.darkTertiary : AppleTheme.lightTertiary),
          width: 1.5,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

/// Apple-style Settings Button
/// 
/// A button for settings actions, replacing the existing _Button.
class AppleSettingsButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool destructive;

  const AppleSettingsButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.enabled = true,
    this.destructive = false,
  }) : super(key: key);

  @override
  State<AppleSettingsButton> createState() => _AppleSettingsButtonState();
}

class _AppleSettingsButtonState extends State<AppleSettingsButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveEnabled = widget.enabled && widget.onPressed != null;
    
    final backgroundColor = widget.destructive
        ? AppleTheme.systemRed
        : AppleTheme.primaryBlue;
    
    return MouseRegion(
      onEnter: effectiveEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: effectiveEnabled ? (_) => setState(() => _isHovered = false) : null,
      cursor: effectiveEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: effectiveEnabled ? widget.onPressed : null,
        onTapDown: effectiveEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: effectiveEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: effectiveEnabled ? () => setState(() => _isPressed = false) : null,
        child: AnimatedContainer(
          duration: AppleTheme.durationFast,
          padding: EdgeInsets.symmetric(
            horizontal: AppleTheme.spacing20,
            vertical: AppleTheme.spacing10,
          ),
          margin: EdgeInsets.only(left: AppleTheme.spacing12),
          decoration: BoxDecoration(
            color: effectiveEnabled
                ? (_isPressed
                    ? backgroundColor.withOpacity(0.8)
                    : (_isHovered
                        ? backgroundColor.withOpacity(0.9)
                        : backgroundColor))
                : backgroundColor.withOpacity(AppleTheme.opacityDisabled),
            borderRadius: BorderRadius.circular(AppleTheme.radiusMedium),
          ),
          child: Text(
            widget.text,
            style: AppleTypography.buttonSmall(context).copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Apple-style Sub-labeled Widget
/// 
/// A widget with a label and content, used for sub-settings.
class AppleSubLabeledWidget extends StatelessWidget {
  final String label;
  final Widget child;
  final bool enabled;

  const AppleSubLabeledWidget({
    Key? key,
    required this.label,
    required this.child,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveOpacity = enabled ? 1.0 : AppleTheme.opacityDisabled;
    
    return Opacity(
      opacity: effectiveOpacity,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppleTheme.spacing32,
          top: AppleTheme.spacing4,
          bottom: AppleTheme.spacing4,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppleTypography.footnote(context).copyWith(
                color: isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText,
              ),
            ),
            SizedBox(width: AppleTheme.spacing12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// Apple-style Sub Button
/// 
/// A smaller button used in sub-settings.
class AppleSubButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;

  const AppleSubButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<AppleSubButton> createState() => _AppleSubButtonState();
}

class _AppleSubButtonState extends State<AppleSubButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveEnabled = widget.enabled && widget.onPressed != null;
    
    return MouseRegion(
      onEnter: effectiveEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: effectiveEnabled ? (_) => setState(() => _isHovered = false) : null,
      cursor: effectiveEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: effectiveEnabled ? widget.onPressed : null,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppleTheme.spacing32,
            top: AppleTheme.spacing4,
            bottom: AppleTheme.spacing4,
          ),
          child: Text(
            widget.text,
            style: AppleTypography.subheadline(context).copyWith(
              color: effectiveEnabled
                  ? (_isHovered
                      ? AppleTheme.primaryBlue.withOpacity(0.8)
                      : AppleTheme.primaryBlue)
                  : AppleTheme.primaryBlue.withOpacity(AppleTheme.opacityDisabled),
            ),
          ),
        ),
      ),
    );
  }
}
