import 'package:bloc/bloc.dart';
import 'package:living_room/service/authentication/authentication_service.dart';
import 'package:living_room/state/screen/verify_email/verify_email_state.dart';

class VerifyEmailCubit extends Cubit<VerifyEmailState> {
  final AuthenticationService _authenticationService;

  VerifyEmailCubit(this._authenticationService)
      : super(const VerifyEmailState());

  void verifyEmail() async {
    if (_authenticationService.currentUser != null) {
      emit(state.copyWith(verifyEmailStatus: VerifyEmailStatus.processing));
      _authenticationService.verifyEmail(onSuccess: (message) async {
        emit(state.copyWith(
            verifyEmailStatus: VerifyEmailStatus.successful,
            successMessage: message));
        _resetStatus(10);
      }, onError: (message) {
        emit(state.copyWith(
            verifyEmailStatus: VerifyEmailStatus.unsuccessful,
            verifyEmailExceptions: message));
        _resetStatus(3);
      });
    }
  }

  Future<void> _resetStatus(int? delayInSeconds) async {
    if (delayInSeconds != null) {
      for (int i = delayInSeconds; i > 0; i--) {
        emit(state.copyWith(countdownSeconds: i));
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    emit(state.copyWith(verifyEmailStatus: VerifyEmailStatus.idle));
  }

  void signOut() async {
    if (_authenticationService.currentUser != null) {
      _authenticationService.signOut();
    }
  }
}
