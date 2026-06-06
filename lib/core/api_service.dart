import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  static const String baseUrl =
      "https://expense-tracker-k33j.onrender.com/api/";

  /// =========================
  /// TOKEN STORAGE
  /// =========================

  Future<void> saveTokens(
    String access,
    String refresh,
  ) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("access", access);

    await prefs.setString("refresh", refresh);
  }

  Future<String?> getAccessToken() async {

    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("access");
  }

  Future<void> logout() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }

  /// =========================
  /// AUTH HEADER
  /// =========================

  Future<Map<String, String>> getHeaders() async {

    final token = await getAccessToken();

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  /// =========================
  /// LOGIN
  /// =========================

Future<bool> login(
  String username,
  String password,
) async {

  try {

    print("LOGIN START");

    final url = Uri.parse("${baseUrl}auth/login/");

    print("URL: $url");

    final res = await http
        .post(
          url,

          headers: {
            "Content-Type": "application/json",
          },

          body: jsonEncode({
            "username": username,
            "password": password,
          }),
        )
        .timeout(const Duration(seconds: 60));

    print("STATUS CODE: ${res.statusCode}");
    print("BODY: ${res.body}");

    if (res.statusCode == 200) {

      final data = jsonDecode(res.body);

      print("ACCESS TOKEN: ${data['access']}");

      await saveTokens(
        data['access'],
        data['refresh'],
      );

      print("TOKENS SAVED");

      return true;
    }

    return false;

  } catch (e) {

    print("LOGIN EXCEPTION:");
    print(e.toString());

    return false;
  }
}

  /// =========================
  /// REGISTER
  /// =========================

  Future<bool> register(
    String username,
    String password,
  ) async {

    final res = await http.post(
      Uri.parse("${baseUrl}auth/register/"),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    return res.statusCode == 201;
  }

  /// =========================
  /// SUMMARY
  /// =========================

  Future<Map<String, dynamic>> getSummary() async {
   
    final res = await authorizedGet(
      "reports/summary/",
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw Exception("Summary failed");
  }

  /// =========================
  /// ANALYTICS
  /// =========================

  Future<List<dynamic>> getCategoryAnalytics() async {

    final res = await http.get(
      Uri.parse("${baseUrl}reports/analytics/category/"),
      headers: await getHeaders(),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw Exception("Analytics failed");
  }

  /// =========================
  /// CATEGORIES
  /// =========================

  Future<List<dynamic>> getCategories() async {

    final res = await http.get(
      Uri.parse("${baseUrl}finance/categories/"),
      headers: await getHeaders(),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw Exception("Failed to load categories");
  }

  Future<void> addCategory(
      Map<String, dynamic> data,
      ) async {

    final res = await http.post(
      Uri.parse("${baseUrl}finance/categories/"),

      headers: await getHeaders(),

      body: jsonEncode(data),
    );

    if (res.statusCode != 201) {
      throw Exception("Failed to add category");
    }
  }

  /// =========================
  /// TRANSACTIONS
  /// =========================

  Future<List<dynamic>> getTransactions() async {

    final res = await http.get(
      Uri.parse("${baseUrl}finance/transactions/"),
      headers: await getHeaders(),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw Exception("Failed to load transactions");
  }

  Future<void> addTransaction(
      Map<String, dynamic> data,
      ) async {

    final res = await http.post(
      Uri.parse("${baseUrl}finance/transactions/"),

      headers: await getHeaders(),

      body: jsonEncode(data),
    );

    if (res.statusCode != 201) {
      throw Exception("Failed to add transaction");
    }
  }

  Future<void> updateTransaction(
      int id,
      Map<String, dynamic> data,
      ) async {

    final res = await http.put(
      Uri.parse("${baseUrl}finance/transactions/$id/"),

      headers: await getHeaders(),

      body: jsonEncode(data),
    );

    if (res.statusCode != 200) {
      throw Exception("Update failed");
    }
  }

  Future<void> deleteTransaction(int id) async {

    final res = await http.delete(
      Uri.parse("${baseUrl}finance/transactions/$id/"),
      headers: await getHeaders(),
    );

    if (res.statusCode != 204) {
      throw Exception("Delete failed");
    }
  }

  /// =========================
  /// DEBTS
  /// =========================

  Future<List<dynamic>> getDebts(
      String status,
      ) async {

    final res = await http.get(
      Uri.parse(
          "${baseUrl}finance/debts/?status=$status"),

      headers: await getHeaders(),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw Exception("Failed to load debts");
  }

  Future<void> addDebt(
      Map<String, dynamic> data,
      ) async {

    final res = await http.post(
      Uri.parse("${baseUrl}finance/debts/"),

      headers: await getHeaders(),

      body: jsonEncode(data),
    );

    if (res.statusCode != 201) {
      throw Exception("Failed to add debt");
    }
  }

  Future<void> updateDebt(
      int id,
      Map<String, dynamic> data,
      ) async {

    final res = await http.put(
      Uri.parse("${baseUrl}finance/debts/$id/"),

      headers: await getHeaders(),

      body: jsonEncode(data),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to update debt");
    }
  }

  Future<void> deleteDebt(int id) async {

    final res = await http.delete(
      Uri.parse("${baseUrl}finance/debts/$id/"),

      headers: await getHeaders(),
    );

    if (res.statusCode != 204) {
      throw Exception("Failed to delete debt");
    }
  }

  Future<void> markDebtPaid(int id) async {
    final res = await http.patch(
      Uri.parse("${baseUrl}finance/debts/$id/mark-paid/"),
      headers: await getHeaders(),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to mark paid");
    }
  }
  Future<bool> refreshAccessToken() async {

    final prefs = await SharedPreferences.getInstance();

    final refresh = prefs.getString("refresh");

    if (refresh == null) {
      return false;
    }

    try {

      final res = await http.post(
        Uri.parse("${baseUrl}auth/refresh/"),

        headers: {
          "Content-Type": "application/json",
        },

        body: jsonEncode({
          "refresh": refresh,
        }),
      );

      if (res.statusCode == 200) {

        final data = jsonDecode(res.body);

        await prefs.setString(
          "access",
          data["access"],
        );

        return true;
      }

      return false;

    } catch (e) {

      print("REFRESH ERROR: $e");

      return false;
    }
  }
  Future<http.Response> authorizedGet(
    String endpoint,
  ) async {
  
    var headers = await getHeaders();
  
    var res = await http.get(
      Uri.parse("${baseUrl}$endpoint"),
      headers: headers,
    );
  
    /// ACCESS TOKEN EXPIRED
    if (res.statusCode == 401) {
  
      final refreshed = await refreshAccessToken();
  
      if (refreshed) {
  
        headers = await getHeaders();
  
        res = await http.get(
          Uri.parse("${baseUrl}$endpoint"),
          headers: headers,
        );
      }
    }
  
    return res;
  }

  Future<Map<String, dynamic>> getAnalyticsSummary({
    required int month,
    required int year,
  }) async {

    final res = await authorizedGet(
      "reports/analytics/summary/?month=$month&year=$year",
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw Exception("Failed to load analytics");
  }

  Future<List<dynamic>> getMonthlyTrend() async {

  final res = await authorizedGet(
    "reports/analytics/monthly-trend/",
  );

  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  }

  throw Exception("Monthly trend failed");
}

Future<List<dynamic>> getCategoryBreakdown() async {

  final res = await authorizedGet(
    "reports/analytics/category-breakdown/",
  );

  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  }

  throw Exception("Category breakdown failed");
}
  Future<Map<String, dynamic>> parseAITransaction(
  String text,
) async {

  final res = await http.post(

    Uri.parse("${baseUrl}finance/ai/parse-transaction/"),

    headers: await getHeaders(),

    body: jsonEncode({
      "text": text,
    }),
  );

  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  }

  throw Exception("AI parsing failed");
}
}
