import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/string_extension.dart';
import 'package:living_room/model/database/users/invitation.dart';
import 'package:living_room/service/authentication/authentication_service.dart';
import 'package:living_room/service/database/database_service.dart';
import 'package:living_room/state/object/family_bloc.dart';

class FamiliesCubit extends Cubit<FamiliesState> {
  final DatabaseService _databaseService;
  final AuthenticationService _authenticationService;
  final List<FamilyCubit> families;
  StreamSubscription? _invitationsStreamSubscription;

  FamiliesCubit(
      {required DatabaseService databaseService,
      required AuthenticationService authenticationService})
      : _databaseService = databaseService,
        _authenticationService = authenticationService,
        families = <FamilyCubit>[],
        super(const FamiliesState()) {
    _init();
  }

  void _init() {
    _invitationsStreamSubscription = _databaseService
        .streamUserInvitations(
            userId: _authenticationService.currentUser?.uid ?? '')
        .listen(_updateFamilyCubits);
  }

  FamilyCubit? getFamilyById(String? id) {
    if (id.isNotEmptyOrNull) {
      return families.firstWhereOrNull((element) => element.familyId == id);
    }
    return null;
  }

  void _updateFamilyCubits(List<Invitation>? invitations) {
    if (invitations == null || invitations.isEmpty) {
      // clear families
      if (families.isNotEmpty) {
        // previously there were invitations, now all of them has to be deleted
        for (FamilyCubit cubit in families) {
          cubit.close();
        }
        families.clear();
      }
      emit(state.copyWith());
    } else {
      // clear removed invitations
      families.removeWhere((element) {
        if (element.state.invitation == null ||
            !invitations.contains(element.state.invitation)) {
          element.close();
          return true;
        }
        return false;
      });

      // update or create families
      List<FamilyCubit> addList = [];

      for (Invitation invitation in invitations) {
        bool isUpdate = false;
        for (FamilyCubit familyCubit in families) {
          if (familyCubit.state.invitation != null &&
              familyCubit.state.invitation!.idNotNullOrEmpty) {
            // Family already created for this invitation, this is an update
            isUpdate = true;
            familyCubit.setInvitation(invitation);
          }
        }
        if (!isUpdate && invitation.familyId != null) {
          // Family was not created for this invitation previously
          FamilyCubit newCubit = FamilyCubit(
              authenticationService: _authenticationService,
              databaseService: _databaseService,
              familyId: invitation.familyId!);

          newCubit.setInvitation(invitation);

          addList.add(newCubit);
        }
      }

      if (addList.isNotEmpty) families.addAll(addList);
    }
    emit(state.copyWith());
  }

  @override
  Future<void> close() {
    _invitationsStreamSubscription?.cancel();
    return super.close();
  }
}

class FamiliesState extends Equatable {
  final bool updateFlag;

  const FamiliesState({this.updateFlag = true});

  FamiliesState copyWith() {
    return FamiliesState(updateFlag: !updateFlag);
  }

  @override
  List<Object?> get props => [updateFlag];
}
