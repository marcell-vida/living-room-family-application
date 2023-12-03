import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/state/screen/profile/notification_settings_bloc.dart';
import 'package:living_room/state/screen/profile/password_settings_bloc.dart';
import 'package:living_room/state/sheet/profile/profile_name_bloc.dart';
import 'package:living_room/state/sheet/profile/profile_picture_bloc.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/util/utils.dart';
import 'package:living_room/widgets/default/default_button.dart';
import 'package:living_room/widgets/default/default_card.dart';
import 'package:living_room/widgets/default/default_container.dart';
import 'package:living_room/widgets/default/default_input_field.dart';
import 'package:living_room/widgets/default/default_slider.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/default/default_toggle_switch.dart';
import 'package:living_room/widgets/general/loading_switch.dart';
import 'package:living_room/widgets/general/no_overscroll_indicator_list_behavior.dart';
import 'package:living_room/widgets/spacers.dart';
import 'package:living_room/widgets/tab_profile/password_change_sheet.dart';
import 'package:living_room/widgets/tab_profile/profile_setting_tile.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfilePictureCubit>(
            create: (context) => ProfilePictureCubit(
                databaseService: context.services.database,
                authenticationService: context.services.authentication,
                storageService: context.services.storage)),
        BlocProvider<ProfileNameCubit>(
            create: (context) => ProfileNameCubit(
                databaseService: context.services.database,
                authenticationService: context.services.authentication))
      ],
      child: Builder(builder: (context) {
        return MultiBlocListener(
          listeners: [
            BlocListener<ProfilePictureCubit, ProfilePictureState>(
                listenWhen: (previous, current) =>
                    previous.pictureUpdateStatus != current.pictureUpdateStatus,
                listener: (BuildContext context, state) {
                  if (state.pictureUpdateStatus == ProcessStatus.processing) {
                    context.hidePreviousShowNewSnackBar(
                        context.loc?.globalProcessingRequest);
                  } else if (state.pictureUpdateStatus ==
                      ProcessStatus.successful) {
                    context.hidePreviousShowNewSnackBar(
                        context.loc?.globalSuccessfulOperation);
                  } else if (state.pictureUpdateStatus ==
                      ProcessStatus.unsuccessful) {
                    context.hidePreviousShowNewSnackBar(
                        context.loc?.globalUnsuccessfulOperation);
                  }
                }),
          ],
          child: _optionsList(context),
        );
      }),
    );
  }

  Widget _optionsList(BuildContext context) {
    return ScrollConfiguration(
        behavior: NoOverscrollIndicatorBehavior(),
        child: ClipRRect(
          borderRadius: Constants.borderRadius,
          child: SizedBox(
            child: ListView(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              children: [
                const ProfileSettingsTile(),

                /// notifications
                DefaultCard(
                  child: Column(
                    children: [
                      DefaultContainer(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DefaultText(
                                context.loc?.profileTabNotifications ?? '',
                                color: AppColors.purple,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              BlocProvider<NotificationSettingsCubit>(
                                  create: (BuildContext context) =>
                                      NotificationSettingsCubit(
                                          databaseService:
                                              context.services.database,
                                          authenticationService:
                                              context.services.authentication),
                                  child: BlocBuilder<NotificationSettingsCubit,
                                          NotificationSettingsState>(
                                      builder: (context, state) {
                                    return LoadingSwitch(
                                      switchState: state.user?.generalNotification,
                                      processStatus: state.saveStatus,
                                      onChanged: (_) => context
                                          .cubits.notificationSettings
                                          .toggleNotification(),
                                    );
                                  }))
                            ],
                          ),
                        ),
                      ),
                      const VerticalSpacer.of10(),
                      DefaultText(
                        context.loc?.profileTabNotificationsDescription ?? '',
                        color: AppColors.grey2,
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
                DefaultCard(
                  child: Column(
                    children: [
                      DefaultButton(
                          color: AppColors.sand,
                          text: context.loc?.profileChangePassword,
                          elevation: 3,
                          callback: () {
                            context.showBottomSheet(
                                children: [PasswordChangeSheet()],
                                onDone: (bool? result) {
                                  if (result == true) {
                                    context.cubits.passwordSettings
                                        .setPassword();
                                  }
                                });
                          }),
                      const VerticalSpacer.of20(),
                      DefaultButton(
                          color: AppColors.red,
                          text: context.loc?.globalSignOut,
                          elevation: 3,
                          callback: () => context.cubits.base.signOut()),
                    ],
                  ),
                )
                // OtherSettingsTile()
              ],
            ),
          ),
        ));
  }
}
