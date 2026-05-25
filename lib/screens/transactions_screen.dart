import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../models/transaction_model.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final ApiService api = ApiService();

  List<TransactionModel> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    setState(() => isLoading = true);

    try {
      final data = await api.getTransactions();

      transactions =
          data.map((e) => TransactionModel.fromJson(e)).toList();
    } catch (e) {
      print("Error loading transactions: $e");
    }

    setState(() => isLoading = false);
  }

  /// DELETE
  Future<void> deleteTransaction(int id) async {
    await api.deleteTransaction(id);
    loadTransactions();
  }

  /// EDIT
  Future<void> editTransaction(TransactionModel txn) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(
          existingTransaction: txn,
        ),
      ),
    );

    if (result == true) {
      loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transactions")),
      floatingActionButton: FloatingActionButton(
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddTransactionScreen(),
      ),
    );

    if (result == true) {
      loadTransactions();
    }
  },
  child: const Icon(Icons.add),
),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? const Center(child: Text("No transactions"))
              : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final t = transactions[index];

                    return Card(
                      child: ListTile(
                        title: Text("₹ ${t.amount}"),
                        subtitle: Text("${t.type} • ${t.date}"),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            /// EDIT
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => editTransaction(t),
                            ),

                            /// DELETE
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteTransaction(t.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}