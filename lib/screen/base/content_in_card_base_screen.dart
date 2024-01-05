import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:living_room/screen/base/app_base_screen.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/general/blurred_card.dart';
import 'package:living_room/widgets/general/no_overscroll_indicator_list_behavior.dart';

abstract class ContentInCardBaseScreen extends AppBaseScreen {
  const ContentInCardBaseScreen({super.key});

  @nonVirtual
  @override
  Widget body(BuildContext context) {
    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.purple, AppColors.sand],
          )),
          child: SafeArea(
            child: ScrollConfiguration(
              behavior: NoOverscrollIndicatorBehavior(),
              child: SingleChildScrollView(
                padding: AppPaddings.screenSide,
                child: BlurredCard(
                  child: onBuild(context),
                ),
              ),
            ),
          )),
    );
  }

  Widget onBuild(BuildContext context);
}
