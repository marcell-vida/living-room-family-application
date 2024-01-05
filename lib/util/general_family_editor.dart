import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/extension/modify_family_process.dart';
import 'package:living_room/model/database/users/database_user.dart';
import 'package:living_room/state/object/family_bloc.dart';
import 'package:living_room/state/object/member_bloc.dart';
import 'package:living_room/state/sheet/family/edit_family_bloc.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/util/general_image_picker.dart';
import 'package:living_room/util/utils.dart';
import 'package:living_room/widgets/default/default_avatar.dart';
import 'package:living_room/widgets/default/default_button.dart';
import 'package:living_room/widgets/default/default_input_field.dart';
import 'package:living_room/widgets/default/default_slider.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/general/list_item_with_picture_icon.dart';
import 'package:living_room/widgets/general/titled_divider.dart';
import 'package:living_room/widgets/spacers.dart';

class GeneralFamilyEditor {
  final BuildContext defaultContext;
  final FamilyCubit? existingFamilyCubit;
  final String? title;
  final String? slider;

  GeneralFamilyEditor(
      {required this.defaultContext,
      this.existingFamilyCubit,
      this.title,
      this.slider});

  void show() {
    defaultContext.showBottomSheet(children: [_sheetContent]);
  }

  Widget get _sheetContent {
    return BlocProvider(
      create: (_) => EditFamilyCubit(
          existingFamilyCubit: existingFamilyCubit,
          databaseService: defaultContext.services.database,
          authenticationService: defaultContext.services.authentication,
          storageService: defaultContext.services.storage),
      child: Builder(builder: (cubitContext) {
        return BlocListener<EditFamilyCubit, EditFamilyState>(
          listener: (listenerContext, listenerState) {
            if (listenerState.addInviteStatus == ProcessStatus.unsuccessful) {
              cubitContext.showInfoSheet(
                  cubitContext.loc?.familiesTabCreateUserAddedOrNull ?? '');
            }
          },
          child: BlocBuilder<EditFamilyCubit, EditFamilyState>(
              builder: (cubitContext, state) {
            return Column(
                children: state.saveGeneralStatus != ProcessStatus.idle
                    ? _processingContent(
                        cubitContext, cubitContext.cubits.editFamily)
                    : _editingContent(
                        cubitContext, cubitContext.cubits.editFamily));
          }),
        );
      }),
    );
  }

  List<Widget> _processingContent(BuildContext context, EditFamilyCubit cubit) {
    return [
      if (title != null) ...[
        DefaultText(
          title ?? '',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          textAlign: TextAlign.center,
        ),
        const VerticalSpacer.of40(),
      ],
      if (cubit.state.saveDetailedStatus != null)
        for (ModifyFamilyProcess current
            in cubit.state.saveDetailedStatus!.keys)
          _processStatusContainer(context, current.getTitle(context),
              cubit.state.saveDetailedStatus![current]),
      if (cubit.state.saveGeneralStatus == ProcessStatus.successful ||
          cubit.state.saveGeneralStatus == ProcessStatus.unsuccessful)
        Padding(
          padding: const EdgeInsets.all(10),
          child: DefaultButton(
              text: context.loc?.generalDone,
              callback: () {
                Navigator.of(context).pop();
              }),
        )
    ];
  }

  Widget _processStatusContainer(
      BuildContext context, String? title, ProcessStatus? status) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
                color: AppColors.purple, width: Constants.borderWidth),
            borderRadius: Constants.borderRadius),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (title != null && title.isNotEmpty)
              Expanded(
                child: DefaultText(
                  title,
                  textAlign: TextAlign.left,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.purple,
                ),
              ),
            _processIndicator(status)
          ],
        ),
      ),
    );
  }

  Widget _processIndicator(ProcessStatus? status) {
    if (status == null) {
      return const Icon(
        Icons.warning_amber,
        color: AppColors.purple,
      );
    }
    if (status == ProcessStatus.processing) {
      return const CircularProgressIndicator(
        color: AppColors.purple,
      );
    }
    if (status == ProcessStatus.unsuccessful) {
      return const Icon(
        Icons.close,
        color: AppColors.purple,
      );
    }
    if (status == ProcessStatus.successful) {
      return const Icon(
        Icons.done,
        color: AppColors.purple,
      );
    }
    return const Icon(
      Icons.remove,
      color: AppColors.purple,
    );
  }

  List<Widget> _editingContent(BuildContext context, EditFamilyCubit cubit) {
    return [
      DefaultText(
        title ?? '',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        textAlign: TextAlign.center,
      ),
      ..._photoSection(context, cubit),
      ..._dataSection(context, cubit),
      ..._memberSection(context, cubit),
      ..._inviteSection(context, cubit),
      ..._approveSection(context, cubit)
    ];
  }

  /// [Family] photo
  List<Widget> _photoSection(BuildContext context, EditFamilyCubit cubit) {
    if (cubit.existingFamilyCubit != null &&
        cubit.state.existingFamilyState?.family == null) {
      // family exists but the data is not loaded yet
      return [const CircularProgressIndicator(color: AppColors.purple)];
    } else {
      String existingPhotoUrl =
          cubit.state.existingFamilyState?.family?.photoUrl ?? '';

      String uploadPhotoPath = cubit.state.photoUploadPath ?? '';

      return <Widget>[
        ..._divider(title: context.loc?.familiesTabCreatePhoto),
        if (existingPhotoUrl.isNotEmpty || uploadPhotoPath.isNotEmpty) ...[
          DefaultAvatar(
            url: existingPhotoUrl.isNotEmpty ? existingPhotoUrl : null,
            radius: 110,
            borderColor: AppColors.purple,
            borderWidth: Constants.borderWidth,
            child: uploadPhotoPath.isNotEmpty
                ? Image.file(
                    File(uploadPhotoPath),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          const VerticalSpacer.of10()
        ],
        _generalPadding(
          child: DefaultButton(
              text: context.loc?.familiesTabCreatePhotoEdit,
              callback: () => GeneralImagePicker(
                  context: context,
                  currentUrl: cubit.state.photoUploadPath == null &&
                          existingPhotoUrl.isNotEmpty
                      ? existingPhotoUrl
                      : null,
                  pickSheetTitle: context
                      .loc?.familiesTabCreatePhotoFamilyPhotoModification,
                  approveSheetTitle: context
                      .loc?.familiesTabCreatePhotoFamilyPhotoModification,
                  pickSheetInfo: context.loc?.familiesTabCreatePhotoPickInfo,
                  approveSheetInfo: context.loc?.familiesTabCreatePhotoPickInfo,
                  approveSheetDescription:
                      context.loc?.familiesTabCreatePhotoSetThis,
                  currentPath: context.states.createFamily.photoUploadPath,
                  onChooseDone: (String? path) => cubit.setPhotoTempPath(path),
                  onApprovalDone: (bool? approve) =>
                      cubit.approvePhotoPath(approve)).show()),
        ),
      ];
    }
  }

  /// Name and description
  List<Widget> _dataSection(BuildContext context, EditFamilyCubit cubit) {
    if (cubit.existingFamilyCubit != null &&
        cubit.state.existingFamilyState?.family == null) {
      // family exists but the data is not loaded yet
      return [const CircularProgressIndicator(color: AppColors.purple)];
    } else {
      return <Widget>[
        ..._divider(title: context.loc?.familiesTabCreateBasics),
        _generalPadding(
          child: DefaultInputField(
            callback: (value) {
              debugPrint('_dataSection: input field callback with $value');
              cubit.setName(value);
            },
            initialValue: cubit.state.existingFamilyState?.family?.name,
            maxLength: 50,
            hintText: context.loc?.familiesTabCreateNameOfFamily,
            textInputAction: TextInputAction.done,
            leadIcon: Icons.family_restroom_outlined,
            textColor: AppColors.purple,
            defaultBorderColor: AppColors.grey2,
            selectedBorderColor: AppColors.purple,
          ),
        ),
        const VerticalSpacer.of20(),
        _generalPadding(
          child: DefaultInputField(
            callback: (value) {
              debugPrint('_dataSection: input field callback with $value');
              cubit.setDescription(value);
            },
            initialValue: cubit.state.existingFamilyState?.family?.description,
            minLines: 2,
            maxLines: 10,
            maxLength: 400,
            hintText: context.loc?.familiesTabCreateDescriptionOfFamily,
            textInputAction: TextInputAction.done,
            leadIcon: Icons.pending_outlined,
            textColor: AppColors.purple,
            defaultBorderColor: AppColors.grey2,
            selectedBorderColor: AppColors.purple,
          ),
        ),
      ];
    }
  }

  /// FamilyMembers
  List<Widget> _memberSection(BuildContext context, EditFamilyCubit cubit) {
    if (cubit.existingFamilyCubit == null) return <Widget>[];

    Iterable<DatabaseUser> iterList = [
      for (MemberCubit current in cubit.existingFamilyCubit!.memberCubits)
        if (current.state.user != null) current.state.user!
    ];

    if (iterList.isEmpty) return <Widget>[];

    return <Widget>[
      ..._divider(title: context.loc?.familiesTabCreateMembers),
      _generalPadding(children: [
        for (DatabaseUser element in iterList)
          _generalPadding(
              vertical: 6,
              child: ListItemWithPictureIcon(
                title: element.displayName,
                photoUrl: element.photoUrl,
              )),
        const VerticalSpacer.of20(),
      ])
    ];
  }

  /// Invites, Invite message
  List<Widget> _inviteSection(BuildContext context, EditFamilyCubit cubit) {
    return <Widget>[
      ..._divider(title: context.loc?.familiesTabCreateInvitedMembers),
      _generalPadding(children: [
        if (cubit.state.eligibleInvitations != null &&
            cubit.state.eligibleInvitations!.isNotEmpty) ...[
          for (DatabaseUser current in cubit.state.eligibleInvitations!)
            _generalPadding(
                vertical: 6,
                child: ListItemWithPictureIcon(
                  title: current.displayName,
                  photoUrl: current.photoUrl,
                )),
          const VerticalSpacer.of20(),
        ],
        DefaultInputField(
          callback: (value) {
            cubit.setCurrentInvitation(value);
          },
          maxLength: 50,
          hintText: context.loc?.familiesTabCreateInvitee,
          initialValue: cubit.state.tempInvitationEmail,
          textInputAction: TextInputAction.next,
          leadIcon: Icons.people,
          textColor: AppColors.purple,
          defaultBorderColor: AppColors.grey2,
          selectedBorderColor: AppColors.purple,
        ),
        const VerticalSpacer.of10(),
        DefaultButton(
            text: context.loc?.globalAdd,
            callback: () => cubit.approveCurrentInvitation(null)),
        const VerticalSpacer.of40(),
        DefaultInputField(
          callback: (value) {
            cubit.setInvitationMessage(value);
          },
          hintText: context.loc?.familiesTabCreateInvitationMessage,
          textInputAction: TextInputAction.done,
          minLines: 3,
          maxLines: 10,
          maxLength: 400,
          leadIcon: Icons.message_outlined,
          textColor: AppColors.purple,
          defaultBorderColor: AppColors.grey2,
          selectedBorderColor: AppColors.purple,
        ),
      ])
    ];
  }

  /// Approve modifications
  List<Widget> _approveSection(BuildContext context, EditFamilyCubit cubit) {
    return <Widget>[
      ..._divider(),
      _generalPadding(children: [
        DefaultSlider(
          stickToEnd: false,
          title: slider,
          onConfirmation: () {
            String name = cubit.state.name ?? '';
            if (name.isNotEmpty) {
              cubit.save();
            } else {
              context.showInfoSheet(
                  context.loc?.familiesTabCreateNameShouldNotBeEmpty ?? '');
            }
          },
        ),
        if (existingFamilyCubit != null) ...[
          const VerticalSpacer.of60(),
          DefaultButton(
              leadIcon: Icons.delete,
              borderColor: AppColors.red,
              color: AppColors.white,
              textColor: AppColors.red,
              text: context.loc?.globalDelete,
              callback: () {
                //todo
              })
        ]
      ])
    ];
  }

  Widget _generalPadding(
      {Widget? child,
      List<Widget>? children,
      double horizontal = 10,
      double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: child ?? Column(children: children ?? []),
    );
  }

  List<Widget> _divider({String? title}) => <Widget>[
        const VerticalSpacer.of60(),
        TitledDivider(
          title: title,
        ),
        const VerticalSpacer.of10(),
      ];
}
