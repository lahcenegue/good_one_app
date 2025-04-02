class WithdrawalRequest {
  final double? amount;
  final String? method;
  final String? name;
  final int? transit;
  final int? institution;
  final int? account;
  final String? email;

  WithdrawalRequest({
    this.amount,
    this.method,
    this.name,
    this.transit,
    this.institution,
    this.account,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      if (amount != null) 'amount': amount!,
      if (method != null) 'method': method!.toString(),
      if (name != null) 'name': name!.toString(),
      if (transit != null) 'transit': transit!,
      if (institution != null) 'institution': institution!,
      if (account != null) 'account': account!,
      if (email != null) 'email': email!.toString(),
    };
  }
}

class WithdrawalModel {
  final double? amount;
  final String? method;
  final String? createdAt;
  final int? requestId;

  WithdrawalModel({
    this.amount,
    this.method,
    this.createdAt,
    this.requestId,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      amount: json['amount'] as double,
      method: json['method'] as String,
      createdAt: json['created_at'] as String,
      requestId: json['id'] as int,
    );
  }
}

class WithdrawStatus {
  final double? amount;
  final String? name;
  final int? transit;
  final int? institution;
  final int? account;
  final String? email;
  final String? createdAt;
  final int? status;

  WithdrawStatus({
    this.amount,
    this.name,
    this.transit,
    this.institution,
    this.account,
    this.email,
    this.createdAt,
    this.status,
  });

  factory WithdrawStatus.fromJson(Map<String, dynamic> json) {
    return WithdrawStatus(
      amount: double.tryParse(json['amount'].toString()),
      createdAt: json['created_at'],
      status: json['status'],
      name: json['name'],
      email: json['email'],
      account: json['account'],
      institution: json['institution'],
      transit: json['transit'],
    );
  }
}
