class Order {
  final int id;
  final int totalHours;
  final int startAt;
  final String? note;
  final int status;
  final int userId;
  final int serviceId;
  final String location;
  final int? couponId;
  final int? couponPercentage;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.totalHours,
    required this.startAt,
    required this.location,
    required this.serviceId,
    this.couponId,
    this.couponPercentage,
    required this.price,
    required this.status,
    this.note,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      totalHours: json['total_hours'] as int,
      startAt: json['start_at'] as int,
      location: json['location'] as String,
      serviceId: json['service_id'] as int,
      couponId: json['coupon_id'] as int?,
      couponPercentage: json['coupon_percentage'] as int?,
      price: (json['price'] as num).toDouble(),
      status: json['status'] as int,
      note: json['note'] as String?,
      userId: json['user_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      id: json['id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_hours': totalHours,
      'start_at': startAt,
      'location': location,
      'service_id': serviceId,
      'coupon_id': couponId,
      'coupon_percentage': couponPercentage,
      'price': price,
      'status': status,
      'note': note,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'id': id,
    };
  }
}

class OrderRequest {
  final int serviceId;
  final String location;
  final int startAt;
  final int totalHours;
  String? coupon;

  OrderRequest({
    required this.serviceId,
    required this.location,
    required this.startAt,
    required this.totalHours,
    this.coupon,
  });

  Map<String, dynamic> toJson() => {
        'service_id': serviceId,
        'location': location,
        'start_at': startAt,
        'total_hours': totalHours,
        if (coupon != null) 'coupon': coupon,
      };
}

class OrderEditRequest {
  int? orderId;
  String? location;
  int? startAt;
  int? totalHours;
  String? note;

  OrderEditRequest({
    this.orderId,
    this.location,
    this.startAt,
    this.totalHours,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      if (orderId != null) 'order_id': orderId,
      if (location != null) 'location': location,
      if (startAt != null) 'start_at': startAt,
      if (totalHours != null) 'total_hours': totalHours,
      if (note != null) 'note': note,
    };
  }
}
