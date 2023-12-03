import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/screen/base/content_in_card_base_screen.dart';
import 'package:living_room/state/screen/app_base/app_base_cubit.dart';
import 'package:living_room/state/screen/app_base/app_base_state.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_button.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/general/circle_shape.dart';
import 'package:living_room/widgets/spacers.dart';

class BannedScreen extends ContentInCardBaseScreen {
  const BannedScreen({Key? key}) : super(key: key);

  @override
  Widget onBuild(BuildContext context) {
    return Builder(builder: (context) {
      return BlocBuilder<AppBaseCubit, AppBaseState>(
          buildWhen: (previous, current) =>
              previous.currentUserStatus != current.currentUserStatus,
          builder: (context, state) {
            return WillPopScope(
              onWillPop: () async {
                return state.currentUserStatus != CurrentUserStatus.userBanned;
              },
              child: Column(
                children: [
                  DefaultText(
                    context.loc?.bannedScreenBeingBanned ?? '',
                    color: AppColors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                  const VerticalSpacer.of40(),
                  const CircleShape(
                    backgroundColor: Colors.transparent,
                    borderColor: AppColors.purple,
                    borderWidth: Constants.borderWidth + 2,
                    padding: 25,
                    child: Icon(
                      Icons.person_off_outlined,
                      size: 65,
                      color: AppColors.purple,
                    ),
                  ),
                  const VerticalSpacer.of23(),
                  DefaultText(
                    context.loc?.bannedScreenBeingBannedDescription(
                            context.cubits.base.getCurrentAuthUser?.email ??
                                '') ??
                        '',
                    textAlign: TextAlign.center,
                    color: AppColors.white,
                  ),
                  const VerticalSpacer.of23(),
                  BlocBuilder<AppBaseCubit, AppBaseState>(
                      buildWhen: (previous, current) =>
                          previous.currentUserStatus !=
                          current.currentUserStatus,
                      builder: (context, authState) {
                        return DefaultButton(
                            color: AppColors.purple,
                            text: context.loc?.globalSignOut,
                            callback: () async {
                              context.cubits.base.signOut();
                            });
                      })
                ],
              ),
            );
          });
    });
  }
}
