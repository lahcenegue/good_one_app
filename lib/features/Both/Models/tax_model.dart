/// Represents tax information for a specific region, parsed from the API response.
class TaxModel {
  final double regionTaxes; // Percentage (e.g., 14.975%)
  final double platformFeesPercentage; // Percentage (e.g., 20%)
  final double platformFees; // Fixed fee (e.g., $5)

  TaxModel({
    required this.regionTaxes,
    required this.platformFeesPercentage,
    required this.platformFees,
  });

  /// Parses a JSON object into a TaxModel instance.
  factory TaxModel.fromJson(Map<String, dynamic> json) {
    return TaxModel(
      regionTaxes: double.parse(json['region_taxes'].toString()),
      platformFeesPercentage:
          double.parse(json['platform_fees_percentage'].toString()),
      platformFees: double.parse(json['platform_fees'].toString()),
    );
  }

  /// Converts the model to a JSON object (for potential future use).
  Map<String, dynamic> toJson() => {
        'region_taxes': regionTaxes,
        'platform_fees_percentage': platformFeesPercentage,
        'platform_fees': platformFees,
      };
}
