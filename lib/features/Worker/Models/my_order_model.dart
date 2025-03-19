class MyOrderModel {
  final int id;
  final String createdAt;
  final String note;
  final String service;
  final int serviceId;
  final double costPerHour;
  final int totalHours;
  final int startAt;
  final double totalPrice;
  final String location;
  final int userId;
  final int status;
  final User user;

  MyOrderModel({
    required this.id,
    required this.createdAt,
    required this.note,
    required this.service,
    required this.serviceId,
    required this.costPerHour,
    required this.totalHours,
    required this.startAt,
    required this.totalPrice,
    required this.location,
    required this.userId,
    required this.status,
    required this.user,
  });

  factory MyOrderModel.fromJson(Map<String, dynamic> json) {
    return MyOrderModel(
      id: json['id'] as int,
      createdAt: json['created_at'] as String,
      note: json['note'] as String,
      service: json['service'] as String,
      serviceId: json['service_id'] as int,
      costPerHour: (json['cost_per_hour'] as num).toDouble(),
      totalHours: json['total_hours'] as int,
      startAt: json['start_at'] as int,
      totalPrice: (json['total_price'] as num).toDouble(),
      location: json['location'] as String,
      userId: json['user_id'] as int,
      status: json['status'] as int,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'note': note,
      'service': service,
      'service_id': serviceId,
      'cost_per_hour': costPerHour,
      'total_hours': totalHours,
      'start_at': startAt,
      'total_price': totalPrice,
      'location': location,
      'user_id': userId,
      'status': status,
      'user': user.toJson(),
    };
  }
}

class User {
  final int id;
  final String fullName;
  final String picture;

  User({
    required this.id,
    required this.fullName,
    required this.picture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      picture: json['picture'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'picture': picture,
    };
  }
}
