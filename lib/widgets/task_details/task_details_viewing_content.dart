import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/extension/dart/datetime_extension.dart';
import 'package:living_room/model/database/families/family_member_task.dart';
import 'package:living_room/state/object/member_bloc.dart';
import 'package:living_room/state/screen/app_base/app_base_cubit.dart';
import 'package:living_room/state/sheet/family/task_details_bloc.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_avatar.dart';
import 'package:living_room/widgets/default/default_button.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/default/default_toggle_switch.dart';
import 'package:living_room/widgets/general/general_padding.dart';
import 'package:living_room/widgets/spacers.dart';

class TaskDetailsViewingContent extends StatelessWidget {
  final String taskId;
  final AppBaseCubit appBaseCubit;
  final MemberCubit? signedInMember;
  final TaskDetailsCubit taskDetailsCubit;
  final void Function()? onEdit;

  const TaskDetailsViewingContent(
      {super.key,
      required this.taskId,
      required this.appBaseCubit,
      required this.taskDetailsCubit,
      this.signedInMember,
      this.onEdit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskDetailsCubit>.value(
      value: taskDetailsCubit,
      child: BlocBuilder<TaskDetailsCubit, TaskDetailsState>(
        bloc: taskDetailsCubit,
        buildWhen: (previous, current) =>
            previous.updateFlag != current.updateFlag,
        builder: (context, state) {
          return Column(
            children: _taskDetailsContent(context),
          );
        },
      ),
    );
  }

  bool _enableApproveSwitch() {
    FamilyMemberTask? task = taskDetailsCubit.state.existingTask;
    bool isFinished = task?.isFinished ?? false;
    bool isFinishApproved = task?.isFinishApproved ?? false;

    /// user is child
    if (signedInMember?.state.member?.isParent != true) return false;

    /// if the task is finished then enable
    bool result = isFinished == true;

    if (isFinishApproved) {
      /// already approved

      bool haveEnoughPointsToDisapprove =
          (taskDetailsCubit.state.familyMember?.pointsCollected ?? 0) >=
              (task?.points ?? 0);

      if (!haveEnoughPointsToDisapprove) {
        /// do not have enough points to subtract from currently collected ones
        /// disable
        result = false;
      }
    }

    return result;
  }

  List<Widget> _taskDetailsContent(BuildContext context) {
    FamilyMemberTask? task = taskDetailsCubit.state.existingTask;
    String title = task?.title ?? '';
    String description = task?.description ?? '';
    String deadline = task?.deadline?.convertString(context) ?? '';
    String createdAt = context.loc?.tasksTabEditCreatedAt(
            task?.createdAt?.convertString(context) ?? '') ??
        '';
    String taskPhotoUrl = task?.taskPhotoUrl ?? '';
    String finishedPhotoUrl = task?.finishedPhotoUrl ?? '';
    String points = task?.points.toString() ?? '';
    bool isFinished = task?.isFinished ?? false;
    bool isFinishApproved = task?.isFinishApproved ?? false;
    bool enableApproveButton = _enableApproveSwitch();
    bool isUserParent = signedInMember?.state.member?.isParent == true;

    return <Widget>[
      /// photo
      if (taskPhotoUrl.isNotEmpty) ...[
        DefaultAvatar(
          url: taskPhotoUrl,
          radius: 110,
          borderColor: AppColors.purple,
          borderWidth: Constants.borderWidth,
        ),
        const VerticalSpacer.of10()
      ],

      /// title
      DefaultText(
        title,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        textAlign: TextAlign.center,
      ),
      const VerticalSpacer.of20(),

      /// description
      DefaultText(
        description,
        color: AppColors.grey,
        textAlign: TextAlign.center,
      ),
      const VerticalSpacer.of40(),

      /// status
      DefaultToggleSwitch(
        enabled: !isFinishApproved,
        value: isFinished,
        offTitle: context.loc?.tasksTabDetailsInProgress,
        onTitle: context.loc?.tasksTabDetailsAccomplished,
        onChanged: (bool setTo) {
          taskDetailsCubit.finish(setTo: setTo, context: context);
        },
      ),
      const VerticalSpacer.of20(),

      /// approve status
      DefaultToggleSwitch(
        enabled: enableApproveButton,
        value: isFinishApproved,
        offTitle: context.loc?.tasksTabDetailsNotApproved,
        onTitle: context.loc?.tasksTabDetailsApproved,
        onChanged: (bool setTo) {
          taskDetailsCubit.approve(setTo: setTo);
        },
      ),

      GeneralPadding(
        children: [
          if (isFinished && !enableApproveButton && isUserParent) ...[
            const VerticalSpacer.of10(),
            DefaultText(
              context.loc?.tasksTabNotEnoughPointsToDisapprove ?? '',
              color: AppColors.grey,
              textAlign: TextAlign.center,
            ),
          ],

          const VerticalSpacer.of40(),

          /// deadline
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                color: AppColors.red,
              ),
              const HorizontalSpacer.of10(),
              Expanded(
                child: DefaultText(
                  '${context.loc?.tasksTabEditDeadline}: $deadline',
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
          const VerticalSpacer.of10(),

          /// points
          Row(
            children: [
              const Icon(
                Icons.control_point_duplicate,
                color: AppColors.sand,
              ),
              const HorizontalSpacer.of10(),
              DefaultText(
                points,
                color: AppColors.grey,
              ),
            ],
          ),
          const VerticalSpacer.of40(),
        ],
      ),

      /// edit button
      if (isUserParent) ...[
        DefaultButton(
            text: context.loc?.globalEdit,
            callback: () {
              /// show modify sheet
              onEdit?.call();
            }),
        const VerticalSpacer.of40(),
      ],

      /// created at
      DefaultText(
        createdAt,
        color: AppColors.grey,
        textAlign: TextAlign.center,
      ),
    ];
  }
}
