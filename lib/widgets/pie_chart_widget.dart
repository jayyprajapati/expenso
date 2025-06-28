import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const CategoryPieChart({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    final total = categoryTotals.values.fold(0.0, (a, b) => a + b);

    if (total == 0) {
      return const Center(child: Text('No spending this month.'));
    }

    final colors = [
      Colors.teal,
      Colors.orange,
      Colors.purple,
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.brown,
      Colors.cyan,
    ];

    final sections = categoryTotals.entries.mapIndexed((entry, index) {
      final value = entry.value;
      // final percent = (value / total * 100).toStringAsFixed(1);
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: value,
        title: '${entry.key}\n₹${value.toInt()}',
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        radius: 80,
      );
    }).toList();

    return PieChart(
      PieChartData(sections: sections, centerSpaceRadius: 40, sectionsSpace: 2),
    );
  }
}

extension<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) sync* {
    int i = 0;
    for (final element in this) {
      yield f(element, i++);
    }
  }
}
