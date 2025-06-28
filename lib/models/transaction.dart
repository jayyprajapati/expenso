class TransactionModel {
  final int? id;
  final double amount;
  final String category;
  final String comment;
  final DateTime date;

  TransactionModel({
    this.id,
    required this.amount,
    required this.category,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      comment: map['comment'],
      date: DateTime.parse(map['date']),
    );
  }
}
