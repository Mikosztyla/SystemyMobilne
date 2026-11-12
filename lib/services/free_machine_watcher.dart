import 'package:bursa_app/models/machine.dart';
import 'package:bursa_app/services/laundry_notifications.dart';

class FreeMachineWatcher {
  final LaundryNotifications _notifications;
  bool _waiting = false;
  DateTime? _alertAt;

  FreeMachineWatcher({LaundryNotifications? notifications})
    : _notifications = notifications ?? LaundryNotifications.instance;

  bool get isWaiting => _waiting;

  static Machine? nextToFree(List<Machine> machines, DateTime now) {
    Machine? best;
    for (final machine in machines) {
      if (machine.statusAt(now) != MachineStatus.busy) continue;
      final endsAt = machine.currentSession!.endsAt;
      if (best == null || endsAt.isBefore(best.currentSession!.endsAt)) {
        best = machine;
      }
    }
    return best;
  }

  Future<bool> restore(List<Machine> machines) async {
    if (_waiting) return false;
    final pending = await _notifications.hasPendingFreeMachineAlert();
    if (!pending || _waiting) return false;
    _waiting = true;
    update(machines);
    return true;
  }

  void start(List<Machine> machines) {
    if (_waiting) return;
    _waiting = true;
    update(machines);
  }

  void cancel() {
    if (!_waiting) return;
    _waiting = false;
    _alertAt = null;
    _notifications.cancelFreeMachineAlert();
  }

  void update(List<Machine> machines) {
    if (!_waiting) return;
    final now = DateTime.now();

    final free = machines
        .where((m) => m.statusAt(now) == MachineStatus.free)
        .firstOrNull;
    if (free != null) {
      _waiting = false;
      final alertAt = _alertAt;
      _alertAt = null;
      if (alertAt != null && !now.isBefore(alertAt)) return;
      _notifications.showFreeMachineNow(free.name);
      return;
    }

    final next = nextToFree(machines, now);
    final endsAt = next?.currentSession?.endsAt;
    if (next == null || endsAt == null) {
      if (_alertAt != null) _notifications.cancelFreeMachineAlert();
      _alertAt = null;
      return;
    }
    if (endsAt == _alertAt) return;
    _alertAt = endsAt;
    _notifications.scheduleFreeMachineAlert(machineName: next.name, at: endsAt);
  }
}
