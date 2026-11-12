import 'package:intl/intl.dart';

DateTime startOfWeek(DateTime date){
  return DateTime(date.year, date.month, date.day - date.weekday + 1);
}

DateTime endOfWeek(DateTime date){
  return DateTime(date.year, date.month, date.day - date.weekday + 7, 23, 59);
}

bool isToday(DateTime date){
  final now = DateTime.now();
  return now.day == date.day && now.month == date.month && now.year == date.year;
}

DateTime addDays(DateTime date, int days){
  return DateTime(date.year, date.month, date.day + days, date.hour, date.minute);
}

final timeFormat = DateFormat.Hm("pl");