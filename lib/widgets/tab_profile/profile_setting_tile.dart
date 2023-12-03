import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/model/database/users/database_user.dart';
import 'package:living_room/state/screen/app_base/app_base_cubit.dart';
import 'package:living_room/state/screen/app_base/app_base_state.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/util/general_image_picker.dart';
import 'package:living_room/widgets/default/default_avatar.dart';
import 'package:living_room/widgets/default/default_card.dart';
import 'package:living_room/widgets/default/default_input_field.dart';
import 'package:living_room/widgets/default/default_slider.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/general/flat_action_chip.dart';
import 'package:living_room/widgets/spacers.dart';

class ProfileSettingsTile extends StatelessWidget {
  const ProfileSettingsTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultCard(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const VerticalSpacer.of20(),
        _picture(context),
        const VerticalSpacer.of40(),
        _name(context),
        const VerticalSpacer.of10(),
        _email(context),
      ],
    ));
  }

  Widget _picture(BuildContext context) {
    return BlocBuilder<AppBaseCubit, AppBaseState>(
        buildWhen: (previous, current) =>
            previous.currentDbUser?.photoUrl != current.currentDbUser?.photoUrl,
        builder: (context, state) {
          return DefaultAvatar(
            url: state.currentDbUser?.photoUrl,
            radius: 70,
            showInitialTextAbovePicture: true,
            foregroundColor: AppColors.purple.withOpacity(0.2),
            initialsText:
                '\n\n\n\n\n${context.loc?.globalEdit}\n✎',
            onTap: () => _onPictureTap(context),
          );
        });
  }

  Widget _name(BuildContext context) {
    return BlocBuilder<AppBaseCubit, AppBaseState>(
        buildWhen: (previous, current) =>
            previous.currentDbUser?.displayName !=
            current.currentDbUser?.displayName,
        builder: (context, state) {
          onPressed() {
            _showNameModifierSheet(
                context: context,
                title: context.loc?.settingsScreenNameModification,
                infoText: context.loc?.settingsScreenNameSetDescription,
                user: state.currentDbUser,
                onValueChanged: (value) {
                  context.cubits.profName.modifyNewDisplayName(value);
                },
                onDone: (value) {
                  if (value != null) {
                    context.cubits.profName.uploadDisplayName();
                  }
                });
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FlatActionChip(
              text: state.currentDbUser?.displayName,
              fontSize: 20,
              paddingBetween: 10,
              leadIcon: Icons.edit_rounded,
              onGeneralTap: onPressed,
            ),
          );
        });
  }

  Widget _email(BuildContext context) {
    return FlatActionChip(
        text: context.states.base.currentAuthUser?.email,
        onGeneralTap: () => context.hidePreviousShowNewSnackBar(
            context.loc?.settingsScreenEmailNotModifiable ?? ''));
  }

  void _onPictureTap(BuildContext context) {
    onApprovalDone(bool? modify) {
      if (modify == true) {
        context.cubits.profPic.uploadPicture();
      }
    }

    onModificationDone(String? imagePath) {
      if (imagePath != null) {
        context.cubits.profPic.modifyNewPictureUrl(imagePath);
      }
    }

    GeneralImagePicker(
      context: context,
      pickSheetTitle: context.loc?.settingsScreenPictureModification,
      approveSheetTitle: context.loc?.settingsScreenPictureModification,
      approveSheetDescription: context.loc?.settingsScreenPictureReallyModify,
      pickSheetInfo: context.loc?.settingsScreenPictureSetDescription,
      approveSheetInfo: context.loc?.settingsScreenPictureCantBeUndone,
      currentUrl: context.states.base.currentDbUser?.photoUrl,
      onChooseDone: onModificationDone,
      onApprovalDone: onApprovalDone
    ).show();
  }

  void _showNameModifierSheet(
      {required BuildContext context,
      Function? onDone,
      Function? onValueChanged,
      String? title,
      String? infoText,
      DatabaseUser? user}) {
    String input = user?.displayName ?? '';
    List<Widget> content = [
      if (title != null) ...[
        DefaultText(
          title,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          textAlign: TextAlign.center,
        ),
        const VerticalSpacer.of23()
      ],
      DefaultInputField(
        callback: (value) {
          if (onValueChanged != null) onValueChanged(value);
        },
        maxLength: 50,
        hintText: user?.displayName,
        textInputAction: TextInputAction.done,
        suffixIcon: Icons.people,
        textColor: AppColors.purple,
        defaultBorderColor: AppColors.grey2,
        selectedBorderColor: AppColors.purple,
      ),
      const VerticalSpacer.of20(),
      DefaultSlider(
        onConfirmation: () => Navigator.of(context)
            .pop(input != '' ? input : user?.displayName ?? ''),
        title: context.loc?.globalApproveSlide,
      )
    ];

    context.showBottomSheet(
        children: content,
        onDone: onDone,
        extraIcon: infoText != null ? Icons.help_outline : null,
        onExtraIconTap: () => context.showInfoSheet(infoText ?? ''));
  }
}
