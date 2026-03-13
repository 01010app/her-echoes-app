import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _favorites = [];
  static const _key = 'favorites_list';

  FavoritesProvider() {
    _load();
  }

  List<Map<String, dynamic>> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(String womanId) {
    return _favorites.any((w) => w['woman_id'].toString() == womanId);
  }

  Future<void> toggle(Map<String, dynamic> woman) async {
    final id = woman['woman_id'].toString();
    if (isFavorite(id)) {
      _favorites.removeWhere((w) => w['woman_id'].toString() == id);
    } else {
      _favorites.add(woman);
    }
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_favorites);
    await prefs.setString(_key, encoded);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final List<dynamic> decoded = jsonDecode(raw);
      _favorites.clear();
      _favorites.addAll(decoded.cast<Map<String, dynamic>>());
      notifyListeners();
    }
  }
}