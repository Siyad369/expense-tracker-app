import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_service.dart';

import 'providers/finance_provider.dart';

import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(

      create: (_) => FinanceProvider(),

      child: MaterialApp(

        debugShowCheckedModeBanner: false,

        title: "Expense Tracker",

        theme: ThemeData(

          useMaterial3: true,

          fontFamily: 'Roboto',

          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          ),

          scaffoldBackgroundColor:
              const Color(0xFFF5F7FB),

          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.black,
            centerTitle: true,
          ),

          cardTheme: CardTheme(
            elevation: 2,
            margin:
                const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(14),
            ),
          ),

          floatingActionButtonTheme:
              const FloatingActionButtonThemeData(
            backgroundColor: Colors.indigo,
          ),

          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            bodyMedium: TextStyle(fontSize: 14),
          ),
        ),

        home: const AuthChecker(),
      ),
    );
  }
}

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() =>
      _AuthCheckerState();
}

class _AuthCheckerState
    extends State<AuthChecker> {

  final ApiService api = ApiService();

  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();

    checkLogin();
  }

  Future<void> checkLogin() async {

    final token = await api.getAccessToken();

    if (token == null) {

      setState(() {
        isLoggedIn = false;
      });

      return;
    }

    /// TRY REFRESH TOKEN
    final refreshed =
        await api.refreshAccessToken();

    setState(() {
      isLoggedIn = refreshed;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (isLoggedIn == null) {

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (isLoggedIn!) {
      return const MainScreen();
    }

    return const LoginScreen();
  }
}