import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final double amount;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final String comment;

  @HiveField(3)
  final DateTime date;

  // No need to manually manage id — `HiveObject` provides .key (or use the object reference)
  TransactionModel({
    required this.amount,
    required this.category,
    required this.comment,
    required this.date,
  });
}
