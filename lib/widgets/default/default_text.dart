import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:living_room/util/constants.dart';

class DefaultText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final FontWeight fontWeight;
  final double fontSize;
  final Color color;
  final TextOverflow? overflow;

  const DefaultText(this.text,
      {Key? key,
      this.textAlign = TextAlign.left,
      this.fontWeight = FontWeight.w600,
      this.fontSize = 14.0,
      this.color = AppColors.black,
      this.overflow})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: textAlign,
        overflow: overflow,
        softWrap: true,
        style: GoogleFonts.inter(
            fontWeight: fontWeight, fontSize: fontSize, color: color));
  }
}
