import 'package:flutter/material.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_container.dart';
import 'package:living_room/widgets/default/default_text.dart';

class DefaultExpansionTile extends StatelessWidget {
  final List<Widget>? children;
  final Color borderColor;
  final Color titleColor;
  final Color backgroundColor;
  final String? title;
  final Widget? leading;
  final bool borderLess;

  const DefaultExpansionTile(
      {super.key,
      this.children,
      this.borderColor = AppColors.purple,
      this.backgroundColor = Colors.transparent,
      this.titleColor = AppColors.purple,
      this.title,
      this.leading,
      this.borderLess = false});

  @override
  Widget build(BuildContext context) {
    return DefaultContainer(
      borderColor: borderLess == true ? Colors.transparent : borderColor,
      paddingLess: borderLess,
      backgroundColor: backgroundColor,
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
            leading: leading,
            childrenPadding: borderLess == true
                ? const EdgeInsets.symmetric(vertical: 20)
                : AppPaddings.defaultExpansionTile,
            iconColor: titleColor,
            collapsedIconColor: titleColor,
            title: DefaultText(
              title ?? '',
              textAlign: TextAlign.left,
              fontSize: 18,
              color: titleColor,
            ),
            children: [...?children]),
      ),
    );
  }
}
