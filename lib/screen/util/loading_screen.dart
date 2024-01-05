import 'package:flutter/material.dart';
import 'package:living_room/screen/base/app_base_screen.dart';
import 'package:living_room/util/constants.dart';

class LoadingScreen extends AppBaseScreen {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget body(BuildContext context) {
    return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(
      color: AppColors.purple,
    )));
  }
}
