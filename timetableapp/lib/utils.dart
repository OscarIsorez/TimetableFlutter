DateTime getMonday(DateTime date) {
  int weekday = date.weekday;
  if (weekday == 1) {
    return date;
  } else {
    return date.subtract(Duration(days: weekday - 1));
  }
}

DateTime getStartOfWeek(DateTime date) {
  return getMonday(date);
}

DateTime get startOfThisWeek => getMonday(DateTime.now());
DateTime get endOfWeek => startOfThisWeek.add(const Duration(days: 4));
