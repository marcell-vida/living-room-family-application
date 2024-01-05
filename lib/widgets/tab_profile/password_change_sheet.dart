import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/extension/result/invalid_input_extension.dart';
import 'package:living_room/state/screen/profile/password_settings_bloc.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/util/utils.dart';
import 'package:living_room/widgets/default/default_button.dart';
import 'package:living_room/widgets/default/default_input_field.dart';
import 'package:living_room/widgets/default/default_slider.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/spacers.dart';

class PasswordChangeSheet extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  PasswordChangeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PasswordSettingsCubit>(
      create: (_) => PasswordSettingsCubit(
          authenticationService: context.services.authentication),
      child: BlocBuilder<PasswordSettingsCubit, PasswordSettingsState>(
          buildWhen: (previous, current) =>
              previous.saveStatus != current.saveStatus,
          builder: (context, state) {
            if (state.saveStatus == ProcessStatus.processing) {
              return const CircularProgressIndicator(
                color: AppColors.purple,
              );
            } else if (state.saveStatus == ProcessStatus.successful) {
              return Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.green,
                    size: 50,
                  ),
                  const VerticalSpacer.of10(),
                  DefaultText(
                    context.loc?.globalSuccessfulOperation ?? '',
                    color: AppColors.grey2,
                  ),
                  const VerticalSpacer.of60(),
                  DefaultButton(
                      text: context.loc?.generalDone,
                      callback: () => context.navigator.pop())
                ],
              );
            } else if (state.saveStatus == ProcessStatus.unsuccessful) {
              return Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.red,
                    size: 50,
                  ),
                  const VerticalSpacer.of10(),
                  DefaultText(
                    context.loc?.globalUnsuccessfulOperation ?? '',
                    color: AppColors.red,
                  ),
                  const VerticalSpacer.of60(),
                  DefaultButton(
                      text: context.loc?.generalDone,
                      callback: () => context.navigator.pop())
                ],
              );
            }
            PasswordSettingsCubit cubit = context.cubits.passwordSettings;
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  DefaultText(
                    context.loc?.profileChangePassword ?? '',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.center,
                  ),
                  const VerticalSpacer.of23(),
                  DefaultInputField(
                    hintText: context.loc?.profileTabOldPassword,
                    obscureText: true,
                    textColor: AppColors.purple,
                    defaultBorderColor: AppColors.purple,
                    callback: (changeTo) => cubit.modifyOldPassword(changeTo),
                    validator: () => cubit.state.isOldPasswordValid,
                    validatorMessage: () => cubit
                        .state.invalidOldPasswordMessage
                        ?.getErrorMessage(context),
                    textInputAction: TextInputAction.next,
                    leadIcon: Icons.lock_outlined,
                  ),
                  const VerticalSpacer.of23(),
                  DefaultInputField(
                    hintText: context.loc?.globalPassword,
                    obscureText: true,
                    textColor: AppColors.purple,
                    defaultBorderColor: AppColors.purple,
                    callback: (changeTo) => cubit.modifyPassword(changeTo),
                    validator: () => cubit.state.isPasswordValid,
                    validatorMessage: () => cubit.state.invalidPasswordMessage
                        ?.getErrorMessage(context),
                    textInputAction: TextInputAction.next,
                    leadIcon: Icons.lock_outlined,
                  ),
                  const VerticalSpacer.of10(),
                  DefaultInputField(
                    hintText: context.loc?.globalPasswordAgain,
                    obscureText: true,
                    textColor: AppColors.purple,
                    defaultBorderColor: AppColors.purple,
                    callback: (changeTo) => cubit.modifyPasswordAgain(changeTo),
                    validator: () => cubit.state.isPasswordAgainValid,
                    validatorMessage: () => cubit
                        .state.invalidPasswordAgainMessage
                        ?.getErrorMessage(context),
                    textInputAction: TextInputAction.done,
                    leadIcon: Icons.lock_outlined,
                  ),
                  const VerticalSpacer.of20(),
                  DefaultSlider(
                    stickToEnd: false,
                    onConfirmation: () {
                      cubit.validate();
                      if (_formKey.currentState!.validate()) {
                        cubit.setPassword();
                      }
                    },
                    title: context.loc?.globalApproveSlide,
                  )
                ],
              ),
            );
          }),
    );
  }
}
