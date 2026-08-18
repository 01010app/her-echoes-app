import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/language_provider.dart';
import 'core/subscription_provider.dart';
import 'core/favorites_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/login/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/daily_suggestions_engine.dart';
import 'core/currency_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _initRevenueCat();

  // FIX: sin esto, la app solo se enteraba de compras/canjes de offer codes
  // al llamar checkStatus() manualmente (ej. "Restaurar compras"). El listener
  // hace que cualquier cambio de RevenueCat (compra, renovación, canje de
  // código promocional) desbloquee el contenido PRO en tiempo real.
  final subscriptionProvider = SubscriptionProvider();
  subscriptionProvider.startListening();
  await subscriptionProvider.checkStatus();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider.value(value: subscriptionProvider),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _initRevenueCat() async {
  await Purchases.setLogLevel(LogLevel.debug);
  PurchasesConfiguration config;
  if (Platform.isIOS) {
    config = PurchasesConfiguration('appl_KDuVwOmljiRmgUegeqjadtfAjRA');
  } else if (Platform.isAndroid) {
    config = PurchasesConfiguration('goog_chSzVTtDJfNcfIfRHepJqITjste');
  } else {
    return;
  }
  await Purchases.configure(config);
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

  // MIGRACIÓN sesión 29: her_echoes.json ahora se descarga desde GitHub en
  // vez de venir empaquetado en el build. Esto permite corregir/agregar
  // contenido sin subir nueva versión a App Store. Se mantiene una copia en
  // caché local (SharedPreferences) para que la app funcione offline, y el
  // asset local sigue existiendo solo como último respaldo de emergencia.
  static const _womenUrl =
      'https://raw.githubusercontent.com/01010app/her-echoes-app/main/assets/data/her_echoes.json';
  static const _womenCacheKey = 'her_echoes_cache_v1';

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  List<Map<String, dynamic>> _parseWomenList(dynamic decoded) {
    final List<dynamic> data =
        decoded is List ? decoded : decoded["data"] ?? [];
    return data
        .cast<Map<String, dynamic>>()
        .where((w) => (w["woman_id"] ?? "").toString().isNotEmpty)
        .toList();
  }

  Future<void> loadJson() async {
    final prefs = await SharedPreferences.getInstance();

    // 1) Intentar descargar la versión más reciente desde GitHub.
    try {
      final res = await http
          .get(Uri.parse(_womenUrl))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');

      final decoded = json.decode(utf8.decode(res.bodyBytes));
      allWomen = _parseWomenList(decoded);

      // Guardar en caché para uso offline futuro.
      await prefs.setString(_womenCacheKey, res.body);
    } catch (e) {
      print("her_echoes.json GitHub ERROR: $e — usando caché/asset local");

      // 2) Sin internet o GitHub caído: usar la última copia cacheada.
      final cached = prefs.getString(_womenCacheKey);
      if (cached != null) {
        try {
          allWomen = _parseWomenList(json.decode(cached));
        } catch (e2) {
          allWomen = [];
        }
      }

      // 3) Sin caché (primera apertura sin internet): usar asset local
      // empaquetado como último respaldo de emergencia.
      if (allWomen.isEmpty) {
        try {
          final response =
              await rootBundle.loadString('assets/data/her_echoes.json');
          allWomen = _parseWomenList(json.decode(response));
        } catch (e3) {
          print("her_echoes.json ASSET ERROR: $e3");
          allWomen = [];
        }
      }
    }

    try {
      final res = await http
          .get(Uri.parse(_wildcardUrl))
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
    // FIX: el dataset usa formato MM/DD (ej. "07/01" = 1 de julio), no DD/MM.
    // Antes esta clave se armaba como DD/MM y nunca hacía match con event_date,
    // dejando todaysWomen vacío y cayendo al fallback (contenido random, sin libres).
    final todayKey =
        "${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}";

    final todaysWomen =
        allWomen.where((w) => w["event_date"] == todayKey).toList();

    // IDs desbloqueados para usuarios free: solo la mujer del día con is_free == "VERDADERO"
    final todaysFreeIds = todaysWomen
        .where((w) => w['is_free'] == 'VERDADERO')
        .map((w) => (w['woman_id'] ?? '').toString())
        .toSet();

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
      home: FutureBuilder<Map<String, bool>>(
        // FIX sesión 28: antes solo se leía 'onboarding_done', así que
        // cualquier usuario (invitado o logueado) siempre caía en LoginScreen
        // al reabrir la app, porque nunca se guardaba que ya había una sesión
        // activa. Ahora se lee también 'session_active'.
        future: SharedPreferences.getInstance().then((p) => {
              'onboarding_done': p.getBool('onboarding_done') ?? false,
              'session_active': p.getBool('session_active') ?? false,
            }),
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

          final onboardingDone = snap.data!['onboarding_done']!;
          final sessionActive = snap.data!['session_active']!;

          if (!onboardingDone) {
            return OnboardingScreen(
              allWomen: allWomen,
              todaysWomen: todaysWomen,
              todaysFreeIds: todaysFreeIds,
              suggestions: suggestions,
              wildcards: wildcards,
            );
          }

          if (sessionActive) {
            return HomeScreen(
              allWomen: allWomen,
              todaysWomen: todaysWomen,
              todaysFreeIds: todaysFreeIds,
              suggestions: suggestions,
              wildcards: wildcards,
            );
          }

          return LoginScreen(
            allWomen: allWomen,
            todaysWomen: todaysWomen,
            todaysFreeIds: todaysFreeIds,
            suggestions: suggestions,
            wildcards: wildcards,
          );
        },
      ),
    );
  }
}