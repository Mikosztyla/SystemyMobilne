abstract final class LaundryFormat {
  static const _weekdays = ['pon.', 'wt.', 'śr.', 'czw.', 'pt.', 'sob.', 'niedz.'];
  static const _monthsShort = [
    'sty.', 'lut.', 'mar.', 'kwi.', 'maj', 'cze.',
    'lip.', 'sie.', 'wrz.', 'paź.', 'lis.', 'gru.',
  ];
  static const _months = [
    'styczeń', 'luty', 'marzec', 'kwiecień', 'maj', 'czerwiec',
    'lipiec', 'sierpień', 'wrzesień', 'październik', 'listopad', 'grudzień',
  ];

  static String time(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}';

  static String money(int grosze) => '${grosze ~/ 100},${_two(grosze % 100)} zł';

  static String duration(int minutes) => '${minutes ~/ 60}:${_two(minutes % 60)} h';

  static String shortDate(DateTime t) =>
      '${_weekdays[t.weekday - 1]}, ${t.day} ${_monthsShort[t.month - 1]}';

  static String monthYear(DateTime t) => '${_months[t.month - 1]} ${t.year}';

  static String month(DateTime t) => _months[t.month - 1];

  static String remaining(Duration d) {
    final minutes = (d.inSeconds / 60).ceil();
    if (minutes < 60) return '$minutes min';
    final rest = minutes % 60;
    return rest == 0 ? '${minutes ~/ 60} h' : '${minutes ~/ 60} h $rest min';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
