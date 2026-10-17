enum PaymentMethod {
  cash('Cash', '💵'),
  venmo('Venmo', '📱'),
  card('Card', '💳'),
  free('Free', '🎁');

  const PaymentMethod(this.label, this.emoji);

  final String label;
  final String emoji;

  static PaymentMethod fromKey(String key) {
    return PaymentMethod.values.firstWhere(
      (m) => m.name == key,
      orElse: () => PaymentMethod.cash,
    );
  }
}

enum TransactionSort { newest, oldest, highestTotal, lowestTotal }

enum DateFilterType { all, today, yesterday, last7Days, last30Days, custom }

enum TransactionStatus {
  completed('Completed'),
  refunded('Refunded');

  const TransactionStatus(this.label);
  final String label;
}
