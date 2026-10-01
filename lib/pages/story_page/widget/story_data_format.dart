import 'package:intl/intl.dart';

class StoryDataFormat {
  static String onFormat(String value) {
    final dateTime = DateTime.parse(value).toLocal();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24 && dateTime.day == now.day && dateTime.month == now.month && dateTime.year == now.year) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 48 && dateTime.day == now.subtract(Duration(days: 1)).day && dateTime.month == now.month && dateTime.year == now.year) {
      String timePart = DateFormat('hh:mm a').format(dateTime);
      return 'Yesterday, $timePart';
    } else {
      return DateFormat('dd/MM/yyyy, hh:mm a').format(dateTime);
    }
  }
}
