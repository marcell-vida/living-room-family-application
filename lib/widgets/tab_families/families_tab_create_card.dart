import 'package:flutter/material.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/util/general_family_editor.dart';
import 'package:living_room/widgets/default/default_card.dart';

class FamiliesTabCreateCard extends StatelessWidget {
  const FamiliesTabCreateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultCard(
      child: Center(
        child: IconButton(
            onPressed: () => _onCreateFamily(context),
            icon: const Icon(
              Icons.add,
              color: AppColors.purple,
              size: 30,
            )),
      ),
    );
  }

  void _onCreateFamily(BuildContext context) {
    GeneralFamilyEditor(
            defaultContext: context,
            title: context.loc?.familiesTabCreateAddFamily,
            slider: context.loc?.generalAddSlide)
        .show();
  }
}
