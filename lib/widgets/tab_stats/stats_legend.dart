import 'package:flutter/material.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/widgets/default/default_text.dart';
import 'package:living_room/widgets/spacers.dart';

class StatsLegend extends StatelessWidget {
  const StatsLegend({
    super.key,
    required this.name,
    required this.color,
  });
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: color,
          ),
        ),
        const HorizontalSpacer(6),
        DefaultText(
          name,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.customBlack2,
        ),
      ],
    );
  }
}

class LegendsListWidget extends StatelessWidget {
  const LegendsListWidget({
    super.key,
    required this.legends,
  });
  final List<Legend> legends;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: legends
          .map(
            (e) => StatsLegend(
          name: e.name,
          color: e.color,
        ),
      )
          .toList(),
    );
  }
}

class Legend {
  Legend(this.name, this.color);
  final String name;
  final Color color;
}