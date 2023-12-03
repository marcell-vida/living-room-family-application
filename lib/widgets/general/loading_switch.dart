import 'package:flutter/material.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/util/utils.dart';

class LoadingSwitch extends StatelessWidget {
  final bool? switchState;
  final ProcessStatus? processStatus;
  final bool? isLoading;
  final bool? isSuccess;
  final bool? isError;
  final Function(bool)? onChanged;

  const LoadingSwitch(
      {Key? key,
      this.switchState,
      this.processStatus,
      bool? isLoading,
      bool? isSuccess,
      bool? isError,
      this.onChanged})
      : isLoading = isLoading ?? processStatus == ProcessStatus.processing,
        isSuccess = isSuccess ?? processStatus == ProcessStatus.successful,
        isError = isError ?? processStatus == ProcessStatus.unsuccessful,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget result;

    if (isLoading == true) {
      result = const CircularProgressIndicator(color: AppColors.purple);
    } else if (isSuccess == true) {
      result = const Icon(Icons.check_circle, color: AppColors.purple);
    } else if (isError == true) {
      result = const Icon(Icons.warning_amber, color: AppColors.red);
    } else {
      result = Switch(
        value: switchState ?? false,
        onChanged: onChanged ?? (_){},
        activeColor: AppColors.white,
        inactiveThumbColor: AppColors.white,
        inactiveTrackColor: AppColors.grey3,
        activeTrackColor: AppColors.purple,
      );
    }
    return SizedBox(
      width: 50,
      height: 50,
      child: Center(child: result),
    );
  }
}
