import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../core/api_service.dart';

class VoiceTransactionScreen extends StatefulWidget {
  const VoiceTransactionScreen({super.key});

  @override
  State<VoiceTransactionScreen> createState() =>
      _VoiceTransactionScreenState();
}

class _VoiceTransactionScreenState
    extends State<VoiceTransactionScreen> {

  final SpeechToText speech =
      SpeechToText();

  final ApiService api =
      ApiService();

  bool isListening = false;

  bool isLoading = false;

  String spokenText =
      "Tap mic and speak";

  Map<String, dynamic>? parsedData;
  final amountController =
    TextEditingController();

  final noteController =
      TextEditingController();

  String selectedType = "expense";

  int? selectedCategoryId;

  String selectedCategoryName = "";

  /// START LISTENING
  Future<void> startListening() async {

    final available =
        await speech.initialize();

    if (!available) return;

    setState(() {
      isListening = true;
    });

    speech.listen(

      onResult: (result) {

        setState(() {
          spokenText =
              result.recognizedWords;
        });
      },
    );
  }

  /// STOP
  Future<void> stopListening() async {

    await speech.stop();

    setState(() {
      isListening = false;
    });

    await parseText();
  }

  /// AI PARSE
  Future<void> parseText() async {

    if (spokenText.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {

      final result =
          await api.parseAITransaction(
        spokenText,
      );

      setState(() {

        parsedData = result;

        amountController.text =
            result["amount"].toString();

        noteController.text =
            result["note"];

        selectedType =
            result["type"];

        selectedCategoryId =
            result["category"];

        selectedCategoryName =
            result["category_name"];
      });

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text("Error: $e"),
        ),
      );

    } finally {

      setState(() {
        isLoading = false;
      });
    }
  }

  /// SAVE TO DB
  Future<void> saveTransaction() async {

    if (parsedData == null) return;

    try {

      await api.addTransaction({

        "type": selectedType,

        "amount":
             double.parse(amountController.text),

        "category":
            parsedData!["category"],

        "date": DateTime.now()
            .toIso8601String()
            .split("T")[0],

        "note": noteController.text,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
              Text("Transaction Added"),
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
            const Text("AI Voice Transaction"),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          children: [

            const SizedBox(height: 30),

            /// SPOKEN TEXT
            Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(20),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(16),
              ),

              child: Text(

                spokenText,

                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// MIC BUTTON
            GestureDetector(

              onTap: () {

                if (isListening) {
                  stopListening();
                } else {
                  startListening();
                }
              },

              child: CircleAvatar(

                radius: 40,

                backgroundColor:
                    isListening
                        ? Colors.red
                        : Colors.indigo,

                child: Icon(

                  isListening
                      ? Icons.mic
                      : Icons.mic_none,

                  color: Colors.white,
                  size: 35,
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (isLoading)
              const CircularProgressIndicator(),

          if (parsedData != null)

            Card(

              child: Padding(

                padding: const EdgeInsets.all(20),

                child: Column(

                  children: [

                    /// TYPE
                    DropdownButtonFormField<String>(

                      value: selectedType,

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
                          selectedType = val!;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    /// AMOUNT
                    TextField(

                      controller: amountController,

                      keyboardType:
                          TextInputType.number,

                      decoration:
                          const InputDecoration(
                        labelText: "Amount",
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// CATEGORY
                    TextField(

                      decoration:
                          const InputDecoration(
                        labelText: "Category",
                      ),

                      controller: TextEditingController(
                        text: selectedCategoryName,
                      ),

                      onChanged: (val) {
                        selectedCategoryName = val;
                      },
                    ),

                    const SizedBox(height: 15),

                    /// NOTE
                    TextField(

                      controller: noteController,

                      maxLines: 2,

                      decoration:
                          const InputDecoration(
                        labelText: "Note",
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(

                      width: double.infinity,

                      child: ElevatedButton(

                        onPressed: saveTransaction,

                        child: const Text(
                          "Confirm & Save",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}