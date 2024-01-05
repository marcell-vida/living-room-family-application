import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:living_room/extension/dart/datetime_extension.dart';
import 'package:living_room/state/screen/stats/stats_bloc.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_card.dart';
import 'package:living_room/widgets/default/default_container.dart';
import 'package:living_room/widgets/default/default_expansion_tile.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/spacers.dart';

class StatsDateCard extends StatelessWidget {
  final String? title;
  final WeekStat weekStat;

  const StatsDateCard({super.key, this.title, required this.weekStat});

  @override
  Widget build(BuildContext context) {
    String dateTitle = '${weekStat.startDate.toMMdd} - '
        '${weekStat.endDate.toMMdd}';

    return DefaultCard(
      child: DefaultExpansionTile(
        title: dateTitle,
        titleColor: AppColors.grey2,
        borderLess: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  DefaultText(
                    '${weekStat.all}',
                    fontSize: 20,
                    color: AppColors.grey2,
                  ),
                  const DefaultText(
                    'feladat összesen',
                    fontSize: 12,
                    color: AppColors.grey2,
                  )
                ],
              ),
              const HorizontalSpacer.of20(),
              Column(
                children: [
                  DefaultText(
                    '${weekStat.approved}',
                    fontSize: 20,
                    color: AppColors.grey2,
                  ),
                  const DefaultText(
                    'elfogadott teljesítés',
                    fontSize: 12,
                    color: AppColors.grey2,
                  )
                ],
              ),
            ],
          ),
          const VerticalSpacer.of40(),
          for (FamilyStat familyStat in weekStat.familyStats) ...[
            _familyTile(context,
                title: familyStat.name,
                approved: familyStat.approved.toDouble(),
                finished: familyStat.finished.toDouble(),
                unfinished: familyStat.unfinished.toDouble()),
            const VerticalSpacer.of20(),
          ]
        ],
      ),
    );
  }

  Widget _familyTile(BuildContext context,
      {String title = '',
      double? approved,
      double? finished,
      double? unfinished}) {
    String approvedString = approved != null && approved > 0
        ? '${approved.toInt().toString()} elfogadott'
        : '';
    String finishedString = finished != null && finished > 0
        ? '${finished.toInt().toString()} teljesített'
        : '';
    String unfinishedString = unfinished != null && unfinished > 0
        ? '${unfinished.toInt().toString()} befejezetlen'
        : '';

    return DefaultContainer(
      borderColor: AppColors.grey2,
      children: [
        const VerticalSpacer.of10(),
        Center(
          child: DefaultText(
            title,
            fontSize: 18,
            color: AppColors.grey2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const VerticalSpacer.of20(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (approvedString.isNotEmpty)
                    DefaultText(
                      approvedString,
                      color: AppColors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.start,
                    ),
                  if (finishedString.isNotEmpty)
                    DefaultText(
                      finishedString,
                      color: AppColors.sand,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.left,
                    ),
                  if (unfinishedString.isNotEmpty)
                    DefaultText(
                      unfinishedString,
                      color: AppColors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                ],
              ),
              _pieChart(
                  approved: approved,
                  finished: finished,
                  unfinished: unfinished)
            ],
          ),
        )
      ],
    );
  }

  Widget _pieChart({double? approved, double? finished, double? unfinished}) {
    return SizedBox(
      width: 120,
      height: 120,
      child: PieChart(
        PieChartData(
          borderData: FlBorderData(
            show: true,
          ),
          sectionsSpace: 2,
          centerSpaceRadius: 0,
          sections: [
            if (approved != null && approved > 0)
              _defaultPieSection(approved, AppColors.blue),
            if (finished != null && finished > 0)
              _defaultPieSection(finished, AppColors.sand),
            if (unfinished != null && unfinished > 0)
              _defaultPieSection(unfinished, AppColors.red)
          ],
        ),
      ),
    );
  }

  PieChartSectionData _defaultPieSection(double value, Color color) {
    TextStyle textStyle = GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.white,
    );
    double radius = 55;

    return PieChartSectionData(
      color: color,
      value: value,
      title: value.toInt().toString(),
      radius: radius,
      titlePositionPercentageOffset: 0.7,
      titleStyle: textStyle,
    );
  }
}
