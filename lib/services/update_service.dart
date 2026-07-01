import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/system/app_button.dart';

class UpdateService {
  static const _bundleId = 'cl.callmehector.herechoes';
  static const _appStoreId = '6760677188';

  static Future<void> checkAndPrompt(BuildContext context, {required bool isEnglish}) async {
    if (!Platform.isIOS) return;

    try {
      final info = await PackageInfo.fromPlatform();
      final installedVersion = info.version;

      final res = await http
          .get(Uri.parse('https://itunes.apple.com/lookup?bundleId=$_bundleId'))
          .timeout(const Duration(seconds: 5));

      if (res.statusCode != 200) return;

      final data = json.decode(res.body);
      final results = data['results'] as List?;
      if (results == null || results.isEmpty) return;

      final storeVersion = results[0]['version'] as String?;
      if (storeVersion == null) return;

      if (_isNewer(storeVersion, installedVersion)) {
        if (!context.mounted) return;
        _showDialog(context, storeVersion, isEnglish);
      }
    } catch (e) {
      debugPrint('[UpdateService] Error: $e');
    }
  }

  static bool _isNewer(String storeVersion, String installedVersion) {
    final store = storeVersion.split('.').map(int.tryParse).toList();
    final installed = installedVersion.split('.').map(int.tryParse).toList();

    final maxLen = store.length > installed.length ? store.length : installed.length;
    for (int i = 0; i < maxLen; i++) {
      final s = i < store.length ? (store[i] ?? 0) : 0;
      final v = i < installed.length ? (installed[i] ?? 0) : 0;
      if (s > v) return true;
      if (s < v) return false;
    }
    return false;
  }

  static void _showDialog(BuildContext context, String newVersion, bool isEnglish) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE5EA),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🚀', style: TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEnglish ? 'New version available' : 'Nueva versión disponible',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isEnglish
                  ? 'Version $newVersion is now available with improvements and new content. Update now for the best experience.'
                  : 'La versión $newVersion ya está disponible con mejoras y contenido nuevo. Actualiza ahora para la mejor experiencia.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14, color: Color(0xFF777777), height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: isEnglish ? 'Update now' : 'Actualizar ahora',
              onPressed: () => _openAppStore(),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                isEnglish ? 'Later' : 'Más tarde',
                style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500,
                  color: Color(0xFF888888),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _openAppStore() async {
    // Reemplaza APP_STORE_ID con tu ID numérico de App Store
    final url = Uri.parse('https://apps.apple.com/app/id$_appStoreId');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}