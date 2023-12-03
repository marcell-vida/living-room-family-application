import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/screen/base/content_in_card_base_screen.dart';
import 'package:living_room/state/screen/app_base/app_base_cubit.dart';
import 'package:living_room/state/screen/app_base/app_base_state.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_button.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/general/circle_shape.dart';
import 'package:living_room/widgets/spacers.dart';

class NoConnectionScreen extends ContentInCardBaseScreen {
  const NoConnectionScreen({Key? key}) : super(key: key);

  @override
  Widget onBuild(BuildContext context) {
    return BlocListener<AppBaseCubit, AppBaseState>(
      listenWhen: (previous, current) =>
          previous.networkConnectionStatus != current.networkConnectionStatus,
      listener: (context, state) {
        if (state.networkConnectionStatus ==
            NetworkConnectionStatus.connected) {
          Navigator.of(context).pop();
        }
      },
      child: BlocBuilder<AppBaseCubit, AppBaseState>(
          buildWhen: (previous, current) =>
              previous.networkConnectionStatus !=
              current.networkConnectionStatus,
          builder: (context, state) {
            bool connectedNoInternet = state.networkConnectionStatus ==
                NetworkConnectionStatus.connectedNoInternet;
            return WillPopScope(
                onWillPop: () async {
                  return state.networkConnectionStatus ==
                      NetworkConnectionStatus.connected;
                },
                child: Column(
                  children: [
                    DefaultText(
                      context.loc?.noConnectionScreenNoConnection ?? '',
                      color: AppColors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                    const VerticalSpacer.of40(),
                    CircleShape(
                      backgroundColor: Colors.transparent,
                      borderColor: AppColors.purple,
                      borderWidth: Constants.borderWidth + 2,
                      padding: 25,
                      child: Icon(
                        connectedNoInternet
                            ? Icons.public_off_outlined
                            : Icons
                                .signal_wifi_connected_no_internet_4_outlined,
                        size: 65,
                        color: AppColors.purple,
                      ),
                    ),
                    const VerticalSpacer.of23(),
                    DefaultText(
                      connectedNoInternet
                          ? context.loc?.noConnectionScreenInternetError ?? ''
                          : context.loc?.noConnectionScreenConnectionError ??
                              '',
                      textAlign: TextAlign.center,
                      color: AppColors.white,
                    ),
                    const VerticalSpacer.of23(),
                    BlocBuilder<AppBaseCubit, AppBaseState>(
                        buildWhen: (previous, current) =>
                            previous.connectionFetchStatus !=
                            current.connectionFetchStatus,
                        builder: (context, state) {
                          return DefaultButton(
                              color: AppColors.purple,
                              text: context.loc?.globalRefresh,
                              isLoading: state.connectionFetchStatus ==
                                  ConnectionFetchStatus.processing,
                              callback: () {
                                context.cubits.base.fetchNetworkStatuses();
                              });
                        })
                  ],
                ));
          }),
    );
  }
}
