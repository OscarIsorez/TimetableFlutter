import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:timetableapp/components/enum_provider_state.dart';

DateTime getMonday(DateTime date) {
  int weekday = date.weekday;
  DateTime monday =
      (weekday == 1) ? date : date.subtract(Duration(days: weekday - 1));
  return DateTime(monday.year, monday.month, monday.day);
}

DateTime getStartOfWeek(DateTime date) {
  return getMonday(date);
}

DateTime get startOfThisWeek => getMonday(DateTime.now());
DateTime get endOfWeek => startOfThisWeek.add(const Duration(days: 4));

String formatTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

String getStringFromState(EnumProviderState state) {
  switch (state) {
    case EnumProviderState.errorNetwork:
      return 'Network Error';
    case EnumProviderState.errorUnknown:
      return 'Unknown Error';
    case EnumProviderState.errorNoData:
      return 'No Data';
    case EnumProviderState.error403:
      return 'Forbidden';
    case EnumProviderState.error404:
      return 'Error, verify your URL';
    case EnumProviderState.error500:
      return 'Server Error, try again later';
    case EnumProviderState.errorBackup:
      return 'Error loading backup';
    case EnumProviderState.error:
      return 'Error';
    case EnumProviderState.empty:
      return 'Empty timetable, no data';
    case EnumProviderState.loading:
      return 'Loading';
    case EnumProviderState.loaded:
      return 'Loaded';
    default:
      return 'Unknown Error';
  }
}

Color getColorFromState(EnumProviderState state) {
  switch (state) {
    case EnumProviderState.errorNetwork:
      return Colors.red;
    case EnumProviderState.errorUnknown:
      return Colors.red;
    case EnumProviderState.errorNoData:
      return Colors.red;
    case EnumProviderState.error403:
      return Colors.red;
    case EnumProviderState.error404:
      return Colors.red;
    case EnumProviderState.error500:
      return Colors.red;
    case EnumProviderState.errorBackup:
      return Colors.red;
    case EnumProviderState.error:
      return Colors.red;
    case EnumProviderState.empty:
      return Colors.red;
    case EnumProviderState.loading:
      return Colors.blue;
    case EnumProviderState.loaded:
      return Colors.green;
    default:
      return Colors.red;
  }
}
