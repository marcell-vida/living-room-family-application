import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/state/sheet/family/task_details_bloc.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/util/utils.dart';
import 'package:living_room/widgets/default/default_button.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/spacers.dart';

class TaskDetailsLoadingContent extends StatelessWidget {
  final ProcessStatus processStatus;

  const TaskDetailsLoadingContent({super.key, required this.processStatus});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskDetailsCubit, TaskDetailsState>(
        buildWhen: (previous, current) =>
            previous.saveStatus != current.saveStatus,
        builder: (cubitContext, state) {
          ProcessStatus processStatus = state.saveStatus;
          if (processStatus == ProcessStatus.unsuccessful) {
            return Column(
              children: [
                DefaultText(
                  context.loc?.globalUnsuccessfulOperation ?? '',
                  color: AppColors.grey,
                ),
                const VerticalSpacer.of10(),
                DefaultButton(
                  callback: () => context.navigator.pop(),
                  text: context.loc?.generalDone,
                )
              ],
            );
          } else if (processStatus == ProcessStatus.successful) {
            return Column(
              children: [
                DefaultText(
                  context.loc?.globalSuccessfulOperation ?? '',
                  color: AppColors.grey,
                ),
                const VerticalSpacer.of10(),
                DefaultButton(
                  callback: () => context.navigator.pop(),
                  text: context.loc?.generalDone,
                )
              ],
            );
          }
          return const CircularProgressIndicator(
            color: AppColors.purple,
          );
        });
  }
}
