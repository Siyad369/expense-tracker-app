import 'voice_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../widgets/category_pie_chart.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<FinanceProvider>(context, listen: false)
          .loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const VoiceTransactionScreen(),
            ),
          );

          if (result == true) {
            Provider.of<FinanceProvider>(context, listen: false)
                .loadDashboard();
          }
        },
        child: const Icon(Icons.add),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: _buildBody(provider),
        ),
      ),
    );
  }

  Widget _buildBody(FinanceProvider provider) {

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(child: Text(provider.errorMessage!));
    }

    final income = provider.summary?.income ?? 0;
    final expense = provider.summary?.expense ?? 0;
    final balance = provider.summary?.balance ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// 💰 Balance Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF5B6CFF), Color(0xFF3F51B5)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total Balance",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 5),
              Text(
                "₹ $balance",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        /// 📊 Income / Expense
        Row(
          children: [
            _miniCard("Income", income, Colors.green),
            _miniCard("Expense", expense, Colors.red),
          ],
        ),

        const SizedBox(height: 20),

        const Text(
          "Expense Breakdown",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        /// 📈 Chart
        SizedBox(
          height: 200,
          child: CategoryPieChart(data: provider.analytics),
        ),

        const SizedBox(height: 10),

        /// 📋 List
        Expanded(
          child: provider.analytics.isEmpty
              ? const Center(child: Text("No data"))
              : ListView.builder(
                  itemCount: provider.analytics.length,
                  itemBuilder: (context, index) {
                    final item = provider.analytics[index];

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.type == "expense"
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                          child: Text(
                            item.category.isNotEmpty
                                ? item.category[0]
                                : "?",
                          ),
                        ),
                        title: Text(item.category),
                        subtitle: Text(
                          item.type.toUpperCase(),
                          style: TextStyle(
                            color: item.type == "expense"
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        trailing: Text(
                          "₹ ${item.total}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _miniCard(String title, double amount, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withOpacity(0.1),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color)),
            const SizedBox(height: 6),
            Text(
              "₹ $amount",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}