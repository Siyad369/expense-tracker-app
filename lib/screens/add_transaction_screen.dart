import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? existingTransaction;

  const AddTransactionScreen({
    Key? key,
    this.existingTransaction,
  }) : super(key: key);

  @override
  State<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService api = ApiService();

  String type = 'expense';
  double? amount;
  int? categoryId;
  String note = "";
  DateTime selectedDate = DateTime.now();

  List<CategoryModel> categories = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCategories();

    /// ✅ PREFILL (EDIT MODE)
    if (widget.existingTransaction != null) {
      final t = widget.existingTransaction!;

      type = t.type;
      amount = t.amount;
      categoryId = t.category;
      note = t.note;
      selectedDate = DateTime.parse(t.date);
    }
  }

  Future<void> loadCategories() async {
    final data = await api.getCategories();

    setState(() {
      categories =
          data.map((e) => CategoryModel.fromJson(e)).toList();
    });
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() => isLoading = true);

    try {
      final payload = {
        "type": type,
        "amount": amount,
        "category": categoryId,
        "date": selectedDate.toIso8601String().split("T")[0],
        "note": note,
      };

      /// ✅ EDIT MODE
      if (widget.existingTransaction != null) {
        await api.updateTransaction(
          widget.existingTransaction!.id,
          payload,
        );
      } 
      /// ✅ CREATE MODE
      else {
        await api.addTransaction(payload);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingTransaction != null
              ? "Transaction Updated"
              : "Transaction Added"),
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTransaction != null
            ? "Edit Transaction"
            : "Add Transaction"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              /// TYPE
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: "expense", child: Text("Expense")),
                  DropdownMenuItem(value: "income", child: Text("Income")),
                ],
                onChanged: (val) => setState(() => type = val!),
              ),

              const SizedBox(height: 10),

              /// AMOUNT
              TextFormField(
                initialValue: amount != null ? amount.toString() : "",
                decoration: const InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter amount" : null,
                onSaved: (val) => amount = double.parse(val!),
              ),

              const SizedBox(height: 10),

              /// CATEGORY
              DropdownButtonFormField<int>(
                value: categoryId,
                hint: const Text("Select Category"),
                items: categories.map((c) {
                  return DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => categoryId = val),
                validator: (val) =>
                    val == null ? "Select category" : null,
              ),

              const SizedBox(height: 10),

              /// NOTE
              TextFormField(
                initialValue: note,
                decoration: const InputDecoration(labelText: "Note"),
                onSaved: (val) => note = val ?? "",
              ),

              const SizedBox(height: 10),

              /// DATE
              ListTile(
                title: Text(
                    "Date: ${selectedDate.toLocal().toString().split(" ")[0]}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );

                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
              ),

              const SizedBox(height: 20),

              /// SUBMIT
              ElevatedButton(
                onPressed: isLoading ? null : submit,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.existingTransaction != null
                        ? "Update Transaction"
                        : "Add Transaction"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}