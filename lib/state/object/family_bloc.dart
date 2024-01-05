import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/string_extension.dart';
import 'package:living_room/main.dart';
import 'package:living_room/model/database/families/family.dart';
import 'package:living_room/model/database/families/family_member.dart';
import 'package:living_room/model/database/users/invitation.dart';
import 'package:living_room/service/authentication/authentication_service.dart';
import 'package:living_room/service/database/database_service.dart';
import 'package:living_room/state/object/member_bloc.dart';

class FamilyCubit extends Cubit<FamilyState> {
  final String familyId;
  final AuthenticationService _authenticationService;

  final DatabaseService _databaseService;
  final List<MemberCubit> memberCubits;

  StreamSubscription? familyStreamSubscription;
  StreamSubscription? membersStreamSubscription;

  FamilyCubit(
      {required AuthenticationService authenticationService,
      required DatabaseService databaseService,
      required this.familyId})
      : _authenticationService = authenticationService,
        _databaseService = databaseService,
        memberCubits = [],
        super(const FamilyState()) {
    log.d('FamilyCubit created with familyId == $familyId');
    _init();
  }

  void _init() {
    if (familyId.isNotEmpty) {
      familyStreamSubscription =
          _databaseService.streamFamily(familyId).listen((Family? family) {
        emit(state.copyWith(family: family));
      });

      membersStreamSubscription = _databaseService
          .streamFamilyMembers(familyId: familyId)
          .listen(_updateMemberCubits);
    }
  }

  void setInvitation(Invitation newValue) {
    emit(state.copyWith(invitation: newValue));
  }

  MemberCubit? getMemberById(String? id) {
    if (id.isNotEmptyOrNull) {
      return memberCubits
          .firstWhereOrNull((element) => element.state.member?.id == id);
    }
    return null;
  }

  MemberCubit? getSignedInMember() {
    String? id = _authenticationService.currentUser?.uid;

    if (id.isNotEmptyOrNull) {
      return memberCubits
          .firstWhereOrNull((element) => element.state.member?.id == id);
    }
    return null;
  }

  void _updateMemberCubits(List<FamilyMember>? newMembers) {
    if (newMembers == null || newMembers.isEmpty) {
      // clear members
      if (memberCubits.isNotEmpty) {
        // previously there were members, now all of them has to be deleted
        for (MemberCubit cubit in memberCubits) {
          cubit.close();
        }
        memberCubits.clear();
      }
      emit(state.copyWith());
    } else {
      // clear removed invitations
      memberCubits.removeWhere((element) {
        for (var e in newMembers) {
          if (e.id == element.userId) {
            debugPrint('Keeping member: element.userId == ${element.userId}');
            return false;
          }
        }
        // remove this
        return true;
      });

      // update or create families
      List<MemberCubit> addList = [];

      for (FamilyMember element in newMembers) {
        /// iterate through streamed elements
        bool isUpdate = false;
        for (MemberCubit memberCubit in memberCubits) {
          /// iterate through saved members
          if (memberCubit.userId == element.id) {
            /// [MemberCubit] already created for this [Member], this is an update
            isUpdate = true;
            break;
          }
        }
        if (!isUpdate && element.id != null) {
          /// [MemberCubit] was not created for this [Member] previously
          MemberCubit newCubit = MemberCubit(
              databaseService: _databaseService,
              familyId: familyId,
              userId: element.id!);

          addList.add(newCubit);
        }
      }

      if (addList.isNotEmpty) memberCubits.addAll(addList);
    }

    String memberCubitsList = 'MemberCubits in list:';

    for (var member in memberCubits) {
      memberCubitsList += '${member.userId}\n';
    }

    log.d(memberCubitsList);

    emit(state.copyWith());
  }

  @override
  Future<void> close() {
    membersStreamSubscription?.cancel();
    familyStreamSubscription?.cancel();
    return super.close();
  }
}

class FamilyState extends Equatable {
  final Family? family;
  final bool updateFlag;
  final Invitation? invitation;

  const FamilyState({this.family, this.invitation, this.updateFlag = true});

  FamilyState copyWith({Family? family, Invitation? invitation}) {
    return FamilyState(
        family: family ?? this.family,
        invitation: invitation ?? this.invitation,
        updateFlag: !updateFlag);
  }

  @override
  List<Object?> get props => [family, invitation];
}
