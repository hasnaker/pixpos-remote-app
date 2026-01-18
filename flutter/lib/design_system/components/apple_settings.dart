import 'package:flutter/material.dart';
import '../apple_theme.dart';
import '../apple_typography.dart';
import 'apple_card.dart';

/// Apple-style Settings Section
/// 
/// A grouped section for settings with a title and list of items.
class AppleSettingsSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final EdgeInsets? margin;

  const AppleSettingsSection({
    Key? key,
    this.title,
    required this.children,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: margin ?? EdgeInsets.only(bottom: AppleTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: EdgeInsets.only(
                left: AppleTheme.spacing16,
                bottom: AppleTheme.spacing8,
              ),
              child: Text(
                title!.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          AppleCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: _buildChildrenWithDividers(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChildrenWithDividers(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Widget> result = [];
    
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(
          Divider(
            height: 1,
            thickness: 0.5,
            indent: AppleTheme.spacing16,
            color: isDark ? AppleTheme.darkSeparator : AppleTheme.lightSeparator,
          ),
        );
      }
    }
    
    return result;
  }
}

/// Apple-style Settings Tile
/// 
/// A single settings item with icon, title, subtitle, and trailing widget.
class AppleSettingsTile extends StatefulWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool enabled;

  const AppleSettingsTile({
    Key? key,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<AppleSettingsTile> createState() => _AppleSettingsTileState();
}

class _AppleSettingsTileState extends State<AppleSettingsTile> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveOpacity = widget.enabled ? 1.0 : AppleTheme.opacityDisabled;
    
    return MouseRegion(
      onEnter: widget.enabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.enabled ? (_) => setState(() => _isHovered = false) : null,
      cursor: widget.onTap != null && widget.enabled 
          ? SystemMouseCursors.click 
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        onTapDown: widget.enabled && widget.onTap != null 
            ? (_) => setState(() => _isPressed = true) 
            : null,
        onTapUp: widget.enabled && widget.onTap != null 
            ? (_) => setState(() => _isPressed = false) 
            : null,
        onTapCancel: widget.enabled && widget.onTap != null 
            ? () => setState(() => _isPressed = false) 
            : null,
        child: AnimatedContainer(
          duration: AppleTheme.durationFast,
          padding: EdgeInsets.symmetric(
            horizontal: AppleTheme.spacing16,
            vertical: AppleTheme.spacing12,
          ),
          decoration: BoxDecoration(
            color: _isPressed
                ? (isDark ? AppleTheme.darkTertiary : AppleTheme.lightSecondary)
                : (_isHovered && widget.onTap != null
                    ? (isDark ? AppleTheme.darkSecondary : AppleTheme.lightBackground)
                    : Colors.transparent),
          ),
          child: Opacity(
            opacity: effectiveOpacity,
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: widget.iconColor ?? AppleTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: AppleTheme.spacing12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppleTypography.body(context),
                      ),
                      if (widget.subtitle != null) ...[
                        SizedBox(height: AppleTheme.spacing2),
                        Text(
                          widget.subtitle!,
                          style: AppleTypography.footnote(context),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.trailing != null) ...[
                  SizedBox(width: AppleTheme.spacing8),
                  widget.trailing!,
                ],
                if (widget.showChevron) ...[
                  SizedBox(width: AppleTheme.spacing8),
                  Icon(
                    Icons.chevron_right,
                    color: isDark ? AppleTheme.darkTertiaryText : AppleTheme.lightTertiary,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}


/// Apple-style Switch Tile
/// 
/// A settings tile with a switch control.
class AppleSwitchTile extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  const AppleSwitchTile({
    Key? key,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppleSettingsTile(
      icon: icon,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      trailing: AppleSwitch(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
      onTap: enabled && onChanged != null 
          ? () => onChanged!(!value) 
          : null,
    );
  }
}

/// Apple-style Switch
/// 
/// A toggle switch following Apple's design.
class AppleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AppleSwitch({
    Key? key,
    required this.value,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 51,
      height: 31,
      child: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppleTheme.systemGreen,
        activeTrackColor: AppleTheme.systemGreen,
      ),
    );
  }
}

/// Apple-style Checkbox Tile
/// 
/// A settings tile with a checkbox control.
class AppleCheckboxTile extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  const AppleCheckboxTile({
    Key? key,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppleSettingsTile(
      icon: icon,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      trailing: AppleCheckbox(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
      onTap: enabled && onChanged != null 
          ? () => onChanged!(!value) 
          : null,
    );
  }
}

/// Apple-style Checkbox
/// 
/// A checkbox following Apple's design.
class AppleCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AppleCheckbox({
    Key? key,
    required this.value,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: AnimatedContainer(
        duration: AppleTheme.durationFast,
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: value ? AppleTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: value 
                ? AppleTheme.primaryBlue 
                : (isDark ? AppleTheme.darkTertiary : AppleTheme.lightTertiary),
            width: 2,
          ),
        ),
        child: value
            ? Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              )
            : null,
      ),
    );
  }
}

/// Apple-style Radio Tile
/// 
/// A settings tile with a radio button control.
class AppleRadioTile<T> extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final T value;
  final T groupValue;
  final ValueChanged<T>? onChanged;
  final bool enabled;

  const AppleRadioTile({
    Key? key,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    
    return AppleSettingsTile(
      icon: icon,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      trailing: isSelected
          ? Icon(
              Icons.check,
              color: AppleTheme.primaryBlue,
              size: 20,
            )
          : null,
      onTap: enabled && onChanged != null 
          ? () => onChanged!(value) 
          : null,
    );
  }
}

/// Apple-style Dropdown Tile
/// 
/// A settings tile with a dropdown selector.
class AppleDropdownTile<T> extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool enabled;

  const AppleDropdownTile({
    Key? key,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    required this.items,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppleSettingsTile(
      icon: icon,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      trailing: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppleTheme.spacing12,
          vertical: AppleTheme.spacing6,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppleTheme.darkTertiary : AppleTheme.lightSecondary,
          borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            items: items,
            onChanged: enabled ? onChanged : null,
            isDense: true,
            style: AppleTypography.subheadline(context),
            icon: Icon(
              Icons.unfold_more,
              size: 16,
              color: isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText,
            ),
          ),
        ),
      ),
    );
  }
}

/// Apple-style Settings Header
/// 
/// A header for the settings page with title and optional subtitle.
class AppleSettingsHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const AppleSettingsHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppleTheme.spacing16,
        vertical: AppleTheme.spacing16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppleTypography.largeTitle(context),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppleTheme.spacing4),
                  Text(
                    subtitle!,
                    style: AppleTypography.footnote(context),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Apple-style Settings Page Scaffold
/// 
/// A scaffold for settings pages with proper styling.
class AppleSettingsPage extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? leading;
  final List<Widget>? actions;
  final ScrollController? scrollController;

  const AppleSettingsPage({
    Key? key,
    required this.title,
    required this.children,
    this.leading,
    this.actions,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppleTheme.darkBackground : AppleTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppleTheme.darkSurface : AppleTheme.lightSurface,
        elevation: 0,
        leading: leading,
        title: Text(
          title,
          style: AppleTypography.headline(context),
        ),
        centerTitle: true,
        actions: actions,
      ),
      body: ListView(
        controller: scrollController,
        padding: EdgeInsets.all(AppleTheme.spacing16),
        children: children,
      ),
    );
  }
}

/// Apple-style Settings Navigation Tile
/// 
/// A tile that navigates to another settings page.
class AppleSettingsNavigationTile extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final bool enabled;

  const AppleSettingsNavigationTile({
    Key? key,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppleSettingsTile(
      icon: icon,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      showChevron: true,
      trailing: value != null
          ? Text(
              value!,
              style: AppleTypography.subheadline(context).copyWith(
                color: isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}

/// Apple-style Button Tile
/// 
/// A tile with a button action.
class AppleButtonTile extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final VoidCallback? onTap;
  final bool enabled;
  final bool destructive;
  final bool centered;

  const AppleButtonTile({
    Key? key,
    required this.title,
    this.titleColor,
    this.onTap,
    this.enabled = true,
    this.destructive = false,
    this.centered = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = titleColor ?? 
        (destructive ? AppleTheme.systemRed : AppleTheme.primaryBlue);
    
    return AppleSettingsTile(
      title: title,
      enabled: enabled,
      onTap: onTap,
      trailing: centered ? null : Icon(
        Icons.chevron_right,
        color: effectiveColor.withOpacity(enabled ? 1.0 : AppleTheme.opacityDisabled),
        size: 20,
      ),
    );
  }
}

/// Apple-style Text Input Tile
/// 
/// A tile with a text input field.
class AppleTextInputTile extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;

  const AppleTextInputTile({
    Key? key,
    this.icon,
    this.iconColor,
    required this.title,
    this.hint,
    this.controller,
    this.onChanged,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppleTheme.spacing16,
        vertical: AppleTheme.spacing12,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor ?? AppleTheme.primaryBlue,
                borderRadius: BorderRadius.circular(AppleTheme.radiusSmall),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            SizedBox(width: AppleTheme.spacing12),
          ],
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: AppleTypography.body(context),
            ),
          ),
          SizedBox(width: AppleTheme.spacing12),
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              enabled: enabled,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textAlign: TextAlign.end,
              style: AppleTypography.body(context),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppleTypography.body(context).copyWith(
                  color: isDark ? AppleTheme.darkSecondaryText : AppleTheme.lightSecondaryText,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
