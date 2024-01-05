import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/model/database/families/family_member.dart';
import 'package:living_room/state/object/family_bloc.dart';
import 'package:living_room/state/object/member_bloc.dart';
import 'package:living_room/state/sheet/family/unaccepted_invitation_bloc.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/util/utils.dart';
import 'package:living_room/widgets/default/default_button.dart';
import 'package:living_room/widgets/default/default_expansion_tile.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/general/list_item_with_picture_icon.dart';
import 'package:living_room/widgets/general/titled_divider.dart';
import 'package:living_room/widgets/spacers.dart';

class FamilyInvitationTile extends StatelessWidget {
  final FamilyCubit familyCubit;

  const FamilyInvitationTile({super.key, required this.familyCubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UnacceptedInvitationCubit>(
      create: (_) => UnacceptedInvitationCubit(
          databaseService: context.services.database,
          familyCubit: familyCubit,
          authenticationService: context.services.authentication),
      child: BlocBuilder<UnacceptedInvitationCubit, UnacceptedInvitationState>(
          builder: (context, state) {
        String familyName =
            context.cubits.unacceptedInvite.familyCubit.state.family?.name ??
                '';

        return BlocListener<UnacceptedInvitationCubit,
                UnacceptedInvitationState>(
            listener: (context, state) {
              if (state.processStatus == ProcessStatus.successful) {
                context
                    .showSnackBar(context.loc?.globalSuccessfulOperation ?? '');
              } else if (state.processStatus == ProcessStatus.unsuccessful) {
                context.showSnackBar(
                    context.loc?.globalUnsuccessfulOperation ?? '');
              }
            },
            child: DefaultExpansionTile(
                title: context.loc?.familiesTabXFamiliesInvitation(familyName),
                children: _tileContent(context, state)));
      }),
    );
  }

  List<Widget> _tileContent(
      BuildContext context, UnacceptedInvitationState state) {
    String invMessage = familyCubit.state.invitation?.message ?? '';
    String senderId = familyCubit.state.invitation?.sender ?? '';
    MemberCubit? sender = familyCubit.getMemberById(senderId);

    return <Widget>[
      if (invMessage.isNotEmpty) ...[
        DefaultText(
          invMessage,
          color: AppColors.purple,
        )
      ],
      if (sender?.state.user != null) ...[
        const VerticalSpacer.of20(),
        TitledDivider(title: context.loc?.familiesTabInvitationSender),
        const VerticalSpacer.of10(),
        ListItemWithPictureIcon(
            title: sender!.state.user!.displayName,
            photoUrl: sender.state.user!.photoUrl,
            icon: sender.state.member != null
                ? _iconOfPerson(sender.state.member!)
                : null)
      ],
      const VerticalSpacer.of60(),
      DefaultButton(
          isLoading: state.processStatus == ProcessStatus.processing,
          leadIcon: Icons.done,
          text: context.loc?.globalAccept,
          callback: () => context.cubits.unacceptedInvite.accept()),
      const VerticalSpacer.of10(),
      DefaultButton(
          elevation: 0,
          color: AppColors.white.withOpacity(0.15),
          borderColor: AppColors.red,
          textColor: AppColors.red,
          isLoading: state.processStatus == ProcessStatus.processing,
          leadIcon: Icons.close,
          text: context.loc?.globalDecline,
          callback: () => context.cubits.unacceptedInvite.decline())
    ];
  }

  IconData _iconOfPerson(FamilyMember member) {
    return member.isCreator == true
        ? Icons.admin_panel_settings_outlined
        : member.isParent == true
            ? Icons.person
            : Icons.people_alt_outlined;
  }
}
