import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../models/summary_model.dart';
import '../models/category_analytics_model.dart';

class FinanceProvider with ChangeNotifier {
  final ApiService api = ApiService();

  SummaryModel? summary;
  List<CategoryAnalytics> analytics = [];

  bool isLoading = false;
  String? errorMessage;

  /// Load Dashboard Data (Summary + Analytics)
  Future<void> loadDashboard() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      print("🔄 Loading dashboard...");

      // ✅ Fetch Summary
      final summaryData = await api.getSummary();
      print("✅ Summary API response: $summaryData");

      summary = SummaryModel.fromJson(summaryData);

      // ✅ Fetch Analytics
      final analyticsData = await api.getCategoryAnalytics();
      print("✅ Analytics API response: $analyticsData");
      print("SUMMARY RAW: $summaryData");

      analytics = analyticsData
          .map((e) => CategoryAnalytics.fromJson(e))
          .toList();

    } catch (e) {
      print("❌ ERROR in loadDashboard: $e");
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}