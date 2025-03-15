class CouponModel {
  final int percentage;

  CouponModel({
    required this.percentage,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      percentage: json['percentage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'percentage': percentage,
    };
  }
}
