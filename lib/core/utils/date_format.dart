const List<String> _months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _two(int value) => value.toString().padLeft(2, '0');

String formatDateTime(DateTime date) {
  final DateTime local = date.toLocal();
  return '${local.day} ${_months[local.month - 1]}, ${_two(local.hour)}:${_two(local.minute)}';
}

String formatTime(DateTime date) {
  final DateTime local = date.toLocal();
  final int hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final String suffix = local.hour < 12 ? 'AM' : 'PM';
  return '$hour12:${_two(local.minute)} $suffix';
}