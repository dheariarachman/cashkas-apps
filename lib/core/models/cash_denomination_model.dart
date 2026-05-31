class CashDenominationModel {
  final int? id;
  final double value;
  final int count;
  final double total;

  CashDenominationModel({
    this.id,
    required this.value,
    required this.count,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
      'count': count,
      'total': total,
    };
  }

  factory CashDenominationModel.fromMap(Map<String, dynamic> map) {
    return CashDenominationModel(
      id: map['id'] as int?,
      value: (map['value'] as num).toDouble(),
      count: map['count'] as int,
      total: (map['total'] as num).toDouble(),
    );
  }
}
