import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_card.dart';
import 'package:living_room/widgets/default/default_container.dart';
import 'package:living_room/widgets/default/default_expansion_tile.dart';
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
  final betweenSpace = 0.1;

  BarChartGroupData generateGroupData(
      int x, double approved, double finished, double unfinished) {
    return BarChartGroupData(
      x: x,
      groupVertically: true,
      showingTooltipIndicators: [2],
      barRods: [
        BarChartRodData(
            fromY: 0,
            toY: approved,
            color: approvedTasksColor,
            width: 20,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5))),
        BarChartRodData(
            fromY: approved + betweenSpace,
            toY: approved + finished,
            color: finishedTasksColor,
            width: 20,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5))),
        BarChartRodData(
            fromY: approved + finished + 2 * betweenSpace,
            toY: approved + finished + 2 * betweenSpace + unfinished,
            color: unfinishedTasksColor,
            width: 20,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5))),
      ],
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 0:
        text = '44.hét';
        break;
      case 1:
        text = '45. hét';
        break;
      case 2:
        text = '46. hét';
        break;
      case 3:
        text = '47. hét';
        break;
      default:
        text = '';
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
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
                  _chart(),
                  const VerticalSpacer.of20(),
                  _legend(context),
                  const VerticalSpacer.of40(),
                  DefaultText(
                    'A kimutatások a jelenlegi és az elmúlt három hét teljesítései alapján készülnek.',
                    color: AppColors.grey2,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
          StatsDateCard(title: '47. hét (11.20 - 11.26)'),
          StatsDateCard(title: '46. hét (11.13 - 11.19)'),
          StatsDateCard(title: '45. hét (11.06 - 11.12)'),
          StatsDateCard(title: '44. hét (10.30 - 11.05)'),
        ],
      ),
    );
  }

  Widget _chart(){
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
                getTitlesWidget: bottomTitles,
                reservedSize: 20,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: [
            generateGroupData(0, 12, 5, 1),
            generateGroupData(1, 16, 1, 1),
            generateGroupData(2, 9, 4, 3),
            generateGroupData(3, 11, 6, 3),
          ],
          maxY: 24 + (betweenSpace),
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
