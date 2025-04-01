class BalanceModel {
  final num? balance;

  const BalanceModel({this.balance});

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      balance: json['balance'],
    );
  }
}
