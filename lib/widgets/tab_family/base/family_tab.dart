import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/state/app/family_selector_bloc.dart';
import 'package:living_room/state/object/families_bloc.dart';
import 'package:living_room/state/object/family_bloc.dart';
import 'package:living_room/state/object/member_bloc.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_avatar.dart';
import 'package:living_room/widgets/default/default_card.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/general/no_overscroll_indicator_list_behavior.dart';
import 'package:living_room/widgets/tab_family/member_tile.dart';

class FamilyTab extends StatelessWidget {
  const FamilyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FamilySelectorCubit>(
      create: (_) => FamilySelectorCubit(
          currentUserFamiliesCubit: context.cubits.currentUserFamilies),
      child: BlocBuilder<FamiliesCubit, FamiliesState>(
          buildWhen: (previous, current) =>
              previous.updateFlag != current.updateFlag,
          builder: (context, state) {
            return BlocBuilder<FamilySelectorCubit, FamilySelectorState>(
                buildWhen: (previous, current) =>
                    previous.selectedFamily != current.selectedFamily,
                builder: (context, state) {
                  return context.cubits.currentUserFamilies.families.isNotEmpty
                      ? _tasksTabContent(context)
                      : const CircularProgressIndicator(
                          color: AppColors.purple);
                });
          }),
    );
  }

  Widget _tasksTabContent(BuildContext context) {
    if (context.cubits.currentUserFamilies.families.isNotEmpty &&
        context.cubits.currentUserFamilies.families.first.state.family?.id !=
            null) {
      /// List of Families is not empty and the first element has a valid id

      /// todo: loading on start up does not stop because family id updates
      /// are not detected

      List<DropdownMenuItem<String>> items = [];

      /// creating a list of items for DropdownButton from user's families
      for (FamilyCubit familyCubit
          in context.cubits.currentUserFamilies.families) {
        if (familyCubit.state.family?.id != null) {
          items.add(DropdownMenuItem(
              value: familyCubit.state.family?.id,
              child: DefaultText(
                context.loc?.familiesTabXFamily(
                        familyCubit.state.family?.name ?? '') ??
                    '',
                fontSize: 24,
                color: AppColors.purple,
              )));
        }
      }

      /// no Family selected yet
      if (context.states.familySelector.selectedFamily == null) {
        context.cubits.familySelector.changeFamily(items.first.value);
      }

      DropdownMenuItem<String>? currentValue = items.first;

      /// selected DropdownMenuItem
      if (items.isNotEmpty) {
        currentValue = items.firstWhereOrNull((element) =>
        element.value ==
            (context.states.familySelector.selectedFamily?.state.family?.id ??
                ''));
      }

      /// selected family's members
      List<MemberCubit> members =
          context.states.familySelector.selectedFamily?.memberCubits ?? [];

      return ScrollConfiguration(
          behavior: NoOverscrollIndicatorBehavior(),
          child: ListView(
            children: [
              DefaultCard(
                child: Column(
                  children: [
                    /// Family photo
                    DefaultAvatar(
                      url: context.states.familySelector.selectedFamily?.state
                          .family?.photoUrl,
                      radius: 130,
                    ),
                    /// Family name and selector
                    Center(
                      child: DropdownButton(
                        alignment: Alignment.centerRight,
                        underline: const SizedBox(),
                        borderRadius: Constants.borderRadius,
                        value: currentValue?.value,
                        items: items,
                        onChanged: (Object? newValue) {
                          if (newValue is String) {
                            context.cubits.familySelector
                                .changeFamily(newValue);
                          }
                        },
                      ),
                    ),
                    /// Family description
                    Center(
                      child: DefaultText(
                        context.states.familySelector.selectedFamily?.state
                                .family?.description ??
                            '',
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              /// Family members
              for (MemberCubit cubit in members)
                DefaultCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: MemberTile(
                      memberCubit: cubit,
                    ),
                  ),
                )
            ],
          ));
    }
    return const CircularProgressIndicator(color: AppColors.purple);
  }
}
