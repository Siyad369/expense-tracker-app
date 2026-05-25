class DebtModel {
  final int id;
  final String name;
  final double amount;
  final String status;
  final String dueDate;
  final String note;

  DebtModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.status,
    required this.dueDate,
    required this.note,
  });

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'],
      name: json['name'],
      amount: double.parse(json['amount'].toString()),
      status: json['status'],
      dueDate: json['due_date'],
      note: json['note'] ?? "",
    );
  }
}