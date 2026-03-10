import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isEnglish = false;

  bool get isEnglish => _isEnglish;
  String get locale => _isEnglish ? 'en' : 'es';

  void setEnglish(bool value) {
    if (_isEnglish == value) return;
    _isEnglish = value;
    notifyListeners();
  }
}