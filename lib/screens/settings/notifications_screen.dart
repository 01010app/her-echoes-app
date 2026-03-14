import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../../core/language_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/settings/settings_list_container.dart';

final FlutterLocalNotificationsPlugin _notificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _notificationsEnabled = false;
  static const _prefKey = 'notifications_enabled';
  static const _notifId = 42;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _notificationsPlugin.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
    );

    final prefs = await SharedPreferences.getInstance();
    setState(() => _notificationsEnabled = prefs.getBool(_prefKey) ?? false);
  }

  Future<void> _toggle(bool isEnglish) async {
    final newValue = !_notificationsEnabled;

    if (newValue) {
      final granted = await _requestPermission();
      if (!granted) return;
      await _scheduleDaily(isEnglish);
    } else {
      await _notificationsPlugin.cancel(_notifId);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, newValue);
    setState(() => _notificationsEnabled = newValue);
  }

  Future<bool> _requestPermission() async {
    final plugin = _notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (plugin == null) return true;
    final granted = await plugin.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return granted ?? true;
  }

  Future<void> _scheduleDaily(bool isEnglish) async {
    await _notificationsPlugin.cancel(_notifId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, 9, 0);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      _notifId,
      isEnglish
          ? "Today's inspiring woman 🌟"
          : "La mujer inspiradora de hoy 🌟",
      isEnglish
          ? "Discover who made history on this day."
          : "Descubre quién hizo historia este día.",
      scheduled,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          'herechoes_daily',
          'Daily Echo',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isEnglish = context.watch<LanguageProvider>().isEnglish;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(height: topPadding, color: Colors.white),
          Container(
            height: 48,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: PhosphorIcon(
                        PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold),
                        size: 20,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Center(
                    child: Text(
                      isEnglish ? "Notifications" : "Notificaciones",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        letterSpacing: -0.5,
                        color: const Color(0xFF404040),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SettingsListContainer(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 16, bottom: 16, right: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEnglish
                                    ? "Daily reminder"
                                    : "Recordatorio diario",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                  letterSpacing: -0.5,
                                  color: const Color(0xFF404040),
                                ),
                              ),
                              Text(
                                isEnglish
                                    ? "Every day at 9:00 AM"
                                    : "Todos los días a las 9:00 AM",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF888888),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _toggle(isEnglish),
                          child: PhosphorIcon(
                            _notificationsEnabled
                                ? PhosphorIcons.toggleRight(
                                    PhosphorIconsStyle.fill)
                                : PhosphorIcons.toggleLeft(
                                    PhosphorIconsStyle.fill),
                            size: 36,
                            color: _notificationsEnabled
                                ? const Color(0xFFF70F3D)
                                : const Color(0xFF949494),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}