import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/extension/dart/datetime_extension.dart';
import 'package:living_room/state/screen/stats/stats_bloc.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_card.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/general/no_overscroll_indicator_list_behavior.dart';
import 'package:living_room/widgets/spacers.dart';
import 'package:living_room/widgets/tab_stats/stats_date_card.dart';
import 'package:living_room/widgets/tab_stats/stats_legend.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  final approvedTasksColor = AppColors.blue;
  final finishedTasksColor = AppColors.sand;
  final unfinishedTasksColor = AppColors.red;
  final spaceBetweenRods = 0.1;

  BarChartGroupData _group(
      int x, double approved, double finished, double unfinished) {
    List<BarChartRodData>? barRods = [
      if (approved > 0)
        _defaultRodData(to: approved, color: approvedTasksColor),
      if (finished > 0)
        _defaultRodData(
            from: approved + spaceBetweenRods,
            to: approved + finished,
            color: finishedTasksColor),
      if (unfinished > 0)
        _defaultRodData(
            from: approved + finished + spaceBetweenRods,
            to: approved + finished + unfinished,
            color: unfinishedTasksColor),
    ];

    return BarChartGroupData(
      x: x,
      groupVertically: true,
      showingTooltipIndicators: [barRods.length - 1],
      barRods: barRods,
    );
  }

  BarChartRodData _defaultRodData(
      {double from = 0, required double to, Color color = AppColors.blue}) {
    return BarChartRodData(
        fromY: from,
        toY: to,
        color: color,
        width: 20,
        borderRadius: const BorderRadius.all(Radius.circular(5)));
  }

  BarTouchData get barTouchData {
    return BarTouchData(
      enabled: false,
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Colors.transparent,
        tooltipPadding: EdgeInsets.zero,
        tooltipMargin: 8,
        getTooltipItem: (
          BarChartGroupData group,
          int groupIndex,
          BarChartRodData rod,
          int rodIndex,
        ) {
          return BarTooltipItem(
            rod.toY.round().toString(),
            const TextStyle(
              color: AppColors.customBlack2,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StatsCubit>(
      create: (_) => StatsCubit(
          databaseService: context.services.database,
          authenticationService: context.services.authentication),
      child: Builder(builder: (context) {
        return BlocBuilder<StatsCubit, StatsState>(builder: (context, state) {
          return ScrollConfiguration(
            behavior: NoOverscrollIndicatorBehavior(),
            child: ListView(
              children: [
                const VerticalSpacer.of10(),
                DefaultCard(
                  color: AppColors.white,
                  title: 'Kimutatások',
                  iconData: Icons.stacked_bar_chart,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _chart(context.cubits.stats),
                        const VerticalSpacer.of20(),
                        _legend(context),
                        const VerticalSpacer.of40(),
                        const DefaultText(
                          'A kimutatások a jelenlegi és az elmúlt három hét teljesítései alapján készülnek.',
                          color: AppColors.grey2,
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
                if (context.cubits.stats.state.monthStat?.weeks.isNotEmpty ??
                    false)
                  for (WeekStat weekStat
                      in context.cubits.stats.state.monthStat!.weeks)
                    StatsDateCard(
                      weekStat: weekStat,
                    )
              ],
            ),
          );
        });
      }),
    );
  }

  Widget _chart(StatsCubit statsCubit) {
    if (statsCubit.state.monthStat == null) {
      return const DefaultText('Nincsenek adatok.');
    }

    List<WeekStat> weekStats = statsCubit.state.monthStat?.weeks ?? [];

    int maxY = 0;
    for (WeekStat current in weekStats) {
      if (current.all > maxY) maxY = current.all;
    }

    return AspectRatio(
      aspectRatio: 1,
      child: BarChart(
        BarChartData(
          barTouchData: barTouchData,
          alignment: BarChartAlignment.spaceBetween,
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double index, TitleMeta meta) {
                  const style = TextStyle(fontSize: 10);

                  int i = index.toInt();
                  String dateTitle = '${weekStats[i].startDate.toMMdd} - '
                      '${weekStats[i].endDate.toMMdd}';

                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(dateTitle, style: style),
                  );
                },
                reservedSize: 20,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: [
            for (int i = weekStats.length - 1; i >= 0; i--)
              if (weekStats[i].all != 0)
                _group(
                    i,
                    weekStats[i].approved.toDouble(),
                    weekStats[i].finished.toDouble(),
                    weekStats[i].unfinished.toDouble())
          ],
          maxY: maxY + 2,
        ),
      ),
    );
  }

  Widget _legend(BuildContext context) {
    return LegendsListWidget(
      legends: [
        Legend('Befejezetlen feladatok', unfinishedTasksColor),
        Legend('Teljesített feladatok', finishedTasksColor),
        Legend('Elfogadott teljesítések', approvedTasksColor),
      ],
    );
  }
}
