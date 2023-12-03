import 'package:flutter/material.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/screen/base/content_in_card_base_screen.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_button.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/spacers.dart';

class WrongRouteScreen extends ContentInCardBaseScreen {
  const WrongRouteScreen({Key? key}) : super(key: key);

  @override
  Widget onBuild(BuildContext context) {
    return Column(
      children: [
        DefaultText(
          context.loc?.wrongRouteScreenPageNotFound ?? '',
          color: AppColors.white,
          fontSize: 25,
          fontWeight: FontWeight.w600,
        ),
        const VerticalSpacer.of40(),
        DefaultButton(
            text: context.loc?.globalBack,
            callback: () => Navigator.of(context).pop(),
            color: AppColors.purple)
      ],
    );
  }
}
