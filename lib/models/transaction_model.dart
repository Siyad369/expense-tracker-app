class TransactionModel {
  final int id;
  final String type;
  final double amount;
  final int category;
  final String date;
  final String note;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      type: json['type'],
      amount: double.parse(json['amount'].toString()),
      category: json['category'],
      date: json['date'],
      note: json['note'] ?? "",
    );
  }
}