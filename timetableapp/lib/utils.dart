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
