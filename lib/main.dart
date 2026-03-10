import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'dart:convert';

import 'core/language_provider.dart';
import 'core/subscription_provider.dart';
import 'core/favorites_provider.dart';
import 'screens/home/home_screen.dart';
import 'services/daily_suggestions_engine.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
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
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    try {
      final response = await rootBundle.loadString('assets/data/her_echoes.json');
      final decoded = json.decode(response);
      final List<dynamic> data = decoded is List ? decoded : decoded["data"] ?? [];
      allWomen = data
          .cast<Map<String, dynamic>>()
          .where((w) => (w["woman_id"] ?? "").toString().isNotEmpty)
          .toList();
    } catch (e) {
      print("JSON ERROR: $e");
      allWomen = [];
    }
    setState(() => initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
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
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: HomeScreen(
        suggestions: suggestions,
        allWomen: allWomen,
        todaysWomen: todaysWomen,
      ),
    );
  }
}