import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/extension/result/success_message_extension.dart';
import 'package:living_room/extension/result/verify_email_exception_extension.dart';
import 'package:living_room/screen/base/content_in_card_base_screen.dart';
import 'package:living_room/state/screen/verify_email/verify_email_cubit.dart';
import 'package:living_room/state/screen/verify_email/verify_email_state.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_button.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/spacers.dart';

class VerifyEmailScreen extends ContentInCardBaseScreen {
  const VerifyEmailScreen({super.key});

  @override
  Widget onBuild(BuildContext context) {
    return BlocProvider<VerifyEmailCubit>(
      create: (context) => VerifyEmailCubit(context.services.authentication),
      child: Builder(builder: (context) {
        return BlocListener<VerifyEmailCubit, VerifyEmailState>(
          listenWhen: (previous, current) =>
              previous.verifyEmailStatus != current.verifyEmailStatus,
          listener: (context, state) {
            if (state.verifyEmailStatus == VerifyEmailStatus.successful) {
              context.hidePreviousShowNewSnackBar(
                  state.successMessage?.getMessage(context) ??
                      context.loc?.verifyEmailSuccessSent ??
                      '');
            } else if (state.verifyEmailStatus ==
                    VerifyEmailStatus.unsuccessful &&
                state.verifyEmailExceptions != null) {
              context.hidePreviousShowNewSnackBar(
                  state.verifyEmailExceptions?.getErrorMessage(context) ??
                      context.loc?.globalExceptionUnknownError ??
                      '');
            } else if (state.verifyEmailStatus ==
                VerifyEmailStatus.processing) {
              context.hidePreviousShowNewSnackBar(
                  context.loc?.globalProcessingRequest ?? '');
            }
          },
          child: Column(
            children: [
              DefaultText(
                context.loc?.verifyEmailScreenVerifyYourEmail ?? '',
                color: AppColors.white,
                textAlign: TextAlign.center,
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
              const VerticalSpacer.of40(),
              BlocBuilder<VerifyEmailCubit, VerifyEmailState>(
                  buildWhen: (previous, current) =>
                      previous.verifyEmailStatus != current.verifyEmailStatus ||
                      previous.countdownSeconds != current.countdownSeconds,
                  builder: (context, state) {
                    return DefaultButton(
                        text: state.countdownSeconds != null
                            ? state.countdownSeconds.toString()
                            : context.loc?.verifyEmailScreenSendVerify,
                        isLoading: state.verifyEmailStatus ==
                            VerifyEmailStatus.processing,
                        isEnabled: (state.verifyEmailStatus !=
                                VerifyEmailStatus.processing) &&
                            (state.verifyEmailStatus !=
                                VerifyEmailStatus.successful) &&
                            (state.verifyEmailStatus !=
                                VerifyEmailStatus.unsuccessful),
                        color: AppColors.purple,
                        callback: () =>
                            context.read<VerifyEmailCubit>().verifyEmail());
                  }),
              const VerticalSpacer.of13(),
              DefaultButton(
                  text: context.loc?.globalSignOut,
                  elevation: 0,
                  color: AppColors.white.withOpacity(0.15),
                  borderColor: AppColors.whiteOp30,
                  textColor: AppColors.purple,
                  callback: () => context.read<VerifyEmailCubit>().signOut()),
            ],
          ),
        );
      }),
    );
  }
}
