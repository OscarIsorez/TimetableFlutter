DateTime getMonday(DateTime date) {
  int weekday = date.weekday;
  if (weekday == 1) {
    return date;
  } else {
    return date.subtract(Duration(days: weekday - 1));
  }
}


