import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_card.dart';
import 'package:living_room/widgets/default/default_container.dart';
import 'package:living_room/widgets/default/default_expansion_tile.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/spacers.dart';

class StatsDateCard extends StatelessWidget {
  final String? title;

  const StatsDateCard({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return DefaultCard(
      child: DefaultExpansionTile(
        title: title,
        titleColor: AppColors.grey2,
        borderLess: true,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  DefaultText(
                    '20',
                    fontSize: 20,
                    color: AppColors.grey2,
                  ),
                  DefaultText(
                    'feladat összesen',
                    fontSize: 12,
                    color: AppColors.grey2,
                  )
                ],
              ),
              HorizontalSpacer.of20(),
              Column(
                children: [
                  DefaultText(
                    '11',
                    fontSize: 20,
                    color: AppColors.grey2,
                  ),
                  DefaultText(
                    'elfogadott teljesítés',
                    fontSize: 12,
                    color: AppColors.grey2,
                  )
                ],
              ),
            ],
          ),
          const VerticalSpacer.of40(),
          _familyTile(context,
              title: 'Vida család', approved: 8, finished: 2, unfinished: 3),
          const VerticalSpacer.of20(),
          _familyTile(context, title: 'Kiss család', approved: 3, finished: 4),
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
                  if(approvedString.isNotEmpty) DefaultText(
                    approvedString,
                    color: AppColors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.start,
                  ),
                  if(finishedString.isNotEmpty) DefaultText(
                    finishedString,
                    color: AppColors.sand,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.left,
                  ),
                  if(unfinishedString.isNotEmpty) DefaultText(
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
