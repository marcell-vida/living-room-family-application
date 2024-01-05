import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/model/database/families/family_member_goal.dart';
import 'package:living_room/state/sheet/family/goal_details_bloc.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/util/general_image_picker.dart';
import 'package:living_room/widgets/default/default_avatar.dart';
import 'package:living_room/widgets/default/default_button.dart';
import 'package:living_room/widgets/default/default_container.dart';
import 'package:living_room/widgets/default/default_input_field.dart';
import 'package:living_room/widgets/default/default_slider.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/general/titled_divider.dart';
import 'package:living_room/widgets/spacers.dart';

class GoalDetailsEditingContent extends StatelessWidget {
  final GoalDetailsCubit goalDetailsCubit;
  final String? title;
  final String? slider;
  final TextEditingController textEditingController = TextEditingController();

  GoalDetailsEditingContent(
      {super.key, required this.goalDetailsCubit, this.title, this.slider});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoalDetailsCubit, GoalDetailsState>(
        builder: (editGoalCubitContext, state) {
      if (goalDetailsCubit.existingGoalId != null &&
          state.existingGoal == null) {
        /// goal exists but the data is not loaded yet
        return const CircularProgressIndicator(color: AppColors.purple);
      } else {
        return _content(editGoalCubitContext);
      }
    });
  }

  Widget _content(BuildContext context) {
    return Column(children: [
      DefaultText(
        title ?? '',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        textAlign: TextAlign.center,
      ),
      ..._photoSection(context),
      ..._dataSection(context),
      ..._pointsSection(context),
      ..._approveSection(context)
    ]);
  }

  /// [FamilyMemberGoal] photo
  List<Widget> _photoSection(
    BuildContext context,
  ) {
    String existingPhotoUrl =
        goalDetailsCubit.state.existingGoal?.photoUrl ?? '';

    String uploadPhotoPath = goalDetailsCubit.state.goalPhotoUploadPath ?? '';

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
                currentUrl:
                    goalDetailsCubit.state.goalPhotoUploadPath == null &&
                            existingPhotoUrl.isNotEmpty
                        ? existingPhotoUrl
                        : null,
                pickSheetTitle: context.loc?.tasksTabEditTaskPhotoModification,
                approveSheetTitle:
                    context.loc?.tasksTabEditTaskPhotoModification,
                pickSheetInfo: context.loc?.familiesTabCreatePhotoPickInfo,
                approveSheetInfo: context.loc?.familiesTabCreatePhotoPickInfo,
                approveSheetDescription: context.loc?.tasksTabEditTaskSetThis,
                currentPath: goalDetailsCubit.state.goalPhotoUploadPath,
                onChooseDone: (String? path) =>
                    goalDetailsCubit.setPhotoPath(path),
                onApprovalDone: (bool? approve) =>
                    goalDetailsCubit.approveGoalPhotoPath(approve)).show()),
      ),
    ];
  }

  /// Name and description
  List<Widget> _dataSection(BuildContext context) {
    return <Widget>[
      ..._divider(title: context.loc?.familiesTabCreateBasics),
      _generalPadding(
        child: DefaultInputField(
          callback: (value) {
            goalDetailsCubit.setTitle(value);
          },
          initialValue: goalDetailsCubit.state.existingGoal?.title,
          maxLength: 50,
          hintText: context.loc?.tasksTabEditTitle,
          textInputAction: TextInputAction.done,
          leadIcon: Icons.title,
          textColor: AppColors.purple,
          defaultBorderColor: AppColors.grey2,
          selectedBorderColor: AppColors.purple,
        ),
      ),
      const VerticalSpacer.of20(),
      _generalPadding(
        child: DefaultInputField(
          callback: (value) {
            goalDetailsCubit.setDescription(value);
          },
          initialValue: goalDetailsCubit.state.existingGoal?.description,
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

  /// Number of points section
  List<Widget> _pointsSection(BuildContext context) {
    int? numberOfPoints = goalDetailsCubit.state.points ??
        goalDetailsCubit.state.existingGoal?.points;

    textEditingController.text =
        numberOfPoints != null ? numberOfPoints.toString() : '';

    textEditingController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: textEditingController.text.length,
      ),
    );
    List<int> quickValues = [10, 20, 50, 100, 200];
    return <Widget>[
      ..._divider(title: context.loc?.tasksTabEditPoints),
      _generalPadding(children: <Widget>[
        DefaultInputField(
          callback: (value) {
            int? points = int.tryParse(value);
            goalDetailsCubit.setPoints(points);
          },
          maxLength: 50,
          hintText: context.loc?.tasksTabEditPoints,
          textInputAction: TextInputAction.done,
          leadIcon: Icons.title,
          textColor: AppColors.purple,
          defaultBorderColor: AppColors.grey2,
          selectedBorderColor: AppColors.purple,
          textInputFormatter: FilteringTextInputFormatter.digitsOnly,
          textInputType: TextInputType.number,
          textEditingController: textEditingController,
        ),
        const VerticalSpacer.of10(),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (int element in quickValues)
              GestureDetector(
                onTap: () {
                  textEditingController.text = '$element';
                  goalDetailsCubit.setPoints(element);
                },
                child: DefaultContainer(
                  backgroundColor: AppColors.purple,
                  child: DefaultText(
                    '$element',
                    color: AppColors.white,
                    fontSize: 16,
                  ),
                ),
              )
          ],
        )
      ]),
    ];
  }

  /// Approve modifications
  List<Widget> _approveSection(BuildContext context) {
    return <Widget>[
      ..._divider(),
      _generalPadding(children: [
        DefaultSlider(
          stickToEnd: false,
          title: slider,
          onConfirmation: () {
            String name = goalDetailsCubit.state.title ??
                goalDetailsCubit.state.existingGoal?.title ??
                '';
            if (name.isNotEmpty) {
              goalDetailsCubit.save();
            } else {
              context.showInfoSheet(
                  context.loc?.familiesTabCreateNameShouldNotBeEmpty ?? '');
            }
          },
        ),
        if (goalDetailsCubit.state.existingGoal != null) ...[
          const VerticalSpacer.of40(),
          DefaultButton(
              text: context.loc?.globalDiscardModifications,
              textColor: AppColors.red,
              color: AppColors.white,
              borderColor: AppColors.red,
              callback: () => goalDetailsCubit.setMode(GoalDetailsMode.viewing))
        ],
      ])
    ];
  }

  Widget _generalPadding(
      {Widget? child,
      List<Widget>? children,
      double horizontal = 10,
      double vertical = 0,
      MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: child ??
          Column(
              mainAxisAlignment: mainAxisAlignment, children: children ?? []),
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
