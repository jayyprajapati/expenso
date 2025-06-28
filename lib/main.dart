import 'package:flutter/material.dart';
// import '../widgets/transaction_form.dart';
import '../helpers/db_helper.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/bar_chart_widget.dart';
import '../widgets/add_transaction_modal.dart';

void main() {
  runApp(const PersonalFinanceApp());
}

class PersonalFinanceApp extends StatelessWidget {
  const PersonalFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenso',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _selectedMonth;
  late int _selectedYear;
  List<TransactionModel> _transactions = [];

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<int> _years = List.generate(5, (i) => DateTime.now().year - i);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final data = await DBHelper.getAllTransactions();
    setState(() {
      _transactions = data;
    });
  }

  Map<String, double> get _categoryTotals {
    final filtered = _transactions.where(
      (tx) => tx.date.month == _selectedMonth && tx.date.year == _selectedYear,
    );

    final Map<String, double> totals = {};
    for (var tx in filtered) {
      totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
    }
    return totals;
  }

  Map<String, double> get _yearlyCategoryTotals {
    final filtered = _transactions.where((tx) => tx.date.year == _selectedYear);

    final Map<String, double> totals = {};
    for (var tx in filtered) {
      totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
    }
    return totals;
  }

  void _openAddTransactionForm() {
    openAddTransactionModal(
      context: context,
      onTransactionAdded: _loadTransactions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filters
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<int>(
                value: _selectedMonth,
                items: List.generate(12, (i) {
                  return DropdownMenuItem(
                    value: i + 1,
                    child: Text(_months[i]),
                  );
                }),
                onChanged: (val) {
                  setState(() {
                    _selectedMonth = val!;
                  });
                },
              ),
              DropdownButton<int>(
                value: _selectedYear,
                items: _years
                    .map(
                      (y) =>
                          DropdownMenuItem(value: y, child: Text(y.toString())),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedYear = val!;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Monthly Spending (Pie Chart)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 250,
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CategoryPieChart(categoryTotals: _categoryTotals),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Yearly Spending (Bar Chart)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 250,
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: YearlyBarChart(
                        categoryTotals: _yearlyCategoryTotals,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _openAddTransactionForm,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Expense'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<TransactionModel> _transactions = [];

  final List<String> _months = [
    'All',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late int _selectedYear;
  String _selectedMonth = 'All';
  List<int> _years = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _years = List.generate(5, (i) => now.year - i);
    _loadTransactions();
  }

  List<TransactionModel> get _filteredTransactions {
    return _transactions.where((tx) {
      final txDate = tx.date;
      final isSameYear = txDate.year == _selectedYear;

      if (_selectedMonth == 'All') return isSameYear;

      final monthIndex = _months.indexOf(_selectedMonth);
      return isSameYear && txDate.month == monthIndex;
    }).toList();
  }

  Future<void> _loadTransactions() async {
    final data = await DBHelper.getAllTransactions();
    setState(() {
      _transactions = data;
    });
  }

  Map<String, List<TransactionModel>> _groupTransactionsByMonth(
    List<TransactionModel> transactions,
  ) {
    final Map<String, List<TransactionModel>> grouped = {};

    for (var tx in transactions) {
      final key = '${DateFormat.yMMMM().format(tx.date)}'; // e.g., "May 2025"
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(tx);
    }

    // Optional: sort transactions in each group by date (latest first)
    for (var list in grouped.values) {
      list.sort((a, b) => b.date.compareTo(a.date));
    }

    // Sort groups (months) by their latest tx date
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat.yMMMM().parse(a);
        final dateB = DateFormat.yMMMM().parse(b);
        return dateB.compareTo(dateA); // latest month first
      });

    final sortedMap = {for (var k in sortedKeys) k: grouped[k]!};

    return sortedMap;
  }

  List<Widget> _buildGroupedTransactionList() {
    final grouped = _groupTransactionsByMonth(_filteredTransactions);

    return grouped.entries.expand((entry) {
      final monthLabel = entry.key;
      final transactions = entry.value;

      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            monthLabel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
        ...transactions.map((tx) {
          return ListTile(
            leading: const Icon(Icons.monetization_on),
            title: Text('₹${tx.amount} - ${tx.category}'),
            subtitle: Text(
              '${tx.comment} • ${DateFormat.yMMMd().format(tx.date)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () {
                    openAddTransactionModal(
                      context: context,
                      onTransactionAdded: _loadTransactions,
                      existingTx: tx,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text(
                          'Are you sure you want to delete this transaction?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await DBHelper.delete(tx.id!);
                      _loadTransactions();
                    }
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ];
    }).toList();
  }

  void _openAddTransactionForm() {
    openAddTransactionModal(
      context: context,
      onTransactionAdded: _loadTransactions,
    );
  }

  // Future<void> _addTransaction(Map<String, dynamic> txData) async {
  //   final tx = TransactionModel(
  //     amount: txData['amount'],
  //     category: txData['category'],
  //     comment: txData['comment'],
  //     date: txData['date'],
  //   );
  //   await DBHelper.insert(tx);
  //   _loadTransactions(); // refresh list
  // }

  @override
  Widget build(BuildContext context) {
    final totalMonth = _filteredTransactions.fold<double>(
      0.0,
      (sum, tx) => sum + tx.amount,
    );

    final totalYear = _transactions
        .where((tx) => tx.date.year == _selectedYear)
        .fold<double>(0.0, (sum, tx) => sum + tx.amount);

    return Scaffold(
      body: Column(
        children: [
          // 🔘 Filters
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedMonth,
                  items: _months
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedMonth = val!;
                    });
                  },
                ),
                DropdownButton<int>(
                  value: _selectedYear,
                  items: _years
                      .map(
                        (y) => DropdownMenuItem(
                          value: y,
                          child: Text(y.toString()),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedYear = val!;
                    });
                  },
                ),
              ],
            ),
          ),

          // 💰 Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'This Month: ₹${totalMonth.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Year: ₹${totalYear.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 📋 Transaction List
          Expanded(
            child: _filteredTransactions.isEmpty
                ? const Center(child: Text('No transactions found.'))
                : ListView(children: _buildGroupedTransactionList()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransactionForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
