class OtpMessageModel {
  final String message;

  OtpMessageModel({
    required this.message,
  });

  factory OtpMessageModel.fromJson(Map<String, dynamic> json) {
    return OtpMessageModel(
      message: json['message'] ?? '',
    );
  }
}
