import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/category_analytics_model.dart';

class CategoryPieChart extends StatelessWidget {
  final List<CategoryAnalytics> data;

  const CategoryPieChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expenseData = data.where((e) => e.type == 'expense').toList();

    if (expenseData.isEmpty) {
      return const Center(child: Text("No expense data"));
    }

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: expenseData.map((e) {
            return PieChartSectionData(
              value: e.total,
              title: e.category,
              radius: 60,
            );
          }).toList(),
        ),
      ),
    );
  }
}