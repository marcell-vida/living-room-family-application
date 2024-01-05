import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/screen/base/app_base_screen.dart';
import 'package:living_room/state/app/navigator_bar_bloc.dart';
import 'package:living_room/state/object/families_bloc.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/tab_families/base/families_tab.dart';
import 'package:living_room/widgets/tab_family/base/family_tab.dart';
import 'package:living_room/widgets/tab_profile/base/profile_tab.dart';
import 'package:living_room/widgets/tab_stats/base/tab_stats.dart';

const List<Widget> _tabs = <Widget>[
  FamilyTab(),
  StatsTab(),
  FamiliesTab(),
  ProfileTab()
];

class LivingRoomMainScreen extends AppBaseScreen {
  const LivingRoomMainScreen({super.key});

  void _handleNavigatorTap(BuildContext context, int index) {
    context.cubits.navigatorBar.changeIndex(index);
  }

  @nonVirtual
  @override
  Widget body(BuildContext context) {
    return BlocProvider<FamiliesCubit>(
      create: (context) => FamiliesCubit(
          databaseService: context.services.database,
          authenticationService: context.services.authentication),
      child: BlocBuilder<NavigatorBarCubit, NavigatorBarState>(
          buildWhen: (previous, current) =>
              previous.selectedIndex != current.selectedIndex,
          builder: (context, state) {
            return Scaffold(
                extendBody: true,
                bottomNavigationBar: DotNavigationBar(
                  backgroundColor: AppColors.purple.withOpacity(0.9),
                  currentIndex: state.selectedIndex,
                  onTap: (int index) => _handleNavigatorTap(context, index),
                  items: [
                    /// Tasks
                    DotNavigationBarItem(
                        icon: const Icon(Icons.home),
                        selectedColor: AppColors.white,
                        unselectedColor: AppColors.white.withOpacity(0.7)),

                    /// Stats
                    DotNavigationBarItem(
                        icon: const Icon(Icons.bar_chart),
                        selectedColor: AppColors.white,
                        unselectedColor: AppColors.white.withOpacity(0.7)),

                    /// Families
                    DotNavigationBarItem(
                        icon: const Icon(Icons.family_restroom_outlined),
                        selectedColor: AppColors.white,
                        unselectedColor: AppColors.white.withOpacity(0.7)),

                    /// Profile
                    DotNavigationBarItem(
                        icon: const Icon(Icons.settings),
                        selectedColor: AppColors.white,
                        unselectedColor: AppColors.white.withOpacity(0.7)),
                  ],
                ),
                body: Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [AppColors.purple, AppColors.sand],
                  )),
                  child: Container(
                    alignment: Alignment.center,
                    color: AppColors.white.withOpacity(0.7),
                    child: SafeArea(
                        minimum: AppPaddings.screenAllAround,
                        bottom: false,
                        child: _tabs.elementAt(state.selectedIndex)),
                  ),
                ));
          }),
    );
  }
}
