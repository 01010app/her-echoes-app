import 'package:flutter/material.dart';

class SubscriptionProvider extends ChangeNotifier {
  bool _isPro = false;

  bool get isPro => _isPro;

  void setIsPro(bool value) {
    if (_isPro == value) return;
    _isPro = value;
    notifyListeners();
  }
}