import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  static const _prefKey = 'currency_override';

  String _currency = 'CLP';

  String get currency => _currency;

  CurrencyProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null && AppPricing.supportedCurrencies.contains(saved)) {
      _currency = saved;
    } else {
      _currency = _detectFromLocale();
    }
    notifyListeners();
  }

  Future<void> setCurrency(String code) async {
    if (!AppPricing.supportedCurrencies.contains(code)) return;
    _currency = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, code);
  }

  Future<void> resetToAuto() async {
    _currency = _detectFromLocale();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  AppPricing get pricing => AppPricing.forCurrency(_currency);

  static String _detectFromLocale() {
    try {
      final locale = Platform.localeName.toUpperCase();
      if (locale.contains('CL')) return 'CLP';
      if (locale.contains('MX')) return 'MXN';
      if (locale.contains('AR')) return 'ARS';
      if (locale.contains('ES') || locale.contains('FR') ||
          locale.contains('DE') || locale.contains('IT') ||
          locale.contains('PT')) return 'EUR';
    } catch (_) {}
    return 'USD';
  }
}

class AppPricing {
  final String currencyCode;
  final String symbol;
  final int individualAnnual;
  final int individualTrial;
  final int familyAnnual;

  const AppPricing({
    required this.currencyCode,
    required this.symbol,
    required this.individualAnnual,
    required this.individualTrial,
    required this.familyAnnual,
  });

  String format(int amount) {
    final s = amount.toString();
    final result = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write('.');
      result.write(s[i]);
    }
    return '$symbol ${result.toString()}';
  }

  static const Map<String, AppPricing> _table = {
    'CLP': AppPricing(
      currencyCode: 'CLP',
      symbol: 'CLP',
      individualAnnual: 9900,
      individualTrial:  16800,
      familyAnnual:     16500,
    ),
    'USD': AppPricing(
      currencyCode: 'USD',
      symbol: 'USD',
      individualAnnual: 10,
      individualTrial:  17,
      familyAnnual:     17,
    ),
    'EUR': AppPricing(
      currencyCode: 'EUR',
      symbol: 'EUR',
      individualAnnual: 9,
      individualTrial:  15,
      familyAnnual:     15,
    ),
    'MXN': AppPricing(
      currencyCode: 'MXN',
      symbol: 'MXN',
      individualAnnual: 199,
      individualTrial:  349,
      familyAnnual:     329,
    ),
    'ARS': AppPricing(
      currencyCode: 'ARS',
      symbol: 'ARS',
      individualAnnual: 9900,
      individualTrial:  16800,
      familyAnnual:     16500,
    ),
  };

  static AppPricing forCurrency(String code) =>
      _table[code] ?? _table['USD']!;

  static List<String> get supportedCurrencies => _table.keys.toList();
}