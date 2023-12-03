import 'package:flutter/material.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/spacers.dart';

class DefaultCard extends StatelessWidget {
  final Color color;
  final Widget? child;
  final String? title;
  final IconData? iconData;

  const DefaultCard(
      {super.key,
      this.color = AppColors.white,
      this.child,
      this.title,
      this.iconData});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: Constants.borderRadius),
      color: color.withOpacity(0.9),
      child: Padding(
        padding: AppPaddings.cardAllAround,
        child: title != null
            ? Column(
                children: [
                  Stack(
                    children: [
                      if (iconData != null)
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(
                              iconData,
                              size: 20,
                            )),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: iconData != null ? 20 : 0),
                        child: Align(
                            alignment: Alignment.center,
                            child: DefaultText(
                              title!,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ],
                  ),
                  const VerticalSpacer.of40(),
                  if (child != null) child!
                ],
              )
            : child,
      ),
    );
  }
}
