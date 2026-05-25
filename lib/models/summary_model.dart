class SummaryModel {
  final double income;
  final double expense;
  final double balance;
  

  SummaryModel({
    required this.income,
    required this.expense,
    required this.balance,

  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      income: double.parse(json['total_income'].toString()),
      expense: double.parse(json['total_expense'].toString()),
      balance: double.parse(json['balance'].toString()),
    );
  }
}