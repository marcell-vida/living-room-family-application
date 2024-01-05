import 'package:flutter/material.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_text.dart';

class TitledDivider extends StatelessWidget {
  final String? title;

  const TitledDivider({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Divider(
          thickness: 3,
          color: AppColors.purple,
        ),
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: Constants.borderRadius,
                    border: Border.all(
                        color: AppColors.purple, width: Constants.borderWidth)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  child: DefaultText(
                    title ?? '',
                    color: AppColors.purple,
                  ),
                )),
          ),
      ],
    );
  }
}
