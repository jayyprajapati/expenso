import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

class HiveDB {
  static final Box<TransactionModel> _box = Hive.box('transactions');

  static Future<void> add(TransactionModel tx) async {
    await _box.add(tx);
  }

  static List<TransactionModel> getAll() {
    return _box.values.toList();
  }

  static Future<void> delete(int index) async {
    await _box.deleteAt(index);
  }

  static Future<void> update(int index, TransactionModel tx) async {
    await _box.putAt(index, tx);
  }

  static Box<TransactionModel> get box => _box;
}
