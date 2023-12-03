import 'package:flutter/material.dart';

class Constants {
  static get borderRadius => BorderRadius.circular(20);

  static get borderRadiusLarge => BorderRadius.circular(50);

  static const double borderWidth = 2.0;

  static const String logoUrl =
      'https://firebasestorage.googleapis.com/v0/b/living-room-9bcc0.appspot.com/o/app%2FNappali_detailed.png?alt=media&token=a907ac2c-c987-4792-afda-9c6c8296a06a';
}

class AppImages{
  static get appIcon => 'assets/images/app_icon.png';
}

class AppPaddings {
  static get screenSide => const EdgeInsets.symmetric(horizontal: 25.0);

  static get cardAllAround =>
      const EdgeInsets.only(left: 20.0, right: 20.0, top: 23.0, bottom: 23.0);

  static get inputField =>
      const EdgeInsets.only(left: 20, top: 16, bottom: 15, right: 20);

  static get screenAllAround =>
      const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 0);

  static get defaultContainer =>
      const EdgeInsets.symmetric(vertical: 6, horizontal: 10);

  static get defaultExpansionTile =>
      const EdgeInsets.only(top: 20, bottom: 20, left: 5, right: 5);
}

class AppColors {
  static const Color blue = Color(0xFF0b84a5);
  static const Color sand = Color(0xFFf6c85f);
  static const Color purple = Color(0xFF6f4e7c);
  static const Color purple50 = Color(0xFFbaa0c4);
  static const Color red = Color(0xffDE5B5B);
  static const Color green = Color(0xFF36C390);
  static const Color green2 = Color(0xFF36C3B5);
  static const Color black = Color(0xFF222222);
  static const Color black36 = Color(0x5c222222);
  static const Color white = Color(0xffFFFFFF);
  static Color whiteOp30 = white.withOpacity(0.3);
  static Color whiteOp90 = white.withOpacity(0.9);
  static const Color grey = Color(0xFF888888);
  static const Color grey2 = Color(0xFFAAAAAA);
  static const Color grey3 = Color(0xFFD2D2D2);
  static const Color customBlack2 = Color(0xFF384357);
}

class AppRoutes {
  static const loading = '/';
  static const signIn = '/signIn';
  static const signUp = '/signUp';
  static const home = '/home';
  static const verify = '/verify';
  static const banned = '/banned';
  static const wrong = '/wrong';
  static const noConnection = '/no_connection';
}
