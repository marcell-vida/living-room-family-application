import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/main.dart';
import 'package:living_room/model/database/families/family_member.dart';
import 'package:living_room/model/database/families/family_member_goal.dart';
import 'package:living_room/model/database/families/family_member_task.dart';
import 'package:living_room/state/object/member_bloc.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_action_chip.dart';
import 'package:living_room/widgets/general/titled_divider.dart';
import 'package:living_room/widgets/tab_family/goals_tile.dart';
import 'package:living_room/widgets/tab_family/tasks_tile.dart';
import 'package:living_room/widgets/default/default_avatar.dart';
import 'package:living_room/widgets/default/default_expansion_tile.dart';
import 'package:living_room/widgets/spacers.dart';
import 'package:living_room/widgets/tab_family/member_details.dart';

class MemberTile extends StatelessWidget {
  final MemberCubit memberCubit;

  const MemberTile({super.key, required this.memberCubit});

  @override
  Widget build(BuildContext context) {
    /// state update management
    return BlocProvider<MemberCubit>.value(
      value: memberCubit,
      child: BlocBuilder<MemberCubit, MemberState>(builder: (context, state) {
        log.d('member state updated');

        /// title of ExpansionTile
        String? title = memberCubit.state.user?.displayName;
        if (context.cubits.base.getCurrentAuthUser?.uid == memberCubit.userId) {
          title = '$title (${context.loc?.globalMe ?? ''})';
        }

        return DefaultExpansionTile(
          title: title,
          borderLess: true,
          leading: memberCubit.state.user?.photoUrl != null
              ? DefaultAvatar(
                  url: memberCubit.state.user?.photoUrl,
                  radius: 18,
                  onTap: () {
                    _onProfileTap(context);
                  },
                )
              : null,
          children: _tileContent(context),
        );
      }),
    );
  }

  /// the content of this [MemberTile]
  List<Widget> _tileContent(BuildContext context) {
    FamilyMember? member = memberCubit.state.member;

    int achievedGoals = 0;
    int allGoals = memberCubit.state.goals?.length ?? 0;
    if (memberCubit.state.goals != null) {
      for (FamilyMemberGoal goal in memberCubit.state.goals!) {
        if (goal.isAchieved == true) {
          achievedGoals++;
        }
      }
    }

    int finishedTasks = 0;
    int allTasks = memberCubit.state.tasks?.length ?? 0;
    if (memberCubit.state.tasks != null) {
      for (FamilyMemberTask task in memberCubit.state.tasks!) {
        if (task.isFinished == true) {
          finishedTasks++;
        }
      }
    }

    return <Widget>[
      /// tasks
      TasksTile(memberCubit: memberCubit),

      const VerticalSpacer.of10(),

      /// goals
      GoalsTile(memberCubit: memberCubit),

      const VerticalSpacer.of20(),
      const TitledDivider(),
      const VerticalSpacer.of20(),

      /// statistics
      Wrap(
        spacing: 10,
        alignment: WrapAlignment.center,
        children: [
          DefaultActionChip(
            icon: Icons.check_circle_outlined,
            color: AppColors.green2,
            title: context.loc?.tasksTabXTasks(allTasks),
            titleColor: AppColors.white,
            disabledColor: AppColors.green,
            onTap: _onStatisticsTap,
          ),
          DefaultActionChip(
            icon: Icons.check_circle,
            color: AppColors.green2,
            title: context.loc?.tasksTabXFinished(finishedTasks),
            titleColor: AppColors.white,
            disabledColor: AppColors.green,
            onTap: _onStatisticsTap,
          ),
          DefaultActionChip(
            icon: Icons.assistant_photo_outlined,
            color: AppColors.purple,
            title: context.loc?.tasksTabXGoals(allGoals),
            titleColor: AppColors.white,
            disabledColor: AppColors.purple,
            onTap: _onStatisticsTap,
          ),
          DefaultActionChip(
            icon: Icons.assistant_photo,
            color: AppColors.purple,
            title: context.loc?.tasksTabXAchieved(achievedGoals),
            titleColor: AppColors.white,
            disabledColor: AppColors.purple,
            onTap: _onStatisticsTap,
          ),
          DefaultActionChip(
            icon: Icons.control_point_duplicate,
            color: AppColors.sand,
            title: context.loc?.tasksTabXPoints(member?.pointsCollected ?? 0),
            titleColor: AppColors.white,
            disabledColor: AppColors.sand,
            onTap: _onStatisticsTap,
          ),
        ],
      ),
    ];
  }

  void _onStatisticsTap() {}

  void _onProfileTap(BuildContext context) {
    context
        .showBottomSheet(children: [MemberDetails(memberCubit: memberCubit)]);
  }
}
