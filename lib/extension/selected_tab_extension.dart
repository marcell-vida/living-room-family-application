import 'package:living_room/util/constants.dart';

enum SelectedTab { home, favorite, search, person }

extension AuthExceptionExtension on  SelectedTab{
  String get getRoute {
    switch (this) {
      case SelectedTab.home:
        return AppRoutes.home;
      default:
        return AppRoutes.home;
    }
  }
}