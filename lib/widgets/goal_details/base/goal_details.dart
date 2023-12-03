import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/state/screen/app_base/app_base_cubit.dart';
import 'package:living_room/state/sheet/family/goal_details_bloc.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/goal_details/goal_details_editing_content.dart';
import 'package:living_room/widgets/goal_details/goal_details_loading_content.dart';
import 'package:living_room/widgets/goal_details/goal_details_viewing_content.dart';

class GoalDetails {
  final BuildContext defaultContext;
  final AppBaseCubit appBaseCubit;
  final String? existingGoalId;
  final String familyId;
  final String userId;

  final TextEditingController textEditingController = TextEditingController();

  GoalDetails(
      {required this.appBaseCubit,
      required this.defaultContext,
      required this.familyId,
      required this.userId,
      this.existingGoalId}){
   _show();
  }

  void _show() {
    defaultContext.showBottomSheet(children: [_sheetContent()]);
  }

  Widget _sheetContent() {
    return BlocProvider(
      create: (_) => GoalDetailsCubit(
          authenticationService: defaultContext.services.authentication,
          databaseService: defaultContext.services.database,
          storageService: defaultContext.services.storage,
          existingGoalId: existingGoalId,
          familyId: familyId,
          userId: userId),
      child: Builder(builder: (cubitContext) {
        return BlocBuilder<GoalDetailsCubit, GoalDetailsState>(
            buildWhen: (previous, current) =>
                previous.goalDetailsMode != current.goalDetailsMode,
            builder: (cubitContext, state) {
              switch (state.goalDetailsMode) {
                case GoalDetailsMode.editing:
                  return GoalDetailsEditingContent(
                    goalDetailsCubit: cubitContext.cubits.editGoal,
                    title: cubitContext.cubits.editGoal.existingGoalId != null
                        ? cubitContext.loc?.goalDetailsEditGoal
                        : cubitContext.loc?.goalDetailsAdd,
                    slider: cubitContext.cubits.editGoal.existingGoalId != null
                        ? cubitContext.loc?.globalModifySlide
                        : cubitContext.loc?.generalAddSlide,
                  );
                case GoalDetailsMode.loading:
                  return GoalDetailsLoadingContent(
                      processStatus: state.saveStatus);
                case GoalDetailsMode.viewing:
                  return existingGoalId != null
                      ? GoalDetailsViewingContent(
                          appBaseCubit: appBaseCubit,
                          goalDetailsCubit: cubitContext.cubits.editGoal,
                          goalId: existingGoalId!,
                          onEdit: () => cubitContext.cubits.editGoal
                              .setMode(GoalDetailsMode.editing),
                        )
                      : const CircularProgressIndicator(
                          color: AppColors.purple,
                        );
                default:
                  return const CircularProgressIndicator(
                    color: AppColors.purple,
                  );
              }
            });
      }),
    );
  }
}
