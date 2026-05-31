enum TransactionType { transfer, withdrawal, topup, ppob, other }
enum TransactionStatus { lunas, piutang }

class TransactionModel {
  final int? id;
  final int walletId;
  final TransactionType type;
  final double amount;
  final double fee;
  final double cost;
  final double profit;
  final TransactionStatus status;
  final String createdAt;

  TransactionModel({
    this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.fee,
    required this.cost,
    required this.profit,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wallet_id': walletId,
      'type': type.name,
      'amount': amount,
      'fee': fee,
      'cost': cost,
      'profit': profit,
      'status': status.name,
      'created_at': createdAt,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      walletId: map['wallet_id'] as int,
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.other,
      ),
      amount: (map['amount'] as num).toDouble(),
      fee: (map['fee'] as num).toDouble(),
      cost: (map['cost'] as num).toDouble(),
      profit: (map['profit'] as num).toDouble(),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TransactionStatus.lunas,
      ),
      createdAt: map['created_at'] as String,
    );
  }
}
