enum DebtStatus { pending, paid }

class DebtModel {
  final int? id;
  final String customerName;
  final double amount;
  final int transactionId;
  final DebtStatus status;

  DebtModel({
    this.id,
    required this.customerName,
    required this.amount,
    required this.transactionId,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_name': customerName,
      'amount': amount,
      'transaction_id': transactionId,
      'status': status.name,
    };
  }

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map['id'] as int?,
      customerName: map['customer_name'] as String,
      amount: (map['amount'] as num).toDouble(),
      transactionId: map['transaction_id'] as int,
      status: DebtStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DebtStatus.pending,
      ),
    );
  }
}
