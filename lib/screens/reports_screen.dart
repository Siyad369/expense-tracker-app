import 'package:flutter/material.dart';
import '../core/api_service.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() =>
      _ReportsScreenState();
}

class _ReportsScreenState
    extends State<ReportsScreen> {

  final ApiService api = ApiService();

  bool isLoading = true;

  int selectedMonth =
      DateTime.now().month;

  int selectedYear =
      DateTime.now().year;

  Map<String, dynamic>? report;

  List<dynamic> monthlyTrend = [];

  List<dynamic> categoryBreakdown = [];

  final months = const [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  @override
  void initState() {
    super.initState();
    loadReport();
  }

  Future<void> loadReport() async {

    setState(() => isLoading = true);

    try {
      final summary =
          await api.getAnalyticsSummary(
        month: selectedMonth,
        year: selectedYear,
      );

      final trend =
          await api.getMonthlyTrend();

      final breakdown =
          await api.getCategoryBreakdown();

      report = summary;

      monthlyTrend = trend;

      categoryBreakdown = breakdown;

    } catch (e) {

      debugPrint(e.toString());

    } finally {

      setState(() => isLoading = false);
    }
  }
Widget buildBarChart() {
  if (monthlyTrend.isEmpty) {
    return const SizedBox();
  }

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Income vs Expense Trend",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                      const monthNames = [
                        '',
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'May',
                        'Jun',
                        'Jul',
                        'Aug',
                        'Sep',
                        'Oct',
                        'Nov',
                        'Dec'
                      ];

                      return Text(
                        monthNames[value.toInt()],
                        style: const TextStyle(fontSize: 10),
                      );  
                      },
                    ),
                  ),
                ),
                barGroups: monthlyTrend.map((item) {
                  return BarChartGroupData(
                    x: item['month'],
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: (item['income'] ?? 0).toDouble(),
                        width: 10,
                      ),
                      BarChartRodData(
                        toY: (item['expense'] ?? 0).toDouble(),
                        width: 10,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildPieChart() {
  if (categoryBreakdown.isEmpty) {
    return const SizedBox();
  }

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Expense Categories",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 280,
            child: PieChart(
              PieChartData(
                sections: categoryBreakdown.map((item) {
                  return PieChartSectionData(
                    value: (item['total'] ?? 0).toDouble(),
                    title: item['category'],
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
  Widget buildCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Reports"),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(

              padding:
                  const EdgeInsets.all(16),

              child: Column(

                children: [

                  DropdownButton<int>(

                    value: selectedMonth,

                    isExpanded: true,

                    items: List.generate(
                      12,
                      (index) {

                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text(
                            months[index],
                          ),
                        );
                      },
                    ),

                    onChanged: (value) {

                      setState(() {
                        selectedMonth = value!;
                      });

                      loadReport();
                    },
                  ),

                        const SizedBox(height: 20),

                        buildBarChart(),

                        const SizedBox(height: 20),

                        buildPieChart(),

                    const SizedBox(height: 20),

                    buildCard(
                      "Monthly Income",
                      "₹ ${report?['monthly_income'] ?? 0}",
                      Icons.arrow_downward,
                    ),

                  buildCard(
                    "Monthly Expense",
                    "₹ ${report?['monthly_expense'] ?? 0}",
                    Icons.arrow_upward,
                  ),

                  buildCard(
                    "Weekly Income",
                    "₹ ${report?['weekly_income'] ?? 0}",
                    Icons.account_balance,
                  ),

                  buildCard(
                    "Weekly Expense",
                    "₹ ${report?['weekly_expense'] ?? 0}",
                    Icons.money_off,
                  ),

                  buildCard(
                    "Total Transactions",
                    "${report?['total_transactions'] ?? 0}",
                    Icons.list_alt,
                  ),

                  Card(
                    child: ListTile(
                      title: const Text(
                        "Top Expense Category",
                      ),
                      subtitle: Text(
                        report?[
                                    'highest_expense_category']
                                ?['category__name']
                                ?.toString() ??
                            "N/A",
                      ),
                      trailing: Text(
                        "₹ ${report?['highest_expense_category']?['total'] ?? 0}",
                      ),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      title: const Text(
                        "Top Income Category",
                      ),
                      subtitle: Text(
                        report?[
                                    'highest_income_category']
                                ?['category__name']
                                ?.toString() ??
                            "N/A",
                      ),
                      trailing: Text(
                        "₹ ${report?['highest_income_category']?['total'] ?? 0}",
                      ),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      title: const Text(
                        "Most Expensive Day",
                      ),
                      subtitle: Text(
                        report?[
                                    'most_expensive_day']
                                ?['date']
                                ?.toString() ??
                            "N/A",
                      ),
                      trailing: Text(
                        "₹ ${report?['most_expensive_day']?['total'] ?? 0}",
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}