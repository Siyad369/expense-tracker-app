import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../models/debt_model.dart';

class AddDebtScreen extends StatefulWidget {
  final DebtModel? existingDebt;

  const AddDebtScreen({
    Key? key,
    this.existingDebt,
  }) : super(key: key);

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService api = ApiService();

  String name = "";
  double? amount;
  String note = "";

  DateTime selectedDate = DateTime.now();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    /// ✅ EDIT MODE PREFILL
    if (widget.existingDebt != null) {
      final d = widget.existingDebt!;

      name = d.name;
      amount = d.amount;
      note = d.note;
      selectedDate = DateTime.parse(d.dueDate);
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() => isLoading = true);

    try {

      final payload = {
        "name": name,
        "amount": amount,
        "due_date": selectedDate
            .toIso8601String()
            .split("T")[0],
        "note": note,
      };

      /// ✅ UPDATE
      if (widget.existingDebt != null) {

        await api.updateDebt(
          widget.existingDebt!.id,
          payload,
        );

      }

      /// ✅ CREATE
      else {

        await api.addDebt(payload);

      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingDebt != null
                ? "Debt Updated"
                : "Debt Added",
          ),
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
        title: Text(
          widget.existingDebt != null
              ? "Edit Debt"
              : "Add Debt",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: ListView(
            children: [

              /// NAME
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(
                  labelText: "Name",
                ),

                validator: (val) =>
                    val == null || val.isEmpty
                        ? "Enter name"
                        : null,

                onSaved: (val) => name = val!,
              ),

              const SizedBox(height: 10),

              /// AMOUNT
              TextFormField(
                initialValue:
                    amount != null ? amount.toString() : "",

                decoration: const InputDecoration(
                  labelText: "Amount",
                ),

                keyboardType: TextInputType.number,

                validator: (val) =>
                    val == null || val.isEmpty
                        ? "Enter amount"
                        : null,

                onSaved: (val) =>
                    amount = double.parse(val!),
              ),

              const SizedBox(height: 10),

              /// NOTE
              TextFormField(
                initialValue: note,

                decoration: const InputDecoration(
                  labelText: "Note",
                ),

                onSaved: (val) => note = val ?? "",
              ),

              const SizedBox(height: 10),

              /// DATE PICKER
              ListTile(
                title: Text(
                  "Due Date: ${selectedDate.toString().split(" ")[0]}",
                ),

                trailing: const Icon(Icons.calendar_today),

                onTap: () async {

                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );

                  if (picked != null) {

                    setState(() {
                      selectedDate = picked;
                    });

                  }
                },
              ),

              const SizedBox(height: 20),

              /// SUBMIT BUTTON
              ElevatedButton(
                onPressed: isLoading ? null : submit,

                child: isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        widget.existingDebt != null
                            ? "Update Debt"
                            : "Add Debt",
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}