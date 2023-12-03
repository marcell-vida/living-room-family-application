import 'package:flutter/material.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_text.dart';

class DefaultTextButton extends StatelessWidget {
  final Function()? onPressed;
  final String? text;
  final Color? textColor;
  final double fontSize;
  final TextAlign textAlign;

  const DefaultTextButton(
      {Key? key,
      this.onPressed,
      this.textColor,
      this.text,
      this.fontSize = 14,
      this.textAlign = TextAlign.start})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: const Size(0, 0)),
        onPressed: onPressed ?? () {},
        onLongPress: () {},
        child: DefaultText(
          text ?? '',
          textAlign: textAlign,
          overflow: TextOverflow.fade,
          color: textColor ?? AppColors.purple,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ));
  }
}
