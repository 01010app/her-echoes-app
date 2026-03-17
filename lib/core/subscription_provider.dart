import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionProvider extends ChangeNotifier {
  bool _isPro = false;

  bool get isPro => _isPro;

  void setIsPro(bool value) {
    if (_isPro == value) return;
    _isPro = value;
    notifyListeners();
  }

  Future<void> checkStatus() async {
    try {
      final info = await Purchases.getCustomerInfo();
      final active = info.entitlements.active.containsKey('pro');
      setIsPro(active);
    } catch (e) {
      print('RevenueCat checkStatus error: $e');
    }
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      final active = result.customerInfo.entitlements.active.containsKey('pro');
      setIsPro(active);
      return active;
    } catch (e) {
      print('RevenueCat purchasePackage error: $e');
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      final active = info.entitlements.active.containsKey('pro');
      setIsPro(active);
      return active;
    } catch (e) {
      print('RevenueCat restorePurchases error: $e');
      return false;
    }
  }
}