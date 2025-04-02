class WithdrawalRequest {
  final double amount;
  final DateTime sendDate;
  final String status;

  WithdrawalRequest({
    required this.amount,
    required this.sendDate,
    required this.status,
  });
}
