import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'core/language_provider.dart';
import 'core/subscription_provider.dart';
import 'core/favorites_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/login/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/daily_suggestions_engine.dart';

import 'core/currency_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Map<String, dynamic>> allWomen = [];
  List<Map<String, dynamic>> wildcards = [];
  bool initialized = false;

  static const _wildcardUrl =
      'https://raw.githubusercontent.com/01010app/her-echoes-app/main/assets/data/wildcard.json';

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    // her_echoes.json — siempre local (asset)
    try {
      final response =
          await rootBundle.loadString('assets/data/her_echoes.json');
      final decoded = json.decode(response);
      final List<dynamic> data =
          decoded is List ? decoded : decoded["data"] ?? [];
      allWomen = data
          .cast<Map<String, dynamic>>()
          .where((w) => (w["woman_id"] ?? "").toString().isNotEmpty)
          .toList();
    } catch (e) {
      print("her_echoes.json ERROR: $e");
      allWomen = [];
    }

    // wildcard.json — primero intenta GitHub, fallback a asset local
    try {
      final res = await http.get(Uri.parse(_wildcardUrl))
          .timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final wcDecoded = json.decode(res.body);
        final List<dynamic> wcData = wcDecoded is List ? wcDecoded : [];
        wildcards = wcData
            .cast<Map<String, dynamic>>()
            .where((w) => (w["woman_id"] ?? "").toString().isNotEmpty)
            .toList();
      } else {
        throw Exception('HTTP ${res.statusCode}');
      }
    } catch (e) {
      print("wildcard GitHub ERROR: $e — usando asset local");
      try {
        final wcResponse =
            await rootBundle.loadString('assets/data/wildcard.json');
        final wcDecoded = json.decode(wcResponse);
        final List<dynamic> wcData = wcDecoded is List ? wcDecoded : [];
        wildcards = wcData
            .cast<Map<String, dynamic>>()
            .where((w) => (w["woman_id"] ?? "").toString().isNotEmpty)
            .toList();
      } catch (e2) {
        wildcards = [];
      }
    }

    setState(() => initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFE1002D),
            ),
          ),
        ),
      );
    }

    final langProvider = context.watch<LanguageProvider>();

    final now = DateTime.now();
    final todayKey =
        "${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}";

    final todaysWomen =
        allWomen.where((w) => w["event_date"] == todayKey).toList();

    final suggestions = DailySuggestionsEngine.generateSuggestions(
      todaysWomen: todaysWomen,
      fullDataset: allWomen,
      locale: langProvider.locale,
      wildcards: wildcards,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: FutureBuilder<bool>(
        future: SharedPreferences.getInstance()
            .then((p) => p.getBool('onboarding_done') ?? false),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFE1002D),
                ),
              ),
            );
          }

          final done = snap.data!;

          if (done) {
            return LoginScreen(
              allWomen: allWomen,
              todaysWomen: todaysWomen,
              suggestions: suggestions,
              wildcards: wildcards,
            );
          }

          return OnboardingScreen(
            allWomen: allWomen,
            todaysWomen: todaysWomen,
            suggestions: suggestions,
            wildcards: wildcards,
          );
        },
      ),
    );
  }
}