import 'package:flutter/material.dart';
import 'package:living_room/util/constants.dart';

class DefaultContainer extends StatelessWidget {
  final Widget? child;
  final List<Widget>? children;
  final Color borderColor;
  final Color backgroundColor;
  final bool paddingLess;

  const DefaultContainer(
      {super.key,
      this.child,
      this.children,
      this.borderColor = AppColors.purple,
      this.backgroundColor = Colors.transparent,
      this.paddingLess = false});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: paddingLess == true ? null : AppPaddings.defaultContainer,
        decoration: BoxDecoration(
            color: backgroundColor,
            border:
                Border.all(color: borderColor, width: Constants.borderWidth),
            borderRadius: Constants.borderRadius),
        child: child ??
            Column(
              children: children ?? <Widget>[],
            ));
  }
}
