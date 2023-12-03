import 'package:flutter/material.dart';
import 'package:living_room/util/constants.dart';
import 'package:toggle_switch/toggle_switch.dart';

class DefaultToggleSwitch extends StatelessWidget {
  final bool value;
  final bool enabled;
  final String? offTitle;
  final String? onTitle;
  final void Function(bool)? onChanged;

  const DefaultToggleSwitch(
      {super.key,
      this.enabled = true,
      this.value = false,
      this.offTitle,
      this.onTitle,
      this.onChanged});

  Color get _color => enabled ? AppColors.purple : AppColors.grey;

  @override
  Widget build(BuildContext context) {
    return ToggleSwitch(
      minWidth: 150,
      cornerRadius: 100,
      activeBgColors: [
        [_color],
        [_color]
      ],
      borderColor: [_color],
      activeFgColor: AppColors.white,
      inactiveBgColor: AppColors.white,
      inactiveFgColor: _color,
      initialLabelIndex: value ? 1 : 0,
      totalSwitches: 2,
      changeOnTap: enabled,
      animate: true,
      animationDuration: 200,
      labels: [offTitle ?? '', onTitle ?? ''],
      radiusStyle: true,
      onToggle: (index) {
        if (enabled) {
          switch (index) {
            case 1:

              /// set to true
              onChanged?.call(true);
              break;
            default:

              /// set to false
              onChanged?.call(false);
              break;
          }
        }
      },
    );
  }
}
