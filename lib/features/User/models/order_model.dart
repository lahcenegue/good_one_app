class Order {
  final int totalHours;
  final int startAt; // Keeping as string since API returns it as string
  final String location;
  final int serviceId;
  final int? couponId; // Nullable since coupons might not always be applied
  final int? couponPercentage; // Nullable for same reason
  final double price;
  final int status;
  final String? note; // Nullable as it can be empty
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int id;

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
  final String? coupon;

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
        'coupon': coupon,
      };
}
