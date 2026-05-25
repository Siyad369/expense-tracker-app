import 'package:flutter/material.dart';
import '../core/api_service.dart';
import 'add_debt_screen.dart'; // ✅ IMPORTANT

class Debt {
  final int id;
  final String name;
  final double amount;
  final String status;
  final String dueDate;

  Debt({
    required this.id,
    required this.name,
    required this.amount,
    required this.status,
    required this.dueDate,
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'],
      name: json['name'],
      amount: double.parse(json['amount'].toString()),
      status: json['status'],
      dueDate: json['due_date'],
    );
  }
}

class DebtScreen extends StatefulWidget {
  const DebtScreen({Key? key}) : super(key: key);

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  final ApiService api = ApiService();

  List<Debt> debts = [];
  bool isLoading = true;

  String filter = "pending";

  @override
  void initState() {
    super.initState();
    loadDebts();
  }

  Future<void> loadDebts() async {
    setState(() => isLoading = true);

    try {
      final res = await api.getDebts(filter);
      debts = res.map((e) => Debt.fromJson(e)).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading debts: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> markAsPaid(int id) async {
    await api.markDebtPaid(id);
    loadDebts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Debts")),

      /// ✅ ADD BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddDebtScreen(),
            ),
          );

          if (result == true) {
            loadDebts(); // 🔄 refresh after adding
          }
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [

          /// 🔁 Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text("Pending"),
                selected: filter == "pending",
                onSelected: (_) {
                  setState(() => filter = "pending");
                  loadDebts();
                },
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text("Paid"),
                selected: filter == "paid",
                onSelected: (_) {
                  setState(() => filter = "paid");
                  loadDebts();
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// 📋 List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : debts.isEmpty
                    ? const Center(child: Text("No debts"))
                    : ListView.builder(
                        itemCount: debts.length,
                        itemBuilder: (context, index) {
                          final d = debts[index];

                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  d.name.isNotEmpty ? d.name[0] : "?",
                                ),
                              ),
                              title: Text(d.name),
                              subtitle: Text("Due: ${d.dueDate}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("₹ ${d.amount}"),

                                  /// ✅ Mark Paid
                                  if (d.status == "pending")
                                    IconButton(
                                      icon: const Icon(Icons.check,
                                          color: Colors.green),
                                      onPressed: () => markAsPaid(d.id),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}