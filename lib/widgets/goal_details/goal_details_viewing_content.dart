import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/extension/dart/datetime_extension.dart';
import 'package:living_room/model/database/families/family_member_goal.dart';
import 'package:living_room/state/screen/app_base/app_base_cubit.dart';
import 'package:living_room/state/sheet/family/goal_details_bloc.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_avatar.dart';
import 'package:living_room/widgets/default/default_button.dart';
import 'package:living_room/widgets/default/default_container.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/general/general_padding.dart';
import 'package:living_room/widgets/spacers.dart';
import 'package:square_percent_indicater/square_percent_indicater.dart';

class GoalDetailsViewingContent extends StatelessWidget {
  final String goalId;
  final AppBaseCubit appBaseCubit;
  final GoalDetailsCubit goalDetailsCubit;
  final void Function()? onEdit;

  const GoalDetailsViewingContent(
      {super.key,
      this.onEdit,
      required this.goalId,
      required this.appBaseCubit,
      required this.goalDetailsCubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GoalDetailsCubit>.value(
      value: goalDetailsCubit,
      child: BlocBuilder<GoalDetailsCubit, GoalDetailsState>(
        bloc: goalDetailsCubit,
        buildWhen: (previous, current) =>
            previous.updateFlag != current.updateFlag,
        builder: (context, state) {
          return Column(
            children: _content(context),
          );
        },
      ),
    );
  }

  List<Widget> _content(BuildContext context) {
    FamilyMemberGoal? goal = goalDetailsCubit.state.existingGoal;
    String title = goal?.title ?? '';
    String description = goal?.description ?? '';
    String createdAt = context.loc?.tasksTabEditCreatedAt(
            goal?.createdAt?.convertString(context) ?? '') ??
        '';
    String goalPhotoUrl = goal?.photoUrl ?? '';
    String points = '${goal?.points ?? 0}';
    bool isAchieved = goal?.isAchieved ?? false;
    bool isApproved = goal?.isApproved ?? false;

    double progressValue = _progressValue(goal);

    return <Widget>[
      /// photo
      if (goalPhotoUrl.isNotEmpty) ...[
        DefaultAvatar(
          url: goalPhotoUrl,
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

      if (description.isNotEmpty) ...[
        /// description
        DefaultText(
          description,
          color: AppColors.grey,
          textAlign: TextAlign.center,
        ),
        const VerticalSpacer.of40(),
      ],

      GeneralPadding(children: [
        /// progress
        if (progressValue < 1 && !isAchieved && !isApproved)
          _progressSection(context, goal, progressValue),

        /// enough points, can be claimed
        if (progressValue >= 1 && !isAchieved) ..._claimSection(context),

        /// approve
        if (isAchieved && !isApproved) ..._approveSection(context),

        /// done
        if (isApproved) _approvedSection(context),

        const VerticalSpacer.of40(),

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
      ]),

      /// edit button
      if (!isApproved) ...[
        DefaultButton(
            text: context.loc?.globalEdit,
            callback: () {
              onEdit?.call();
            }),
        const VerticalSpacer.of40()
      ],

      /// created at
      DefaultText(
        createdAt,
        color: AppColors.grey,
        textAlign: TextAlign.center,
      ),
    ];
  }

  double _progressValue(FamilyMemberGoal? goal) {
    double collectedPoints =
        goalDetailsCubit.state.familyMember?.pointsCollected?.toDouble() ?? 1;
    if (collectedPoints <= 0) collectedPoints = 0.001;
    double pointsNeeded = goal?.points?.toDouble() ?? 1;
    if (pointsNeeded <= 0) pointsNeeded = 0.001;
    return collectedPoints / pointsNeeded;
  }

  List<Widget> _claimSection(BuildContext context) {
    return <Widget>[
      const Center(
        child: Icon(
          Icons.check_circle,
          color: AppColors.green,
          size: 50,
        ),
      ),
      const VerticalSpacer.of10(),
      Center(
        child: DefaultText(
          context.loc?.tasksTabGoalsYouAchieved ?? '',
          fontSize: 16,
          textAlign: TextAlign.center,
          color: AppColors.green,
        ),
      ),
      const VerticalSpacer.of20(),
      DefaultButton(
          text: context.loc?.tasksTabGoalsTradePoints,
          color: AppColors.green,
          callback: () {
            goalDetailsCubit.claim();
          })
    ];
  }

  List<Widget> _approveSection(BuildContext context) {
    return <Widget>[
      const Center(
        child: Icon(
          Icons.warning_amber,
          color: AppColors.sand,
          size: 50,
        ),
      ),
      const VerticalSpacer.of10(),
      Center(
        child: DefaultText(
          context.loc?.tasksTabGoalsApproveDescription ?? '',
          fontSize: 16,
          textAlign: TextAlign.center,
          color: AppColors.sand,
        ),
      ),
      const VerticalSpacer.of20(),
      DefaultButton(
          text: context.loc?.tasksTabGoalsApprove,
          color: AppColors.sand,
          callback: () {
            goalDetailsCubit.approve();
          })
    ];
  }

  Widget _progressSection(
      BuildContext context, FamilyMemberGoal? goal, double progressValue) {
    return SquarePercentIndicator(
      width: MediaQuery.maybeOf(context)?.size.width ?? 150,
      height: 60,
      borderRadius: 20,
      shadowWidth: 3,
      progressWidth: 5,
      shadowColor: AppColors.grey3,
      progressColor: AppColors.purple,
      progress: progressValue,
      child: Center(
        child: DefaultText(
          '${goalDetailsCubit.state.familyMember?.pointsCollected ?? 0}/${goal?.points ?? 0}',
          fontSize: 20,
          color: AppColors.purple,
        ),
      ),
    );
  }

  Widget _approvedSection(BuildContext context) {
    return DefaultContainer(
      borderColor: AppColors.purple,
      children: [
        const Center(
          child: Icon(
            Icons.done_all,
            color: AppColors.purple,
            size: 50,
          ),
        ),
        const VerticalSpacer.of10(),
        Center(
          child: DefaultText(
            context.loc?.tasksTabDetailsApproved ?? '',
            fontSize: 20,
            color: AppColors.purple,
          ),
        ),
      ],
    );
  }
}
