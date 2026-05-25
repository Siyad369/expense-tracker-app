class CategoryAnalytics {
  final String category;
  final String type;
  final double total;

  CategoryAnalytics({
    required this.category,
    required this.type,
    required this.total,
  });

  factory CategoryAnalytics.fromJson(Map<String, dynamic> json) {
    return CategoryAnalytics(
      category: json['category'] ?? "Unknown",
      type: json['type'],
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}