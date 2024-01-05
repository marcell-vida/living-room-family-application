import 'package:flutter/cupertino.dart';

extension NavigatorStateExtension on NavigatorState {
  /// Navigator pushes the named [route] with the given [arguments] only if this
  /// is not the screen displayed right now.
  void pushNamedIfNotCurrent(String route, {Object? arguments}) {
    if (!isCurrent(route)) {
      pushNamed(route, arguments: arguments);
    }
  }

  bool isCurrent(String route) {
    bool isCurrent = false;
    popUntil((current) {
      debugPrint(
          'NavigatorStateExtension.isCurrent: current inspected screen is: ${current.settings.name}');
      if (current.settings.name == route) {
        isCurrent = true;
      }
      // does not pop the screens truly, just iterates through them
      return true;
    });
    return isCurrent;
  }
}
