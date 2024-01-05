import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/main.dart';
import 'package:living_room/model/database/families/family_member_task.dart';
import 'package:living_room/model/database/users/invitation.dart';
import 'package:living_room/service/authentication/authentication_service.dart';
import 'package:living_room/service/database/database_service.dart';
import 'package:living_room/util/utils.dart';

class FamilyStat {
  final String name;
  final int approved;
  final int finished;
  final int unfinished;

  FamilyStat(
      {required this.name,
      this.approved = 0,
      this.finished = 0,
      this.unfinished = 0});
}

class WeekStat {
  int all;
  int approved;
  int finished;
  int unfinished;
  final DateTime startDate;
  final DateTime endDate;
  final List<FamilyStat> familyStats = <FamilyStat>[];

  WeekStat({
    required this.startDate,
  })  : endDate = startDate.add(const Duration(days: 7)),
        all = 0,
        approved = 0,
        finished = 0,
        unfinished = 0;

  void addFamily(FamilyStat familyStat) {
    familyStats.add(familyStat);
    all += familyStat.approved + familyStat.unfinished + familyStat.finished;
    finished += familyStat.finished;
    unfinished += familyStat.unfinished;
    approved += familyStat.approved;
  }
}

class MonthStat {
  List<WeekStat> weeks = [];

  MonthStat();

  void addWeek(WeekStat weekStat) {
    weeks.add(weekStat);
  }
}

class StatsCubit extends Cubit<StatsState> {
  final DatabaseService _databaseService;
  final AuthenticationService _authenticationService;
  StreamSubscription? _userStreamSubscription;
  StreamSubscription? _familiesStreamSubscription;

  StatsCubit(
      {required DatabaseService databaseService,
      required AuthenticationService authenticationService})
      : _databaseService = databaseService,
        _authenticationService = authenticationService,
        super(const StatsState()) {
    _init();
  }

  void _init() {
    String userId = _authenticationService.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      _databaseService.streamUserById(userId).listen((event) {
        _update();
      });
    }

    _databaseService.streamFamilies().listen((event) {
      _update();
    });
  }

  _showSave({bool show = true}) {
    emit(state.copyWith(isLoading: show));
  }

  Future<void> _update({String? userId}) async {
    _showSave();

    String user = userId ?? _authenticationService.currentUser?.uid ?? '';

    if (user.isEmpty) {
      _showSave(show: false);
      return;
    }

    List<Invitation> invitations =
        (await _databaseService.getUserInvitations(userId: user)) ?? [];

    if (invitations.isEmpty) {
      _showSave(show: false);
      return;
    }

    /// creating weeks
    MonthStat monthStat = MonthStat();
    DateTime startDate = DateTime.now();

    for (int i = 0; i < 4; i++) {
      startDate = startDate.subtract(const Duration(days: 7));

      monthStat.addWeek(WeekStat(startDate: startDate));
    }

    /// checking users families
    for (Invitation invitation in invitations) {
      if (invitation.accepted == true) {
        /// getting own tasks
        List<FamilyMemberTask>? tasks = await _databaseService
            .getFamilyMemberTasks(familyId: invitation.familyId!, userId: user);

        if (tasks != null) {
          /// tasks arent null

          String familyName =
              (await _databaseService.getFamily(invitation.familyId!))?.name ??
                  '';

          for (WeekStat weekStat in monthStat.weeks) {
            int approved = 0;
            int finished = 0;
            int unfinished = 0;

            for (FamilyMemberTask task in tasks) {
              if (task.createdAt != null) {
                /// created date not null

                log.d('Current task: ${task.id}'
                    '\ntask.createdAt!.isAfter(weekStat.startDate) == '
                    '${task.createdAt!.isAfter(weekStat.startDate)}'
                    '\ntask.createdAt!.isBefore(weekStat.endDate) == '
                    '${task.createdAt!.isBefore(weekStat.endDate)}'
                    '\ncurrent week:'
                    '\n${weekStat.startDate}-${weekStat.endDate}'
                    '\ncreated:'
                    '\n${task.createdAt}');

                if (task.createdAt!.isAfter(weekStat.startDate) &&
                    task.createdAt!.isBefore(weekStat.endDate)) {
                  /// task was created on this week
                  if (task.isFinishApproved == true) {
                    approved++;
                  } else if (task.isFinished == true) {
                    finished++;
                  } else {
                    unfinished++;
                  }
                }
              }
            }

            /// creating family stat for week
            if (approved > 0 || finished > 0 || unfinished > 0) {
              weekStat.addFamily(FamilyStat(
                  name: familyName,
                  approved: approved,
                  finished: finished,
                  unfinished: unfinished));
            }
          }
        }
      }
    }
    emit(state.copyWith(monthStat: monthStat));
  }

  @override
  Future<void> close() async {
    _userStreamSubscription?.cancel();
    _familiesStreamSubscription?.cancel();
    super.close();
  }
}

class StatsState extends Equatable {
  final MonthStat? monthStat;
  final ProcessStatus? saveStatus;
  final bool updateFlag;
  final bool isLoading;

  const StatsState(
      {this.monthStat,
      this.saveStatus,
      this.updateFlag = true,
      this.isLoading = true});

  StatsState copyWith(
      {MonthStat? monthStat, ProcessStatus? saveStatus, bool? isLoading}) {
    return StatsState(
        monthStat: monthStat ?? this.monthStat,
        saveStatus: saveStatus ?? this.saveStatus,
        isLoading: isLoading ?? this.isLoading,
        updateFlag: !updateFlag);
  }

  @override
  List<Object?> get props => [monthStat, saveStatus, updateFlag];
}
