import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/screen/base/content_in_card_base_screen.dart';
import 'package:living_room/state/screen/sign_in/sign_in_cubit.dart';
import 'package:living_room/state/screen/sign_in/sign_in_state.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/util/utils.dart';
import 'package:living_room/widgets/default/default_button.dart';
import 'package:living_room/widgets/default/default_input_field.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/default/default_text_button.dart';
import 'package:living_room/widgets/spacers.dart';
import 'package:living_room/extension/result/success_message_extension.dart';
import 'package:living_room/extension/result/auth_exception_extension.dart';
import 'package:living_room/extension/result/invalid_input_extension.dart';

class SignInScreen extends ContentInCardBaseScreen {
  final _formKey = GlobalKey<FormState>();

  SignInScreen({Key? key}) : super(key: key);

  @override
  Widget onBuild(BuildContext context) {
    return BlocProvider<SignInCubit>(
        create: (_) => SignInCubit(context.services.authentication),
        child: Builder(builder: (context) {
          return BlocListener<SignInCubit, SignInState>(
            listenWhen: (previous, current) =>
                previous.signInStatus != current.signInStatus,
            listener: (context, state) {
              if (state.signInStatus == ProcessStatus.successful) {
                context.hidePreviousShowNewSnackBar(
                    state.successMessage?.getMessage(context) ??
                        context.loc?.signInSuccess ??
                        '');
              } else if (state.signInStatus == ProcessStatus.unsuccessful &&
                  state.authException != null) {
                context.hidePreviousShowNewSnackBar(
                    state.authException?.getErrorMessage(context) ??
                        context.loc?.globalExceptionUnknownError ??
                        '');
              } else if (state.signInStatus == ProcessStatus.processing) {
                context.hidePreviousShowNewSnackBar(
                    context.loc?.globalProcessingRequest ?? '');
              }
            },
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(AppImages.appIcon, height: 150,),
                  const VerticalSpacer.of13(),
                  DefaultText(
                    context.loc?.appName ?? '',
                    color: AppColors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                  const VerticalSpacer.of40(),
                  _emailField(context),
                  const VerticalSpacer.of13(),
                  _passwordField(context),
                  const VerticalSpacer.of13(),
                  DefaultTextButton(
                    text: context.loc?.signInScreenForgotPassword,
                    textColor: AppColors.white,
                  ),
                  const VerticalSpacer.of40(),
                  _signInButton(context),
                  const VerticalSpacer.of13(),
                  _signUpButton(context),
                ],
              ),
            ),
          );
        }));
  }

  Widget _emailField(BuildContext context) {
    return DefaultInputField(
      callback: (changeTo) => context.cubits.signIn.modifyEmail(changeTo),
      hintText: context.loc?.globalEmail,
      validator: () => context.cubits.signIn.isEmailValid,
      validatorMessage: () =>
          context.states.signIn.invalidEmailMessage?.getErrorMessage(context),
      textInputAction: TextInputAction.next,
      leadIcon: Icons.email_outlined,
    );
  }

  Widget _passwordField(BuildContext context) {
    return BlocBuilder<SignInCubit, SignInState>(
        buildWhen: (previous, current) =>
            previous.obscurePassword != current.obscurePassword,
        builder: (context, state) {
          return DefaultInputField(
            initialValue: state.password,
            hintText: context.loc?.globalPassword,
            obscureText: state.obscurePassword,
            obscureIconTap: context.cubits.signIn.toggleObscurePassword,
            callback: (changeTo) =>
                context.cubits.signIn.modifyPassword(changeTo),
            validator: () => context.cubits.signIn.isPasswordValid,
            validatorMessage: () => context.states.signIn.invalidPasswordMessage
                ?.getErrorMessage(context),
            textInputAction: TextInputAction.done,
            leadIcon: Icons.lock_outlined,
          );
        });
  }

  Widget _signInButton(BuildContext context) {
    return BlocBuilder<SignInCubit, SignInState>(
        buildWhen: (previous, current) =>
            previous.signInStatus != current.signInStatus,
        builder: (context, state) {
          return DefaultButton(
              text: context.loc?.globalSignIn,
              isLoading: state.signInStatus == ProcessStatus.processing,
              isEnabled: state.signInStatus != ProcessStatus.processing,
              color: AppColors.purple,
              showErrorColor: state.signInStatus == ProcessStatus.unsuccessful,
              callback: () async {
                /// validate data
                context.cubits.signIn.validate();

                /// show validation result
                if (_formKey.currentState!.validate()) {
                  /// sign in
                  context.cubits.signIn.signInWithEmailAndPassword();
                }
              });
        });
  }

  Widget _signUpButton(BuildContext context) {
    return DefaultButton(
        elevation: 0,
        text: context.loc?.globalSignUp,
        color: AppColors.white.withOpacity(0.15),
        borderColor: AppColors.whiteOp30,
        textColor: AppColors.purple,
        callback: () => Navigator.of(context).pushNamed(AppRoutes.signUp));
  }
}
