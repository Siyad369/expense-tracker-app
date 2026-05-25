import 'package:flutter/material.dart';
import '../core/api_service.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({Key? key}) : super(key: key);

  @override
  State<AddCategoryScreen> createState() =>
      _AddCategoryScreenState();
}

class _AddCategoryScreenState
    extends State<AddCategoryScreen> {

  final _formKey = GlobalKey<FormState>();

  final ApiService api = ApiService();

  String name = "";
  String type = "expense";

  bool isLoading = false;

  Future<void> submit() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      isLoading = true;
    });

    try {

      await api.addCategory({
        "name": name,
        "type": type,
      });

      if (!mounted) return;

      /// ✅ SUCCESS MESSAGE
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Category Added Successfully"),
        ),
      );

      /// ✅ RESET FORM
      _formKey.currentState!.reset();

      setState(() {
        type = "expense";
        name = "";
      });

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Add Category"),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Form(

          key: _formKey,

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [

              const SizedBox(height: 20),

              /// CATEGORY NAME
              TextFormField(

                decoration: InputDecoration(

                  labelText: "Category Name",

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),

                validator: (val) {

                  if (val == null || val.isEmpty) {
                    return "Enter category name";
                  }

                  return null;
                },

                onSaved: (val) {
                  name = val!.trim();
                },
              ),

              const SizedBox(height: 20),

              /// TYPE
              DropdownButtonFormField<String>(

                value: type,

                decoration: InputDecoration(

                  labelText: "Category Type",

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),

                items: const [

                  DropdownMenuItem(
                    value: "expense",
                    child: Text("Expense"),
                  ),

                  DropdownMenuItem(
                    value: "income",
                    child: Text("Income"),
                  ),
                ],

                onChanged: (val) {

                  setState(() {
                    type = val!;
                  });
                },
              ),

              const SizedBox(height: 30),

              /// BUTTON
              SizedBox(

                height: 55,

                child: ElevatedButton(

                  onPressed:
                      isLoading ? null : submit,

                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),

                  child: isLoading

                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )

                      : const Text(
                          "Add Category",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}