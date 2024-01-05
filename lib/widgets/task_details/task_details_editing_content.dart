import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/extension/dart/datetime_extension.dart';
import 'package:living_room/state/sheet/family/task_details_bloc.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/util/general_image_picker.dart';
import 'package:living_room/widgets/default/default_avatar.dart';
import 'package:living_room/widgets/default/default_button.dart';
import 'package:living_room/widgets/default/default_container.dart';
import 'package:living_room/widgets/default/default_input_field.dart';
import 'package:living_room/widgets/default/default_slider.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/general/general_padding.dart';
import 'package:living_room/widgets/general/titled_divider.dart';
import 'package:living_room/widgets/spacers.dart';

class TaskDetailsEditingContent extends StatelessWidget {
  final TaskDetailsCubit taskDetailsCubit;
  final String? title;
  final String? slider;
  final BuildContext? defaultContext;
  final TextEditingController textEditingController = TextEditingController();

  TaskDetailsEditingContent(
      {super.key,
      required this.taskDetailsCubit,
      this.defaultContext,
      this.title,
      this.slider});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskDetailsCubit, TaskDetailsState>(
        builder: (editTaskCubitContext, state) {
      if (taskDetailsCubit.existingTaskId != null &&
          taskDetailsCubit.state.existingTask == null) {
        /// task exists but the data is not loaded yet
        return const CircularProgressIndicator(color: AppColors.purple);
      } else {
        return _content(editTaskCubitContext);
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
      ..._deadlineSection(context),
      ..._pointsSection(context),
      ..._approveSection(context)
    ]);
  }

  /// [FamilyMemberTask] photo
  List<Widget> _photoSection(
    BuildContext context,
  ) {
    if (taskDetailsCubit.existingTaskId != null &&
        taskDetailsCubit.state.existingTask == null) {
      // task exists but the data is not loaded yet
      return [const CircularProgressIndicator(color: AppColors.purple)];
    } else {
      String existingPhotoUrl =
          taskDetailsCubit.state.existingTask?.taskPhotoUrl ?? '';

      String uploadPhotoPath = taskDetailsCubit.state.taskPhotoUploadPath ?? '';

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
        GeneralPadding(
          child: DefaultButton(
              text: context.loc?.familiesTabCreatePhotoEdit,
              callback: () => GeneralImagePicker(
                  context: context,
                  currentUrl:
                      taskDetailsCubit.state.taskPhotoUploadPath == null &&
                              existingPhotoUrl.isNotEmpty
                          ? existingPhotoUrl
                          : null,
                  pickSheetTitle:
                      context.loc?.tasksTabEditTaskPhotoModification,
                  approveSheetTitle:
                      context.loc?.tasksTabEditTaskPhotoModification,
                  pickSheetInfo: context.loc?.familiesTabCreatePhotoPickInfo,
                  approveSheetInfo: context.loc?.familiesTabCreatePhotoPickInfo,
                  approveSheetDescription: context.loc?.tasksTabEditTaskSetThis,
                  currentPath:
                      context.cubits.editTask.state.taskPhotoUploadPath,
                  onChooseDone: (String? path) =>
                      taskDetailsCubit.setTaskPhotoTempPath(path),
                  onApprovalDone: (bool? approve) =>
                      taskDetailsCubit.approveTaskPhotoPath(approve)).show()),
        ),
      ];
    }
  }

  /// Name and description
  List<Widget> _dataSection(BuildContext context) {
    if (taskDetailsCubit.existingTaskId != null &&
        taskDetailsCubit.state.existingTask == null) {
      // task exists but the data is not loaded yet
      return [const CircularProgressIndicator(color: AppColors.purple)];
    } else {
      return <Widget>[
        ..._divider(title: context.loc?.familiesTabCreateBasics),
        GeneralPadding(
          child: DefaultInputField(
            callback: (value) {
              taskDetailsCubit.setTitle(value);
            },
            initialValue: taskDetailsCubit.state.existingTask?.title,
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
        GeneralPadding(
          child: DefaultInputField(
            callback: (value) {
              taskDetailsCubit.setDescription(value);
            },
            initialValue: taskDetailsCubit.state.existingTask?.description,
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

  /// Task deadline
  List<Widget> _deadlineSection(BuildContext context) {
    if (taskDetailsCubit.existingTaskId != null &&
        taskDetailsCubit.state.existingTask == null) {
      // task exists but the data is not loaded yet
      return [const CircularProgressIndicator(color: AppColors.purple)];
    } else {
      DateTime? currentDeadline = taskDetailsCubit.state.deadLine ??
          taskDetailsCubit.state.existingTask?.deadline;

      String title = currentDeadline != null
          ? currentDeadline.convertString(context)
          : context.loc?.globalEdit ?? '';

      DateTime? currentCreatedAt =
          taskDetailsCubit.state.existingTask?.createdAt;

      String createdAtTitle = currentCreatedAt != null
          ? currentCreatedAt.convertString(context)
          : '';

      return <Widget>[
        ..._divider(title: context.loc?.tasksTabEditDeadline),
        GeneralPadding(mainAxisAlignment: MainAxisAlignment.center, children: [
          DefaultButton(
            leadIcon: Icons.edit,
            text: title,
            callback: () {
              DatePicker.showDateTimePicker(context,
                  locale: LocaleType.en,
                  showTitleActions: true,
                  minTime: DateTime.now().add(const Duration(minutes: 1)),
                  onChanged: (date) {}, onConfirm: (date) {
                if (date.isInTheFutureAtLeastFiveSeconds) {
                  taskDetailsCubit.setDeadline(date);
                } else {
                  context.showInfoSheet(
                      context.loc?.tasksTabEditDeadlineMustBeFuture ?? '');
                }
              }, currentTime: DateTime.now());
            },
          ),
          if (createdAtTitle.isNotEmpty) ...[
            const VerticalSpacer.of40(),
            DefaultText(
              context.loc?.tasksTabEditCreatedAt(createdAtTitle) ?? '',
              color: AppColors.grey,
              textAlign: TextAlign.center,
            ),
          ]
        ])
      ];
    }
  }

  /// Number of points section
  List<Widget> _pointsSection(BuildContext context) {
    if (taskDetailsCubit.existingTaskId != null &&
        taskDetailsCubit.state.existingTask == null) {
      // task exists but the data is not loaded yet
      return [const CircularProgressIndicator(color: AppColors.purple)];
    } else {
      int? numberOfPoints = taskDetailsCubit.state.points ??
          taskDetailsCubit.state.existingTask?.points;

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
        GeneralPadding(children: <Widget>[
          DefaultInputField(
            callback: (value) {
              int? points = int.tryParse(value);
              taskDetailsCubit.setPoints(points);
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
            // textEditingController: textEditingController,
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
                    taskDetailsCubit.setPoints(element);
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
  }

  /// Approve modifications
  List<Widget> _approveSection(BuildContext context) {
    return <Widget>[
      ..._divider(),
      GeneralPadding(children: [
        DefaultSlider(
          stickToEnd: false,
          title: slider,
          onConfirmation: () {
            String name = taskDetailsCubit.state.title ??
                taskDetailsCubit.state.existingTask?.title ??
                '';
            if (name.isNotEmpty) {
              taskDetailsCubit.save(context: defaultContext);
            } else {
              context.showInfoSheet(
                  context.loc?.familiesTabCreateNameShouldNotBeEmpty ?? '');
            }
          },
        ),
        if (taskDetailsCubit.state.existingTask != null) ...[
          const VerticalSpacer.of40(),
          DefaultButton(
              text: context.loc?.globalDiscardModifications,
              textColor: AppColors.red,
              color: AppColors.white,
              borderColor: AppColors.red,
              callback: () => taskDetailsCubit.setMode(TaskDetailsMode.viewing))
        ]
      ])
    ];
  }

  List<Widget> _divider({String? title}) => <Widget>[
        const VerticalSpacer.of60(),
        TitledDivider(
          title: title,
        ),
        const VerticalSpacer.of10(),
      ];
}
