import 'package:intl/intl.dart';

import '../core/json_utils.dart';

String fixtureLabel(DateTime kickoff) {
  final today = dateOnly(DateTime.now());
  final day = dateOnly(kickoff);
  final time = DateFormat('h:mm a').format(kickoff);
  final diff = day.difference(today).inDays;
  if (diff == 0) return 'Today • $time';
  if (diff == 1) return 'Tomorrow • $time';
  return '${DateFormat('EEE, d MMM').format(kickoff)} • $time';
}

String dayHeader(DateTime day) {
  final today = dateOnly(DateTime.now());
  final diff = dateOnly(day).difference(today).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  if (diff == -1) return 'Yesterday';
  return DateFormat('EEEE, d MMM').format(day);
}

String shortDate(DateTime d) => DateFormat('d MMM • h:mm a').format(d);
