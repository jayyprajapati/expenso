import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../helpers/db_helper.dart';
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
        final tx = TransactionModel(
          id: existingTx?.id,
          amount: txData['amount'],
          category: txData['category'],
          comment: txData['comment'],
          date: txData['date'],
        );

        if (existingTx != null) {
          await DBHelper.update(tx);
        } else {
          await DBHelper.insert(tx);
        }

        onTransactionAdded();
      },
    ),
  );
}
