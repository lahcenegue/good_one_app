import 'package:intl/intl.dart';

class ChatUtils {
  static String formatMessageTime(String? timestamp) {
    if (timestamp == null) return '';

    try {
      final DateTime messageTime = DateTime.parse(timestamp);
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime yesterday = today.subtract(const Duration(days: 1));
      final DateTime messageDate = DateTime(
        messageTime.year,
        messageTime.month,
        messageTime.day,
      );

      if (messageDate == today) {
        // Today: show only time
        return DateFormat('HH:mm').format(messageTime);
      } else if (messageDate == yesterday) {
        // Yesterday
        return 'Yesterday';
      } else if (messageDate.year == now.year) {
        // This year: show day and month
        return DateFormat('dd/MM').format(messageTime);
      } else {
        // Different year: show day/month/year
        return DateFormat('dd/MM/yy').format(messageTime);
      }
    } catch (e) {
      return '';
    }
  }
}
