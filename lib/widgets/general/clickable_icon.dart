import 'package:flutter/material.dart';
import 'package:living_room/util/constants.dart';

class ClickableIcon extends StatelessWidget {
  final void Function()? onTap;
  final IconData? icon;
  final Color color;
  final double size;

  const ClickableIcon(
      {Key? key,
      this.onTap,
      this.icon,
      this.color = AppColors.purple,
      this.size = 30})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: color,
          child: IconButton(
            onPressed: onTap ?? () {},
            icon: Icon(
              icon,
              size: size,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
