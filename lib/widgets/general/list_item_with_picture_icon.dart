import 'package:flutter/material.dart';
import 'package:living_room/extension/dart/string_extension.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_avatar.dart';
import 'package:living_room/widgets/default/default_container.dart';
import 'package:living_room/widgets/default/default_text.dart';

class ListItemWithPictureIcon extends StatelessWidget {
  final String? photoUrl;
  final String? title;
  final IconData? icon;
  final Widget? endWidget;
  final Color borderColor;
  final Color? titleColor;
  final Color? avatarColor;
  final Color backgroundColor;
  final Color? iconColor;
  final void Function()? onTap;

  const ListItemWithPictureIcon(
      {super.key,
      this.photoUrl,
      this.title,
      this.icon,
        this.endWidget,
      this.onTap,
      this.borderColor = AppColors.purple,
      this.backgroundColor = Colors.transparent,
        this.titleColor,
        this.avatarColor,
      this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DefaultContainer(
        borderColor: borderColor,
        backgroundColor: backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (photoUrl.isNotEmptyOrNull)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DefaultAvatar(
                      borderColor: avatarColor ?? borderColor,
                      url: photoUrl,
                      radius: 18,
                    ),
                  ),
                if (title.isNotEmptyOrNull)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 50),
                    child: DefaultText(
                      title ?? '',
                      textAlign: TextAlign.center,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? borderColor,
                    ),
                  ),
                if (icon != null) ...[
                  Align(
                      alignment: Alignment.centerRight,
                      child: Icon(icon, color: iconColor ?? borderColor))
                ],
                if(endWidget != null) Align(
                    alignment: Alignment.centerRight,
                    child: endWidget!)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
