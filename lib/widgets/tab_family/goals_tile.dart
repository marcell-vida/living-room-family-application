import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/model/database/families/family_member_goal.dart';
import 'package:living_room/state/object/member_bloc.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_button.dart';
import 'package:living_room/widgets/default/default_expansion_tile.dart';
import 'package:living_room/widgets/general/list_item_with_picture_icon.dart';
import 'package:living_room/widgets/goal_details/base/goal_details.dart';
import 'package:living_room/widgets/spacers.dart';

class GoalsTile extends StatelessWidget {
  final MemberCubit memberCubit;

  const GoalsTile({super.key, required this.memberCubit});

  @override
  Widget build(BuildContext context) {
    return _content(context);
  }

  Widget _content(BuildContext context) {
    return StreamBuilder(
        stream: context.services.database.streamFamilyMemberGoals(
            familyId: memberCubit.familyId, userId: memberCubit.userId),
        builder: (context, snapshot) {
          List<FamilyMemberGoal>? goals = snapshot.data;

          return DefaultExpansionTile(
            title: context.loc?.tasksTabGoals,
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
                _onCreateGoal(context);
              },
            ),
            children: [
              /// active goals
              if (goals != null)
                for (FamilyMemberGoal goal in goals)
                  if (goal.isApproved != true) _goalItem(context, goal),

              /// previous goals
              DefaultButton(
                  text: context.loc?.tasksTabPreviousGoals ?? '',
                  borderColor: Colors.transparent,
                  color: AppColors.white,
                  textColor: AppColors.purple,
                  callback: () {
                    _onShowPreviousGoals(context);
                  }),
            ],
          );
        });
  }

  /// a single goal item
  Widget _goalItem(BuildContext context, FamilyMemberGoal goal,
      {bool withBorder = false}) {
    return StreamBuilder(
        stream: context.services.database.streamFamilyMemberGoal(
            familyId: goal.familyId!, userId: goal.memberId!, goalId: goal.id!),
        builder: (context, snapshot) {
          FamilyMemberGoal? streamedGoal = snapshot.data;

          if (streamedGoal == null) return const SizedBox();

          Color? iconColor;
          IconData? icon;
          Widget? endWidget;

          if (goal.isApproved == true) {
            iconColor = AppColors.green;
            icon = Icons.done_all;
          } else if (goal.isAchieved == true) {
            /// goal needs attention
            iconColor = AppColors.red;
            icon = Icons.warning_amber;
          } else {
            int collected = memberCubit.state.member?.pointsCollected ?? 0;
            int needed = goal.points ?? 1;
            double progress = collected / needed;

            if (progress <= 0) progress = 0.05;

            endWidget = SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  value: progress,
                  color: AppColors.green2,
                  backgroundColor: AppColors.lightBlue,
                  strokeWidth: 14,
                ));
          }

          return Column(children: [
            ListItemWithPictureIcon(
              onTap: () => _onShowGoal(context, goal),
              title: streamedGoal.title,
              photoUrl: streamedGoal.photoUrl,
              iconColor: iconColor,
              backgroundColor: AppColors.white,
              borderColor: withBorder ? AppColors.purple : Colors.transparent,
              avatarColor: AppColors.purple,
              titleColor: AppColors.purple,
              icon: icon,
              endWidget: endWidget,
            ),
            const VerticalSpacer.of10()
          ]);
        });
  }

  void _onShowPreviousGoals(BuildContext context) {
    context.showBottomSheet(children: [
      BlocProvider<MemberCubit>.value(
        value: memberCubit,
        child: BlocBuilder<MemberCubit, MemberState>(
            bloc: memberCubit,
            buildWhen: (previous, current) =>
                previous.updateFlag != current.updateFlag,
            builder: (context, state) {
              List<Widget> goals = [
                /// all goals
                if (memberCubit.state.goals != null)
                  for (FamilyMemberGoal goal in memberCubit.state.goals!)
                    _goalItem(context, goal, withBorder: true),
              ];

              return Column(
                children: goals,
              );
            }),
      )
    ]);
  }

  void _onShowGoal(BuildContext context, FamilyMemberGoal goal) {
    GoalDetails(
        appBaseCubit: context.cubits.base,
        existingGoalId: goal.id,
        familyId: memberCubit.familyId,
        userId: memberCubit.userId,
        defaultContext: context);
  }

  void _onCreateGoal(BuildContext context) {
    GoalDetails(
        appBaseCubit: context.cubits.base,
        familyId: memberCubit.familyId,
        userId: memberCubit.userId,
        defaultContext: context);
  }
}
