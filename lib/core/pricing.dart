import 'dart:io';

class AppPricing {
  final String currencyCode;
  final String symbol;
  final int individualMonthly;
  final int individualAnnual;
  final int individualTrial;
  final int familyAnnual;

  const AppPricing({
    required this.currencyCode,
    required this.symbol,
    required this.individualMonthly,
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
      individualMonthly: 9900,
      individualAnnual:  9900,
      individualTrial:   16800,
      familyAnnual:      16500,
    ),
    'USD': AppPricing(
      currencyCode: 'USD',
      symbol: 'USD',
      individualMonthly: 10,
      individualAnnual:  10,
      individualTrial:   17,
      familyAnnual:      17,
    ),
    'EUR': AppPricing(
      currencyCode: 'EUR',
      symbol: 'EUR',
      individualMonthly: 9,
      individualAnnual:  9,
      individualTrial:   15,
      familyAnnual:      15,
    ),
    'MXN': AppPricing(
      currencyCode: 'MXN',
      symbol: 'MXN',
      individualMonthly: 199,
      individualAnnual:  199,
      individualTrial:   349,
      familyAnnual:      329,
    ),
    'ARS': AppPricing(
      currencyCode: 'ARS',
      symbol: 'ARS',
      individualMonthly: 9900,
      individualAnnual:  9900,
      individualTrial:   16800,
      familyAnnual:      16500,
    ),
  };

  static AppPricing fromLocale(String? override) {
    if (override != null && _table.containsKey(override)) {
      return _table[override]!;
    }
    try {
      final locale = Platform.localeName.toUpperCase();
      if (locale.contains('CL')) return _table['CLP']!;
      if (locale.contains('MX')) return _table['MXN']!;
      if (locale.contains('AR')) return _table['ARS']!;
      if (locale.contains('ES') || locale.contains('FR') ||
          locale.contains('DE') || locale.contains('IT') ||
          locale.contains('PT')) return _table['EUR']!;
    } catch (_) {}
    return _table['USD']!;
  }

  static List<String> get supportedCurrencies => _table.keys.toList();
}