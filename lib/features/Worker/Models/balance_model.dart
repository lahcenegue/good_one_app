class BalanceModel {
  final num? balance;
  final num? totalEarnings;
  final num? withdrawn;

  const BalanceModel({
    this.balance,
    this.totalEarnings,
    this.withdrawn,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      balance: json['balance'],
      totalEarnings: json['total_earnings'],
      withdrawn: json['withdrawn'],
    );
  }
}
