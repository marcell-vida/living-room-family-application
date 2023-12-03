import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/string_extension.dart';
import 'package:living_room/model/database/families/family.dart';
import 'package:living_room/model/database/families/family_member.dart';
import 'package:living_room/model/database/users/invitation.dart';
import 'package:living_room/service/authentication/authentication_service.dart';
import 'package:living_room/service/database/database_service.dart';
import 'package:collection/collection.dart';
import 'package:living_room/state/object/member_bloc.dart';

class FamilyCubit extends Cubit<FamilyState> {
  final String familyId;
  final AuthenticationService _authenticationService;

  final DatabaseService _databaseService;
  final List<MemberCubit> memberCubits;

  // final List<StreamSubscription<DatabaseUser?>>
  //     _individualUsersStreamSubscription;

  StreamSubscription? familyStreamSubscription;
  StreamSubscription? membersStreamSubscription;

  FamilyCubit(
      {required AuthenticationService authenticationService,
      required DatabaseService databaseService,
      required this.familyId})
      : _authenticationService = authenticationService,
        _databaseService = databaseService,
        // _individualUsersStreamSubscription = [],
        memberCubits = [],
        super(const FamilyState()) {
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
        if (element.state.member == null ||
            !newMembers.contains(element.state.member)) {
          element.close();
          // remove this
          return true;
        }
        // do not remove this
        return false;
      });

      // update or create families
      List<MemberCubit> addList = [];

      for (FamilyMember element in newMembers) {
        bool isUpdate = false;
        for (MemberCubit memberCubit in memberCubits) {
          if (memberCubit.state.member != null &&
              memberCubit.state.member!.idNotNullOrEmpty) {
            /// [MemberCubit] already created for this [Member], this is an update
            isUpdate = true;
          }
        }
        if (!isUpdate && element.id.isNotEmptyOrNull) {
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
    emit(state.copyWith());
  }

  // void _updateMembers(List<FamilyMember>? newMembers) async {
  //   if (newMembers == null) {
  //     // empty list
  //     emit(state.copyWith(membersUsers: {}));
  //     return;
  //   }
  //
  //   List<DatabaseUser>? allUsers = await _databaseService.getUsers();
  //
  //   Map<FamilyMember, DatabaseUser> newList = {};
  //
  //   _individualUsersStreamSubscription.clearSubscriptions();
  //
  //   for (FamilyMember currentMember in newMembers) {
  //     if (allUsers != null) {
  //       // get DatabaseUser for member
  //       DatabaseUser? currentUser = currentMember.getUserFromList(allUsers);
  //       if (currentUser != null) {
  //         // add gotten user to list
  //         newList[currentMember] = currentUser;
  //         _individualUsersStreamSubscription.addSubscriptions(
  //             usersToAdd: [currentUser],
  //             onUserUpdates: (DatabaseUser? user) {
  //               FamilyMember member = currentMember;
  //               _updateUser(member, user);
  //             },
  //             databaseService: _databaseService);
  //       }
  //     }
  //   }
  //
  //   emit(state.copyWith(membersUsers: newList));
  // }

  // void _updateUser(FamilyMember member, DatabaseUser? user) {
  //   if (user == null) return;
  //
  //   Map<FamilyMember, DatabaseUser>? newList = state.membersUsers;
  //   if(newList != null){
  //     newList[member] = user;
  //     emit(state.copyWith(membersUsers: newList));
  //   }
  // }

  @override
  Future<void> close() {
    // _individualUsersStreamSubscription.clearSubscriptions();
    membersStreamSubscription?.cancel();
    familyStreamSubscription?.cancel();
    return super.close();
  }
}

class FamilyState extends Equatable {
  final Family? family;

  // final Map<FamilyMember, DatabaseUser>? membersUsers;
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
