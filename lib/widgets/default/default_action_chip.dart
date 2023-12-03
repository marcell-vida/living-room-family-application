import 'package:flutter/material.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_text.dart';

class DefaultActionChip extends StatelessWidget {
  final String? title;
  final Color color;
  final Color titleColor;
  final Color disabledColor;
  final Color? iconColor;
  final Widget? avatar;
  final IconData? icon;
  final BorderSide? side;
  final double? elevation;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? labelPadding;
  final Function()? onTap;

  const DefaultActionChip(
      {Key? key,
      this.title,
      this.color = AppColors.purple50,
      this.titleColor = AppColors.white,
      this.disabledColor = AppColors.sand,
      this.fontSize = 14,
      this.avatar,
      this.onTap,
      this.side,
      this.iconColor,
      this.icon,
      this.elevation = 3,
      this.padding,
      this.labelPadding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: DefaultText(
        title ?? '',
        color: titleColor,
        fontSize: fontSize,
        textAlign: TextAlign.center,
      ),
      labelPadding: labelPadding ??
          const EdgeInsets.only(top: 1, bottom: 1, left: 4, right: 8),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 6),
      onPressed: onTap,
      backgroundColor: color,
      surfaceTintColor: color,
      disabledColor: disabledColor,
      elevation: elevation,
      shadowColor: color,
      avatar: avatar ??
          (icon != null ? Icon(icon, color: iconColor ?? titleColor) : null),
      side: side,
    );
  }
}
