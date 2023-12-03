import 'package:flutter/material.dart';
import 'package:living_room/util/constants.dart';

class CircleShape extends StatelessWidget {
  final Color backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final Widget? child;
  final double? radius;
  final double? padding;

  const CircleShape(
      {super.key,
      this.backgroundColor = Colors.transparent,
      this.borderColor,
      this.borderWidth = Constants.borderWidth,
      this.child,
      this.radius,
      this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: radius != null ? (radius! * 2) : null,
        padding: EdgeInsets.all(padding ?? 0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
            border: borderColor == null
                ? null
                : Border.all(color: borderColor!, width: borderWidth)),
        child: child);
  }
}
