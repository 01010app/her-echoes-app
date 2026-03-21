import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionProvider extends ChangeNotifier {
  bool _isPro = false;
  bool _isPurchasing = false;
  Package? _activePackage;

  bool get isPro => _isPro;
  bool get isPurchasing => _isPurchasing;
  Package? get activePackage => _activePackage;

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
      debugPrint('RevenueCat checkStatus error: $e');
    }
  }

  Future<bool> purchasePackage(Package package) async {
    _isPurchasing = true;
    notifyListeners();
    try {
      final result = await Purchases.purchasePackage(package);
      final active = result.customerInfo.entitlements.active.containsKey('pro');
      _isPro = active;
      if (active) _activePackage = package;
      return active;
    } catch (e) {
      debugPrint('RevenueCat purchasePackage error: $e');
      return false;
    } finally {
      _isPurchasing = false;
      notifyListeners();
    }
  }

  Future<bool> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      final active = info.entitlements.active.containsKey('pro');
      setIsPro(active);
      return active;
    } catch (e) {
      debugPrint('RevenueCat restorePurchases error: $e');
      return false;
    }
  }
}