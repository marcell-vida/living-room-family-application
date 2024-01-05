import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/state/object/member_bloc.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_avatar.dart';
import 'package:living_room/widgets/default/default_button.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/spacers.dart';

class MemberDetails extends StatelessWidget {
  final MemberCubit memberCubit;
  final MemberCubit? signedInMember;

  const MemberDetails(
      {super.key, required this.memberCubit, this.signedInMember});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MemberCubit>.value(
      value: memberCubit,
      child: BlocBuilder<MemberCubit, MemberState>(
          bloc: memberCubit,
          builder: (blocContext, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: _content(blocContext, state),
              ),
            );
          }),
    );
  }

  List<Widget> _content(BuildContext blocContext, MemberState state) {
    String name = state.user?.displayName ?? '';
    String email = state.user?.email ?? '';
    String photo = state.user?.photoUrl ?? '';
    String type = (state.member?.isCreator == true
            ? blocContext.loc?.globalTypeCreator
            : state.member?.isParent == true
                ? blocContext.loc?.globalTypeParent
                : blocContext.loc?.globalTypeChild) ??
        '';

    return <Widget>[
      /// photo
      if (photo.isNotEmpty) ...[
        DefaultAvatar(
          url: photo,
          radius: 110,
          borderColor: AppColors.purple,
          borderWidth: Constants.borderWidth,
        ),
        const VerticalSpacer.of10()
      ],

      /// name
      DefaultText(
        name,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        textAlign: TextAlign.center,
      ),

      if (signedInMember?.userId == memberCubit.userId) ...[
        const VerticalSpacer.of10(),
        DefaultText(
          blocContext.loc?.globalMe ?? '',
          color: AppColors.blue,
          fontSize: 18,
        ),
        const VerticalSpacer.of10(),
      ],

      /// type
      DefaultText(
        type,
        color: AppColors.grey,
        textAlign: TextAlign.center,
      ),
      const VerticalSpacer.of20(),

      /// email
      DefaultText(
        email,
        color: AppColors.grey,
        textAlign: TextAlign.center,
      ),
      const VerticalSpacer.of60(),

      /// buttons to remove and upgrade members
      if (signedInMember?.state.member?.isCreator == true &&
          signedInMember?.userId != memberCubit.userId) ...[
        if (memberCubit.state.member?.isParent != true)
          DefaultButton(
              text: blocContext.loc?.globalDeclareAsParent,
              color: AppColors.sand,
              callback: () {
                //todo
              }),
        const VerticalSpacer.of20(),
        DefaultButton(
            color: AppColors.red,
            text: blocContext.loc?.globalRemoveUser,
            callback: () {
              //todo
            }),
      ]
    ];
  }
}
