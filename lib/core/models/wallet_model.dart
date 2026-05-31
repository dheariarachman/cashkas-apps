enum WalletType { bank, eWallet, cash }

class WalletModel {
  final int? id;
  final String name;
  final double balance;
  final WalletType type;

  WalletModel({
    this.id,
    required this.name,
    required this.balance,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'type': type.name,
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      balance: (map['balance'] as num).toDouble(),
      type: WalletType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => WalletType.bank,
      ),
    );
  }
}
