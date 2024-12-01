enum AccountType { customer, worker }

extension AccountTypeExtension on AccountType {
  String toJson() {
    switch (this) {
      case AccountType.customer:
        return 'customer';
      case AccountType.worker:
        return 'worker';
    }
  }

  static AccountType fromJson(String json) {
    switch (json) {
      case 'customer':
        return AccountType.customer;
      case 'worker':
        return AccountType.worker;
      default:
        throw ArgumentError('Invalid AccountType value: $json');
    }
  }
}
