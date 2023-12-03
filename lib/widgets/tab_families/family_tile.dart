import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/model/database/families/family_member.dart';
import 'package:living_room/state/object/family_bloc.dart';
import 'package:living_room/state/object/member_bloc.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/util/general_family_editor.dart';
import 'package:living_room/widgets/default/default_avatar.dart';
import 'package:living_room/widgets/default/default_button.dart';
import 'package:living_room/widgets/default/default_container.dart';
import 'package:living_room/widgets/default/default_expansion_tile.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/general/list_item_with_picture_icon.dart';
import 'package:living_room/widgets/spacers.dart';

class FamilyTile extends StatelessWidget {
  final FamilyCubit familyCubit;

  const FamilyTile({super.key, required this.familyCubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FamilyCubit>.value(
      value: familyCubit,
      child: BlocBuilder<FamilyCubit, FamilyState>(builder: (context, state) {
        return DefaultExpansionTile(
          title: context.loc?.familiesTabXFamily(state.family?.name ?? ''),
          leading: familyCubit.state.family?.photoUrl != null
              ? DefaultAvatar(
                  url: familyCubit.state.family?.photoUrl,
                  radius: 18,
                )
              : null,
          children: _tileContent(context, state, familyCubit),
        );
      }),
    );
  }

  List<Widget> _tileContent(
      BuildContext context, FamilyState state, FamilyCubit cubit) {
    String description = familyCubit.state.family?.description ?? '';

    return <Widget>[
      if (description.isNotEmpty) ...[
        Align(
          alignment: Alignment.center,
          child: DefaultText(
            description,
            color: AppColors.grey,
          ),
        ),
        const VerticalSpacer.of40(),
      ],
      if (familyCubit.memberCubits.isNotEmpty)
        for (MemberCubit current in familyCubit.memberCubits) ...[
          BlocBuilder<MemberCubit, MemberState>(
              bloc: current,
              builder: (context, state) {
                if (current.state.user != null) {
                  return ListItemWithPictureIcon(
                    title: current.state.user!.displayName,
                    photoUrl: current.state.user!.photoUrl,
                    icon: current.state.member != null
                        ? _iconOfPerson(current.state.member!)
                        : null,
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              }),
          const VerticalSpacer.of10()
        ],
      const VerticalSpacer.of20(),
      DefaultButton(
          text: context.loc?.globalEdit,
          callback: () => _onModify(context, cubit))
    ];
  }

  void _onModify(BuildContext context, FamilyCubit cubit) {
    GeneralFamilyEditor(
            existingFamilyCubit: cubit,
            defaultContext: context,
            title:
                context.loc?.familiesTabXFamily(cubit.state.family?.name ?? ''),
            slider: context.loc?.globalModifySlide)
        .show();
  }

  IconData _iconOfPerson(FamilyMember member) {
    return member.isCreator == true
        ? Icons.admin_panel_settings_outlined
        : member.isParent == true
            ? Icons.person
            : Icons.people_alt_outlined;
  }
}
