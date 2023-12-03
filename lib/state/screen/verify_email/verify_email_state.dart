import 'package:equatable/equatable.dart';
import 'package:living_room/extension/result/success_message_extension.dart';
import 'package:living_room/extension/result/verify_email_exception_extension.dart';

enum VerifyEmailStatus { idle, processing, successful, unsuccessful }

class VerifyEmailState extends Equatable {
  final VerifyEmailStatus? verifyEmailStatus;
  final int? countdownSeconds;
  final VerifyEmailException? verifyEmailExceptions;
  final SuccessMessage? successMessage;

  const VerifyEmailState(
      {this.successMessage,
        this.countdownSeconds,
        this.verifyEmailStatus,
        this.verifyEmailExceptions});

  VerifyEmailState copyWith(
      {VerifyEmailStatus? verifyEmailStatus,
        int? countdownSeconds,
        VerifyEmailException? verifyEmailExceptions,
        SuccessMessage? successMessage}) {
    return VerifyEmailState(
        verifyEmailStatus: verifyEmailStatus ?? this.verifyEmailStatus,
        countdownSeconds: countdownSeconds,
        verifyEmailExceptions:
        verifyEmailExceptions ?? this.verifyEmailExceptions,
        successMessage: successMessage ?? this.successMessage);
  }

  @override
  List<Object?> get props => [
    verifyEmailStatus,
    countdownSeconds,
    verifyEmailExceptions,
    successMessage
  ];
}
