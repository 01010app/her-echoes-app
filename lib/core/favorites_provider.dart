import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _favorites = [];

  List<Map<String, dynamic>> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(String womanId) {
    return _favorites.any((w) => w['woman_id'].toString() == womanId);
  }

  void toggle(Map<String, dynamic> woman) {
    final id = woman['woman_id'].toString();
    if (isFavorite(id)) {
      _favorites.removeWhere((w) => w['woman_id'].toString() == id);
    } else {
      _favorites.add(woman);
    }
    notifyListeners();
  }
}