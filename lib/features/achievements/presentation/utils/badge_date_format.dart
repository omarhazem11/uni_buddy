const _shortMonthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Dec 15"
String shortDateLabel(DateTime date) => '${_shortMonthNames[date.month - 1]} ${date.day}';
