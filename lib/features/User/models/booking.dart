import 'package:intl/intl.dart';

class Booking {
  final int id;
  final int totalHours;
  final int startAt;
  final double price;
  final String location;
  final int serviceId;
  final int status;
  final String note;
  // final int userId;
  //final DateTime createdAt;
  //final DateTime updatedAt;
  final Service service;

  Booking({
    required this.id,
    required this.totalHours,
    required this.startAt,
    required this.note,
    required this.status,
    // required this.userId,
    required this.serviceId,
    required this.location,
    required this.price,
    //  required this.createdAt,
    //  required this.updatedAt,
    required this.service,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int? ?? 0,
      totalHours: json['total_hours'] as int? ?? 0,
      startAt: json['start_at'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] as String? ?? '',
      serviceId: json['service_id'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
      note: json['note'] as String? ?? '',
      //userId: json['user_id'] as int? ?? 0,
      // createdAt: DateTime.parse(
      //     json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      // updatedAt: DateTime.parse(
      //     json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
      service: Service.fromJson(json['service'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'total_hours': totalHours,
        'start_at': startAt,
        'note': note,
        'status': status,
        //'user_id': userId,
        'service_id': serviceId,
        'location': location,
        'price': price,
        // 'created_at': createdAt.toIso8601String(),
        // 'updated_at': updatedAt.toIso8601String(),
        'service': service.toJson(),
      };

  String getStatusText() {
    switch (status) {
      case 1:
        return 'inProgress';
      case 2:
        return 'completed';
      case 3:
        return 'canceled';
      default:
        return 'unknownStatus';
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

class Service {
  final int id;
  final String fullName;
  final String picture;
  final String service;
  final int subcategoryId;
  final double costPerHour;
  final Subcategory subcategory;

  Service({
    required this.id,
    required this.fullName,
    required this.picture,
    required this.service,
    required this.subcategoryId,
    required this.costPerHour,
    required this.subcategory,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      picture: json['picture'] as String,
      service: json['service'] as String,
      subcategoryId: json['subcategory_id'] as int,
      costPerHour: (json['cost_per_hour'] as num).toDouble(),
      subcategory:
          Subcategory.fromJson(json['subcategory'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'picture': picture,
        'service': service,
        'subcategory_id': subcategoryId,
        'cost_per_hour': costPerHour,
        'subcategory': subcategory.toJson(),
      };
}

class Subcategory {
  final int id;
  final String name;

  Subcategory({
    required this.id,
    required this.name,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
