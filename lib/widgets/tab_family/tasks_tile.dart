import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/main.dart';
import 'package:living_room/model/database/families/family_member_task.dart';
import 'package:living_room/state/object/member_bloc.dart';
import 'package:living_room/state/object/task_bloc.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_button.dart';
import 'package:living_room/widgets/default/default_expansion_tile.dart';
import 'package:living_room/widgets/general/list_item_with_picture_icon.dart';
import 'package:living_room/widgets/spacers.dart';
import 'package:living_room/widgets/task_details/base/task_details.dart';

class TasksTile extends StatelessWidget {
  final MemberCubit memberCubit;

  const TasksTile({super.key, required this.memberCubit});

  @override
  Widget build(BuildContext context) {
    return _content(context);
  }

  Widget _content(BuildContext context) {
    return DefaultExpansionTile(
      title: context.loc?.tasksTabTasks,
      titleColor: AppColors.white,
      borderColor: Colors.transparent,
      backgroundColor: AppColors.purple,
      leading: GestureDetector(
        child: const Icon(
          Icons.add_circle_outlined,
          color: AppColors.white,
          size: 34,
        ),
        onTap: () {
          _onCreateTask(context);
        },
      ),
      children: [
        /// active tasks
        if (memberCubit.state.tasks != null)
          for (FamilyMemberTask task in memberCubit.state.tasks!)
            if (task.isFinishApproved != true) _taskItem(context, task),

        /// previous tasks
        DefaultButton(
            text: context.loc?.tasksTabPreviousTasks ?? '',
            borderColor: Colors.transparent,
            color: AppColors.white,
            textColor: AppColors.purple,
            callback: () {
              _onShowPreviousTasks(context);
            }),
      ],
    );
  }

  /// a single task item
  Widget _taskItem(BuildContext context, FamilyMemberTask task,
      {bool withBorder = false}) {
    Color iconColor = AppColors.sand;
    IconData icon = Icons.incomplete_circle;

    if (task.isFinishApproved == true) {
      /// task needs attention
      iconColor = AppColors.green;
      icon = Icons.done_all;
    } else if (task.isFinished == true) {
      /// task needs attention
      iconColor = AppColors.red;
      icon = Icons.warning_amber;
    }

    return Column(children: [
      ListItemWithPictureIcon(
          onTap: () => _onShowTask(context, task),
          title: task.title,
          photoUrl: task.taskPhotoUrl,
          iconColor: iconColor,
          backgroundColor: AppColors.white,
          borderColor: withBorder ? AppColors.purple : Colors.transparent,
          avatarColor: AppColors.purple,
          titleColor: AppColors.purple,
          icon: icon),
      const VerticalSpacer.of10()
    ]);
  }

  void _onCreateTask(BuildContext context) {
    TaskDetails(
        appBaseCubit: context.cubits.base,
        familyId: memberCubit.familyId,
        userId: memberCubit.userId,
        defaultContext: context);
  }

  void _onShowTask(BuildContext context, FamilyMemberTask task) {
    TaskDetails(
        existingTaskId: task.id,
        appBaseCubit: context.cubits.base,
        familyId: memberCubit.familyId,
        userId: memberCubit.userId,
        defaultContext: context);
  }

  void _onShowPreviousTasks(BuildContext context) {
    context.showBottomSheet(children: [
      BlocProvider<MemberCubit>.value(
        value: memberCubit,
        child: BlocBuilder<MemberCubit, MemberState>(
            bloc: memberCubit,
            buildWhen: (previous, current) =>
                previous.updateFlag != current.updateFlag,
            builder: (context, state) {
              log.d('updating layout');
              List<Widget> tasks = [
                /// all tasks
                if (memberCubit.state.tasks != null)
                  for (FamilyMemberTask task in memberCubit.state.tasks!)
                    _taskItem(context, task, withBorder: true),
              ];
              return Column(
                children: tasks,
              );
            }),
      )
    ]);
  }
}
