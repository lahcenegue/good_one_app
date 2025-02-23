import 'package:intl/intl.dart';

class Booking {
  final int id;
  final int totalHours;
  final int startAt; // Unix timestamp in seconds
  final String note;
  final int status; // 1 = Completed, 2 = In Progress, 3 = Canceled
  final int userId;
  final int serviceId;
  final String location;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.totalHours,
    required this.startAt,
    required this.note,
    required this.status,
    required this.userId,
    required this.serviceId,
    required this.location,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      totalHours: json['total_hours'] as int,
      startAt: json['start_at'] as int,
      note: json['note'] as String,
      status: json['status'] as int,
      userId: json['user_id'] as int,
      serviceId: json['service_id'] as int,
      location: json['location'] as String,
      price: (json['price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  String getStatusText() {
    // Define status strings as constants or methods, localized in UI
    switch (status) {
      case 1:
        return 'completed'; // Will be localized in UI
      case 2:
        return 'inProgress'; // Will be localized in UI
      case 3:
        return 'canceled'; // Will be localized in UI
      default:
        return 'unknownStatus'; // Will be localized in UI
    }
  }

  String get formattedStartDate {
    final date = DateTime.fromMillisecondsSinceEpoch(startAt * 1000);
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String get formattedStartTime {
    final date = DateTime.fromMillisecondsSinceEpoch(startAt * 1000);
    return DateFormat('HH:mm').format(date);
  }
}
