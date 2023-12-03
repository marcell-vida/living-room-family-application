import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/service/authentication/authentication_service.dart';
import 'package:living_room/service/database/database_service.dart';
import 'package:living_room/state/object/family_bloc.dart';
import 'package:living_room/util/utils.dart';

class UnacceptedInvitationCubit extends Cubit<UnacceptedInvitationState> {
  final AuthenticationService _authenticationService;
  final DatabaseService _databaseService;
  final FamilyCubit familyCubit;
  StreamSubscription? _familyCubitStreamSubscription;

  UnacceptedInvitationCubit(
      {required AuthenticationService authenticationService,
      required DatabaseService databaseService,
      required this.familyCubit})
      : _authenticationService = authenticationService,
        _databaseService = databaseService,
        super(const UnacceptedInvitationState()) {
    _init();
  }

  void _init() {
    _familyCubitStreamSubscription = familyCubit.stream.listen((event) {
      emit(state.copyWith());
    });
  }

  Future<void> accept() async {
    emit(state.copyWith(processStatus: ProcessStatus.processing));
    String signedInUserId = _authenticationService.currentUser?.uid ?? '';
    String familyId = familyCubit.state.invitation?.familyId ?? '';
    if (signedInUserId.isEmpty || familyId.isEmpty) {
      emit(state.copyWith(processStatus: ProcessStatus.unsuccessful));
      return;
    }
    await _databaseService.createFamilyMember(
        userId: signedInUserId, familyId: familyId);

    _databaseService.updateUserInvitation(
        userId: signedInUserId,
        familyId: familyId,
        accepted: true,
        onSuccess: () =>
            emit(state.copyWith(processStatus: ProcessStatus.successful)),
        onError: () =>
            emit(state.copyWith(processStatus: ProcessStatus.unsuccessful)));
  }

  void decline() {
    emit(state.copyWith(processStatus: ProcessStatus.processing));
    String signedInUserId = _authenticationService.currentUser?.uid ?? '';
    String familyId = familyCubit.state.invitation?.familyId ?? '';

    if (signedInUserId.isEmpty || familyId.isEmpty) {
      emit(state.copyWith(processStatus: ProcessStatus.unsuccessful));
      return;
    }

    _databaseService.deleteInvitation(
        userId: signedInUserId,
        familyId: familyId,
        onSuccess: () =>
            emit(state.copyWith(processStatus: ProcessStatus.successful)),
        onError: () =>
            emit(state.copyWith(processStatus: ProcessStatus.unsuccessful)));
  }

  @override
  Future<void> close() {
    _familyCubitStreamSubscription?.cancel();
    return super.close();
  }
}

class UnacceptedInvitationState extends Equatable {
  final bool updateFlag;
  final ProcessStatus? processStatus;

  const UnacceptedInvitationState({this.processStatus, this.updateFlag = true});

  UnacceptedInvitationState copyWith({ProcessStatus? processStatus}) {
    return UnacceptedInvitationState(
        processStatus: processStatus ?? this.processStatus,
        updateFlag: !updateFlag);
  }

  @override
  List<Object?> get props => [updateFlag];
}
