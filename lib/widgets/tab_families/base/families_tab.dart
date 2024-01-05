import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/state/object/families_bloc.dart';
import 'package:living_room/state/object/family_bloc.dart';
import 'package:living_room/widgets/default/default_card.dart';
import 'package:living_room/widgets/general/no_overscroll_indicator_list_behavior.dart';
import 'package:living_room/widgets/tab_families/families_tab_create_card.dart';
import 'package:living_room/widgets/tab_families/family_invitation_tile.dart';
import 'package:living_room/widgets/tab_families/family_tile.dart';

class FamiliesTab extends StatelessWidget {
  const FamiliesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FamiliesCubit, FamiliesState>(
        buildWhen: (previous, current) =>
            previous.updateFlag != current.updateFlag,
        builder: (context, state) {
          return _familiesTabContent(
              context, context.cubits.currentUserFamilies.families);
        });
  }

  Widget _familiesTabContent(BuildContext context, List<FamilyCubit> list) {
    List<Widget> unacceptedContent = [];
    List<Widget> acceptedContent = [];

    for (FamilyCubit element in list) {
      if (element.state.invitation != null &&
          element.state.invitation!.accepted == true) {
        acceptedContent.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: FamilyTile(familyCubit: element),
        ));
      } else if (element.state.invitation != null) {
        unacceptedContent.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: FamilyInvitationTile(familyCubit: element),
        ));
      }
    }

    return ScrollConfiguration(
      behavior: NoOverscrollIndicatorBehavior(),
      child: ListView(
        children: [
          if (unacceptedContent.isNotEmpty)
            DefaultCard(
              title: context.loc?.familiesTabInvitations,
              iconData: Icons.handshake_outlined,
              child: Column(
                children: unacceptedContent,
              ),
            ),
          if (acceptedContent.isNotEmpty)
            DefaultCard(
              title: context.loc?.familiesTabManageFamilies,
              iconData: Icons.people,
              child: Column(
                children: acceptedContent,
              ),
            ),
          const FamiliesTabCreateCard()
        ],
      ),
    );
  }
}
