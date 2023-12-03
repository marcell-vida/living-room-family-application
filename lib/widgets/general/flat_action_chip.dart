import 'package:flutter/material.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_text_button.dart';

class FlatActionChip extends StatelessWidget {
  final IconData? leadIcon;
  final IconData? endIcon;
  final Color textColor;
  final Color leadIconColor;
  final Color endIconColor;
  final String? text;
  final double fontSize;
  final double paddingBetween;
  final TextAlign textAlign;
  final Function()? onGeneralTap;
  final Function()? leadIconTap;
  final Function()? endIconTap;

  const FlatActionChip(
      {super.key,
      this.leadIcon,
      this.endIcon,
      this.textColor = AppColors.purple,
      this.leadIconColor = AppColors.purple,
      this.paddingBetween = 0,
      this.text,
      this.fontSize = 14,
      this.onGeneralTap,
      this.textAlign = TextAlign.center,
      this.leadIconTap,
      this.endIconTap,
      this.endIconColor = AppColors.purple});

  MainAxisAlignment get alignment {
    if(textAlign == TextAlign.start) {
      return MainAxisAlignment.start;
    } else if(textAlign == TextAlign.center) {
      return MainAxisAlignment.center;
    }    else {
      return MainAxisAlignment.end;
    }  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: alignment,
      children: [
        if (leadIcon != null)
          GestureDetector(
            onTap: leadIconTap ?? onGeneralTap,
            child: Icon(
              leadIcon,
              size: fontSize,
              color: leadIconColor,
            ),
          ),
        if (text != null)
          Padding(
            padding:
            EdgeInsets.symmetric(horizontal: paddingBetween),
            child: DefaultTextButton(
                text: text,
                textAlign: textAlign,
                textColor: textColor,
                fontSize: fontSize,
                onPressed: onGeneralTap),
          ),
        if (endIcon != null)
          GestureDetector(
            onTap: endIconTap ?? onGeneralTap,
            child: Icon(
              endIcon,
              color: endIconColor,
            ),
          ),
      ],
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        if (leadIcon != null)
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: leadIconTap ?? onGeneralTap,
              child: Icon(
                leadIcon,
                size: fontSize,
                color: leadIconColor,
              ),
            ),
          ),
        if (text != null)
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: fontSize + paddingBetween),
              child: DefaultTextButton(
                  text: text,
                  textAlign: textAlign,
                  textColor: textColor,
                  fontSize: fontSize,
                  onPressed: onGeneralTap),
            ),
          ),
        if (endIcon != null)
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: endIconTap ?? onGeneralTap,
              child: Icon(
                endIcon,
                color: endIconColor,
              ),
            ),
          ),
      ],
    );
  }
}
