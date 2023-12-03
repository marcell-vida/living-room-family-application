import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:living_room/util/constants.dart';

class BlurredCard extends StatelessWidget {
  final double? height;
  final double? width;
  final Widget? child;

  const BlurredCard({super.key, this.height, this.width, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Colors.transparent,
      child: IntrinsicHeight(
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: Constants.borderRadius,
                  border: Border.all(
                      color: AppColors.whiteOp30,
                      width: Constants.borderWidth),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppColors.white.withOpacity(0.15),
                      AppColors.white.withOpacity(0.05)
                    ],
                  )),
            ),
            Padding(
              padding: AppPaddings.cardAllAround,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [if (child != null) child!],
              ),
            )
          ],
        ),
      ),
    );
  }
}
