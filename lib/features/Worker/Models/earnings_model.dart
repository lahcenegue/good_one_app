class EarningsHistoryModel {
  final String id;
  final String orderId;
  final String serviceName;
  final double grossAmount;
  final double platformFeeAmount;
  final double taxAmount;
  final double couponDiscount;
  final double netEarnings;
  final String pricingType;
  final double durationValue;
  final String region;
  final String status;
  final DateTime earnedAt;
  final DateTime createdAt;

  EarningsHistoryModel({
    required this.id,
    required this.orderId,
    required this.serviceName,
    required this.grossAmount,
    required this.platformFeeAmount,
    required this.taxAmount,
    required this.couponDiscount,
    required this.netEarnings,
    required this.pricingType,
    required this.durationValue,
    required this.region,
    required this.status,
    required this.earnedAt,
    required this.createdAt,
  });

  factory EarningsHistoryModel.fromJson(Map<String, dynamic> json) {
    return EarningsHistoryModel(
      id: json['id'].toString(),
      orderId: json['order_id'].toString(),
      serviceName: json['service_name'] ?? 'Unknown Service',
      grossAmount: (json['gross_amount'] as num).toDouble(),
      platformFeeAmount: (json['platform_fee_amount'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      couponDiscount: (json['coupon_discount'] as num).toDouble(),
      netEarnings: (json['net_earnings'] as num).toDouble(),
      pricingType: json['pricing_type'] ?? 'hourly',
      durationValue: (json['duration_value'] as num).toDouble(),
      region: json['region'] ?? 'unknown',
      status: json['status'] ?? 'pending',
      earnedAt: DateTime.parse(json['earned_at']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class EarningsSummaryModel {
  final double totalEarnings;
  final double pendingEarnings;
  final double availableBalance;
  final double totalWithdrawn;
  final double monthlyEarnings;
  final double totalPlatformFees;
  final double totalTaxes;

  EarningsSummaryModel({
    required this.totalEarnings,
    required this.pendingEarnings,
    required this.availableBalance,
    required this.totalWithdrawn,
    required this.monthlyEarnings,
    required this.totalPlatformFees,
    required this.totalTaxes,
  });

  factory EarningsSummaryModel.fromJson(Map<String, dynamic> json) {
    // Handle the case where the response might be null or have different structure
    Map<String, dynamic> data;

    if (json.containsKey('data') && json['data'] != null) {
      data = json['data'] as Map<String, dynamic>;
    } else {
      // Fallback: assume the json itself contains the data
      data = json;
    }

    return EarningsSummaryModel(
      totalEarnings: _parseDouble(data['total_earnings']) ?? 0.0,
      pendingEarnings: _parseDouble(data['pending_earnings']) ?? 0.0,
      availableBalance: _parseDouble(data['available_balance']) ?? 0.0,
      totalWithdrawn: _parseDouble(data['total_withdrawn']) ?? 0.0,
      monthlyEarnings: _parseDouble(data['monthly_earnings']) ?? 0.0,
      totalPlatformFees: _parseDouble(data['total_platform_fees']) ?? 0.0,
      totalTaxes: _parseDouble(data['total_taxes']) ?? 0.0,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
