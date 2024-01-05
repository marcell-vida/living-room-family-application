import 'package:flutter/material.dart';
import 'package:living_room/util/constants.dart';

class DefaultCheckBox extends StatelessWidget {
  final bool? value;
  final Color? activeColor;
  final Color? borderColor;
  final Color? checkColor;
  final double? size;
  final Function(bool?)? onChanged;

  const DefaultCheckBox(
      {Key? key,
      this.value,
      this.activeColor,
      this.borderColor,
      this.checkColor,
      this.size,
      this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Checkbox(
          value: value ?? false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
          side: BorderSide(
              width: 2.0,
              color: borderColor ??
                  (onChanged == null ? AppColors.grey3 : AppColors.purple)),
          activeColor: activeColor ??
              (onChanged == null ? AppColors.grey3 : AppColors.purple),
          checkColor: checkColor ?? AppColors.white,
          onChanged: (newValue) => onChanged?.call(newValue)),
    );
  }
}
