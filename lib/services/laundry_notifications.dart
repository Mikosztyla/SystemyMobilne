import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

typedef WashReminder = ({String machineName, DateTime endsAt});

class LaundryNotifications {
  LaundryNotifications._();

  static final LaundryNotifications instance = LaundryNotifications._();

  static const warningBefore = Duration(minutes: 5);

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'laundry',
      'Pranie',
      channelDescription: 'Przypomnienia o końcu prania',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
    ),
    iOS: DarwinNotificationDetails(),
  );

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  final Map<String, DateTime> _scheduled = {};
  bool _initialized = false;
  bool _permissionAsked = false;
  Future<void> _queue = Future.value();

  Future<void> sync(Map<String, WashReminder> washes, {required bool enabled}) {
    final wanted = enabled ? Map.of(washes) : <String, WashReminder>{};
    _queue = _queue.then((_) => _sync(wanted)).catchError((Object e) {
      debugPrint('LaundryNotifications: $e');
    });
    return _queue;
  }

  Future<void> cancelAll() {
    sync(const {}, enabled: false);
    return cancelFreeMachineAlert();
  }

  static const _freeMachineId = 0x40000000;

  Future<void> scheduleFreeMachineAlert({
    required String machineName,
    required DateTime at,
  }) => _enqueue(() async {
    await _initialize();
    await _askForPermissionOnce();
    await _schedule(
      id: _freeMachineId,
      at: at,
      title: 'Pralka się zwolniła',
      body: '$machineName jest wolna – możesz zacząć pranie.',
    );
  });

  Future<void> showFreeMachineNow(String machineName) => _enqueue(() async {
    await _initialize();
    await _plugin.cancel(id: _freeMachineId);
    await _plugin.show(
      id: _freeMachineId,
      title: 'Pralka się zwolniła',
      body: '$machineName jest wolna – możesz zacząć pranie.',
      notificationDetails: _details,
    );
  });

  Future<void> cancelFreeMachineAlert() => _enqueue(() async {
    await _initialize();
    await _plugin.cancel(id: _freeMachineId);
  });

  Future<bool> hasPendingFreeMachineAlert() async {
    await _queue;
    await _initialize();
    final pending = await _plugin.pendingNotificationRequests();
    return pending.any((request) => request.id == _freeMachineId);
  }

  Future<void> _enqueue(Future<void> Function() action) {
    _queue = _queue.then((_) => action()).catchError((Object e) {
      debugPrint('LaundryNotifications: $e');
    });
    return _queue;
  }

  Future<void> _sync(Map<String, WashReminder> wanted) async {
    await _initialize();

    final now = DateTime.now();
    final gone = _scheduled.keys.where((id) => !wanted.containsKey(id)).toList();
    for (final sessionId in gone) {
      final endsAt = _scheduled.remove(sessionId)!;
      if (endsAt.isAfter(now)) {
        final ids = _idsFor(sessionId);
        await _plugin.cancel(id: ids.warning);
        await _plugin.cancel(id: ids.end);
      }
    }

    for (final MapEntry(key: sessionId, value: wash) in wanted.entries) {
      if (_scheduled.containsKey(sessionId)) continue;
      if (!wash.endsAt.isAfter(DateTime.now())) continue;
      await _askForPermissionOnce();

      final ids = _idsFor(sessionId);
      await _schedule(
        id: ids.warning,
        at: wash.endsAt.subtract(warningBefore),
        title: 'Za 5 minut koniec prania',
        body: '${wash.machineName} – przygotuj się do odebrania prania.',
      );
      await _schedule(
        id: ids.end,
        at: wash.endsAt,
        title: 'Pranie skończone',
        body: '${wash.machineName} – możesz odebrać pranie.',
      );
      _scheduled[sessionId] = wash.endsAt;
    }
  }

  Future<void> _initialize() async {
    if (_initialized) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  Future<void> _askForPermissionOnce() async {
    if (_permissionAsked) return;
    _permissionAsked = true;
    await _android?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, sound: true);
  }

  Future<void> _schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  }) async {
    if (!at.isAfter(DateTime.now())) return;
    final exact = await _android?.canScheduleExactNotifications() ?? false;
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
      notificationDetails: _details,
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  ({int warning, int end}) _idsFor(String sessionId) {
    final base = sessionId.hashCode & 0x3FFFFFFE;
    return (warning: base, end: base + 1);
  }
}
