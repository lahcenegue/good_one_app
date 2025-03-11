class RateServiceResponse {
  final int id;
  final int rate;
  final String message;
  final int serviceId;
  final DateTime createdAt;
  final DateTime updatedAt;

  RateServiceResponse({
    required this.id,
    required this.rate,
    required this.message,
    required this.serviceId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RateServiceResponse.fromJson(Map<String, dynamic> json) {
    return RateServiceResponse(
      id: json['id'] as int,
      rate: json['rate'] as int,
      message: json['message'] as String,
      serviceId: json['service_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class RateServiceRequest {
  final int serviceId;
  final int rate;
  final String message;

  RateServiceRequest({
    required this.serviceId,
    required this.rate,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
        'service_id': serviceId.toString(),
        'rate': rate.toString(),
        'message': message,
      };
}
