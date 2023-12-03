import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:living_room/service/authentication/authentication_service.dart';
import 'package:living_room/service/database/database_service.dart';
import 'package:living_room/service/messaging/messaging_service.dart';
import 'package:living_room/service/storage/storage_service.dart';
import 'package:living_room/state/app/family_selector_bloc.dart';
import 'package:living_room/state/app/navigator_bar_bloc.dart';
import 'package:living_room/state/screen/profile/notification_settings_bloc.dart';
import 'package:living_room/state/screen/profile/password_settings_bloc.dart';
import 'package:living_room/state/sheet/family/edit_family_bloc.dart';
import 'package:living_room/state/sheet/family/goal_details_bloc.dart';
import 'package:living_room/state/sheet/family/task_details_bloc.dart';
import 'package:living_room/state/sheet/temp_bottom_sheet_cubit.dart';
import 'package:living_room/state/sheet/family/unaccepted_invitation_bloc.dart';
import 'package:living_room/state/object/families_bloc.dart';
import 'package:living_room/state/object/family_bloc.dart';
import 'package:living_room/state/sheet/profile/profile_name_bloc.dart';
import 'package:living_room/state/sheet/profile/profile_picture_bloc.dart';
import 'package:living_room/state/object/task_bloc.dart';
import 'package:living_room/state/screen/sign_in/sign_in_cubit.dart';
import 'package:living_room/state/screen/sign_in/sign_in_state.dart';
import 'package:living_room/state/screen/sign_up/sign_up_cubit.dart';
import 'package:living_room/state/screen/sign_up/sign_up_state.dart';
import 'package:living_room/state/screen/verify_email/verify_email_cubit.dart';
import 'package:living_room/state/screen/verify_email/verify_email_state.dart';
import 'package:living_room/state/screen/app_base/app_base_cubit.dart';
import 'package:living_room/state/screen/app_base/app_base_state.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/general/clickable_icon.dart';
import 'package:living_room/widgets/general/no_overscroll_indicator_list_behavior.dart';
import 'package:living_room/widgets/spacers.dart';

extension ContextExtension on BuildContext {
  void hidePreviousShowNewSnackBar(String? message,
      {SnackBarAction? snackBarAction, Duration? duration}) {
    hideCurrentSnackBar().showSnackBar(message ?? '',
        snackBarAction: snackBarAction,
        duration: duration ?? const Duration(seconds: 3));
  }

  void showSnackBar(String message,
      {SnackBarAction? snackBarAction,
      Duration duration = const Duration(seconds: 3)}) {
    var snackBar = SnackBar(
      content: DefaultText(
        message,
        textAlign: TextAlign.center,
        color: AppColors.white,
      ),
      action: snackBarAction,
      elevation: 0,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: Constants.borderRadius),
      backgroundColor: AppColors.purple.withOpacity(0.95),
    );
    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }

  BuildContext hideCurrentSnackBar() {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    return this;
  }

  AppLocalizations? get loc => AppLocalizations.of(this);

  AppServices get services => AppServices(this);

  AppCubits get cubits => AppCubits(this);

  AppStates get states => AppStates(this);

  NavigatorState get navigator => Navigator.of(this);

  void showInfoSheet(String text) {
    showModalBottomSheet(
        context: this,
        useSafeArea: true,
        isScrollControlled: true,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.transparent,
        builder: (context) {
          return BlocProvider(
            create: (_) => TempBottomSheetCubit(seconds: 5),
            child: Builder(builder: (context) {
              return BlocListener<TempBottomSheetCubit, TempBottomSheetState>(
                  listener: (context, state) {
                    if (state.timeLeft <= 0) Navigator.of(this).pop();
                  },
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: Constants.borderRadius,
                        color: AppColors.purple),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 20,
                              left: 20,
                              top: 20,
                              bottom: 20),
                          child: ScrollConfiguration(
                              behavior: NoOverscrollIndicatorBehavior(),
                              child: SingleChildScrollView(
                                  child: Center(
                                child: DefaultText(
                                  text,
                                  color: AppColors.white,
                                  textAlign: TextAlign.center,
                                ),
                              ))),
                        ),
                      ],
                    ),
                  ));
            }),
          );
        });
  }

  void showBottomSheet(
      {Function? onDone,
      List<Widget>? children,
      Color? extraIconColor,
      IconData? extraIcon,
      void Function()? onExtraIconTap}) {
    showModalBottomSheet(
        context: this,
        useSafeArea: true,
        isScrollControlled: true,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (context) {
          if (children == null) {
            return const SizedBox();
          } else {
            return Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: Constants.borderRadius,
                  color: AppColors.white),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        right: 20,
                        left: 20,
                        top: 0,
                        bottom:
                            (MediaQuery.maybeOf(context)?.viewInsets.bottom ??
                                0)),
                    child: ScrollConfiguration(
                        behavior: NoOverscrollIndicatorBehavior(),
                        child: SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                              const VerticalSpacer.of40(),
                              ...children,
                              const VerticalSpacer(100)
                            ]))),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (extraIcon != null)
                        ClickableIcon(
                          onTap: onExtraIconTap,
                          icon: extraIcon,
                          color: extraIconColor ?? AppColors.purple,
                        ),
                      ClickableIcon(
                          onTap: () {
                            Navigator.maybeOf(context)?.pop();
                          },
                          icon: Icons.arrow_drop_down_circle_rounded)
                    ],
                  ),
                ],
              ),
            );
          }
        }).then((value) {
      onDone?.call(value);
    });
  }
}

class AppCubits {
  final BuildContext context;

  AppCubits(this.context);

  AppBaseCubit get base => context.read<AppBaseCubit>();

  SignInCubit get signIn => context.read<SignInCubit>();

  SignUpCubit get signUp => context.read<SignUpCubit>();

  VerifyEmailCubit get verifyEmail => context.read<VerifyEmailCubit>();

  NavigatorBarCubit get navigatorBar => context.read<NavigatorBarCubit>();

  ProfilePictureCubit get profPic => context.read<ProfilePictureCubit>();

  ProfileNameCubit get profName => context.read<ProfileNameCubit>();

  FamiliesCubit get currentUserFamilies => context.read<FamiliesCubit>();

  EditFamilyCubit get editFamily => context.read<EditFamilyCubit>();

  TaskDetailsCubit get editTask => context.read<TaskDetailsCubit>();

  GoalDetailsCubit get editGoal => context.read<GoalDetailsCubit>();

  FamilyCubit get family => context.read<FamilyCubit>();

  FamilyTaskCubit get task => context.read<FamilyTaskCubit>();

  UnacceptedInvitationCubit get unacceptedInvite => context.read<UnacceptedInvitationCubit>();

  FamilySelectorCubit get familySelector => context.read<FamilySelectorCubit>();

  NotificationSettingsCubit get notificationSettings => context.read<NotificationSettingsCubit>();

  PasswordSettingsCubit get passwordSettings => context.read<PasswordSettingsCubit>();
}

class AppStates {
  final BuildContext context;

  AppStates(this.context);

  AppBaseState get base => context.read<AppBaseCubit>().state;

  SignInState get signIn => context.read<SignInCubit>().state;

  SignUpState get signUp => context.read<SignUpCubit>().state;

  VerifyEmailState get verifyEmail => context.read<VerifyEmailCubit>().state;

  NavigatorBarState get navigatorBar => context.read<NavigatorBarCubit>().state;

  ProfilePictureState get profPic => context.read<ProfilePictureCubit>().state;

  ProfileNameState get profName => context.read<ProfileNameCubit>().state;

  FamiliesState get currentUserFamilies => context.read<FamiliesCubit>().state;

  EditFamilyState get createFamily => context.read<EditFamilyCubit>().state;

  TaskDetailsState get editTask => context.read<TaskDetailsState>();

  GoalDetailsState get editGoal => context.read<GoalDetailsCubit>().state;

  FamilyState get family => context.read<FamilyCubit>().state;

  UnacceptedInvitationState get unacceptedInvite => context.read<UnacceptedInvitationCubit>().state;

  FamilySelectorState get familySelector => context.read<FamilySelectorCubit>().state;

  NotificationSettingsState get notificationSettings => context.read<NotificationSettingsCubit>().state;

  PasswordSettingsState get passwordSettings => context.read<PasswordSettingsCubit>().state;

}

class AppServices {
  final BuildContext context;

  AppServices(this.context);

  AuthenticationService get authentication =>
      RepositoryProvider.of<AuthenticationService>(context);

  DatabaseService get database =>
      RepositoryProvider.of<DatabaseService>(context);

  StorageService get storage => RepositoryProvider.of<StorageService>(context);

  MessagingService get messaging => RepositoryProvider.of<MessagingService>(context);
}
