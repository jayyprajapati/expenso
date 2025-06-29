import 'package:expenso/helpers/hive_db.dart';
import 'package:expenso/models/transaction_model.dart';
import 'package:flutter/material.dart';

import 'transaction_form.dart';

Future<void> openAddTransactionModal({
  required BuildContext context,
  required VoidCallback onTransactionAdded,
  TransactionModel? existingTx,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => TransactionForm(
      existingTransaction: existingTx,
      onSubmit: (txData) async {
        final newTx = TransactionModel(
          amount: txData['amount'],
          category: txData['category'],
          comment: txData['comment'],
          date: txData['date'],
        );

        if (existingTx != null) {
          final key = existingTx.key; // HiveObject gives us this
          await HiveDB.update(key, newTx); // you update using key
        } else {
          await HiveDB.add(newTx); // add new entry
        }

        onTransactionAdded();
      },
    ),
  );
}
