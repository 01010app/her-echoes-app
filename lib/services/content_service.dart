import 'dart:convert';
import 'package:flutter/services.dart';

class ContentService {
  static Future<Map<String, dynamic>> loadLegalContent() async {
    final jsonString =
        await rootBundle.loadString('assets/content/legal_content.json');

    return json.decode(jsonString);
  }
}