import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:living_room/util/constants.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';

class DefaultSlider extends StatelessWidget {
  final String? title;
  final Color backgroundColorEnd;
  final Color foregroundColor;
  final Color sliderButtonColor;
  final Color titleColor;
  final bool stickToEnd;
  final Function()? onConfirmation;

  const DefaultSlider(
      {super.key,
      this.title,
      this.backgroundColorEnd = AppColors.purple,
      this.foregroundColor = AppColors.purple,
      this.sliderButtonColor = AppColors.white,
      this.titleColor = AppColors.purple,
      this.stickToEnd = true,
      this.onConfirmation});

  @override
  Widget build(BuildContext context) {
    return ConfirmationSlider(
      backgroundShape: Constants.borderRadius,
      text: title ?? '',
      backgroundColorEnd: backgroundColorEnd,
      textStyle: GoogleFonts.inter(
          color: titleColor, fontWeight: FontWeight.w600, fontSize: 14),
      sliderButtonContent: Icon(Icons.keyboard_double_arrow_right,
          color: sliderButtonColor, size: 35),
      foregroundColor: foregroundColor,
      stickToEnd: stickToEnd,
      onConfirmation: onConfirmation ?? () {},
      height: 48,
    );
  }
}
