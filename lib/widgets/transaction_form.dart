import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionForm extends StatefulWidget {
  final void Function(Map<String, dynamic>) onSubmit;
  final TransactionModel? existingTransaction;

  const TransactionForm({
    super.key,
    required this.onSubmit,
    this.existingTransaction,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _amountController = TextEditingController();
  final _commentController = TextEditingController();
  String _category = 'Food'; // default
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.existingTransaction != null) {
      _amountController.text = widget.existingTransaction!.amount
          .toStringAsFixed(2);
      _commentController.text = widget.existingTransaction!.comment;
      _category = widget.existingTransaction!.category;
      _selectedDate = widget.existingTransaction!.date;
    }
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || _category.isEmpty) return;

    widget.onSubmit({
      'amount': amount,
      'category': _category,
      'comment': _commentController.text.trim(),
      'date': _selectedDate,
    });

    Navigator.of(context).pop();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: ['Food', 'Travel', 'Shopping', 'Bills', 'Health', 'Others']
                .map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                })
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _category = val;
                });
              }
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(labelText: 'Comment (Optional)'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                ),
              ),
              TextButton(onPressed: _pickDate, child: const Text('Pick Date')),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: Text(
              widget.existingTransaction != null
                  ? 'Update Transaction'
                  : 'Add Transaction',
            ),
          ),
        ],
      ),
    );
  }
}
