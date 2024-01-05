import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:living_room/extension/dart/context_extension.dart';

extension DateTimeExtension on DateTime {
  bool get isDateInThePast {
    DateTime current = DateTime(year, month, day);
    DateTime now =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return current.compareTo(now) < 0;
  }

  bool get isInThePast {
    return isBefore(DateTime.now());
  }

  bool get isInTheFuture {
    return isAfter(DateTime.now());
  }

  bool get isInTheFutureAtLeastFiveSeconds {
    return isAfter(DateTime.now().add(const Duration(seconds: 5)));
  }

  bool get isDateInTheFuture {
    DateTime current = DateTime(year, month, day);
    DateTime now =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return current.compareTo(now) > 0;
  }

  bool get isDateToday {
    DateTime now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  String get toHHmm {
    return DateFormat('HH:mm').format(this);
  }

  String convertString(BuildContext context) {
    return '$year'
        ', ${monthByName(context)} '
        '$day '
        '(${weekdayByName(context)})'
        ', $toHHmm';
  }

  String get toMMdd {
    String result = '';

    if (month < 10) result += '0';

    result += '$month.';

    if (day < 10) result += '0';

    return result + day.toString();
  }

  String? weekdayByName(BuildContext context) {
    switch (weekday) {
      case 1:
        return context.loc?.globalDaysMonday;
      case 2:
        return context.loc?.globalDaysTuesday;
      case 3:
        return context.loc?.globalDaysWednesday;
      case 4:
        return context.loc?.globalDaysWednesday;
      case 5:
        return context.loc?.globalDaysThursday;
      case 6:
        return context.loc?.globalDaysSaturday;
      case 7:
        return context.loc?.globalDaysSunday;
    }
    return null;
  }

  String? monthByName(BuildContext context) {
    switch (month) {
      case 1:
        return context.loc?.globalMonthsJanuary;
      case 2:
        return context.loc?.globalMonthsFebruary;
      case 3:
        return context.loc?.globalMonthsMarch;
      case 4:
        return context.loc?.globalMonthsApril;
      case 5:
        return context.loc?.globalMonthsMay;
      case 6:
        return context.loc?.globalMonthsJune;
      case 7:
        return context.loc?.globalMonthsJuly;
      case 8:
        return context.loc?.globalMonthsAugust;
      case 9:
        return context.loc?.globalMonthsSeptember;
      case 10:
        return context.loc?.globalMonthsOctober;
      case 11:
        return context.loc?.globalMonthsNovember;
      case 12:
        return context.loc?.globalMonthsDecember;
    }
    return null;
  }
}
