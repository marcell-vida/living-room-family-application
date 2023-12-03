import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/state/screen/app_base/app_base_cubit.dart';
import 'package:living_room/state/sheet/family/task_details_bloc.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/task_details/task_details_editing_content.dart';
import 'package:living_room/widgets/task_details/task_details_loading_content.dart';
import 'package:living_room/widgets/task_details/task_details_viewing_content.dart';

class TaskDetails {
  final BuildContext defaultContext;
  final AppBaseCubit appBaseCubit;
  final String? existingTaskId;
  final String familyId;
  final String userId;

  final TextEditingController textEditingController = TextEditingController();

  TaskDetails(
      {required this.defaultContext,
      required this.familyId,
      required this.userId,
      required this.appBaseCubit,
      this.existingTaskId}) {
    _show();
  }

  void _show() {
    defaultContext.showBottomSheet(children: [_sheetContent()]);
  }

  Widget _sheetContent() {
    return BlocProvider(
      create: (_) => TaskDetailsCubit(
          authenticationService: defaultContext.services.authentication,
          databaseService: defaultContext.services.database,
          storageService: defaultContext.services.storage,
          existingTaskId: existingTaskId,
          familyId: familyId,
          userId: userId),
      child: Builder(builder: (cubitContext) {
        return BlocBuilder<TaskDetailsCubit, TaskDetailsState>(
            buildWhen: (previous, current) =>
                previous.taskDetailsMode != current.taskDetailsMode,
            builder: (cubitContext, state) {
              switch (state.taskDetailsMode) {
                case TaskDetailsMode.editing:

                  /// currently editing
                  return TaskDetailsEditingContent(
                    taskDetailsCubit: cubitContext.cubits.editTask,
                    title: cubitContext.cubits.editTask.existingTaskId != null
                        ? cubitContext.loc?.tasksTabEditModifyTask
                        : cubitContext.loc?.tasksTabEditAddTask,
                    slider: cubitContext.cubits.editTask.existingTaskId != null
                        ? cubitContext.loc?.globalModifySlide
                        : cubitContext.loc?.generalAddSlide,
                  );

                /// processing changes
                case TaskDetailsMode.loading:
                  return TaskDetailsLoadingContent(
                      processStatus: state.saveStatus);

                /// viewing data
                case TaskDetailsMode.viewing:
                  return existingTaskId != null
                      ? TaskDetailsViewingContent(
                          appBaseCubit: appBaseCubit,
                          taskDetailsCubit: cubitContext.cubits.editTask,
                          taskId: existingTaskId!,
                          onEdit: () => cubitContext.cubits.editTask
                              .setMode(TaskDetailsMode.editing),
                        )
                      : const CircularProgressIndicator(
                          color: AppColors.purple,
                        );

                /// other
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
