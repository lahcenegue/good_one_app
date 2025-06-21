class WithdrawalRequest {
  final double? amount;
  final String? method;
  final String? name;
  final String? transit;
  final String? institution;
  final String? account;
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
      if (transit != null) 'transit': transit!.toString(),
      if (institution != null) 'institution': institution!.toString(),
      if (account != null) 'account': account!.toString(),
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
      amount: _parseDouble(json['amount']),
      method: json['method']?.toString(),
      createdAt: json['created_at']?.toString(),
      requestId: _parseInt(json['id']),
    );
  }

  // Helper methods (add these as static methods in the class)
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class WithdrawStatus {
  final double? amount;
  final String? name;
  final String? transit;
  final String? institution;
  final String? account;
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
      amount: (json['amount'] as num?)?.toDouble(),
      createdAt: json['created_at'],
      status: json['status'],
      name: json['name'].toString(),
      email: json['email'].toString(),
      account: json['account'].toString(),
      institution: json['institution'].toString(),
      transit: json['transit'].toString(),
    );
  }
}
