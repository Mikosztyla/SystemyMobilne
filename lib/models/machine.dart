import 'package:bursa_app/models/current_session.dart';

enum MachineStatus { free, busy, outOfOrder }

class Machine {
  final String id;
  final String name;
  final String place;
  final String qrCode;
  final int priceGrosze;
  final bool outOfOrder;
  final CurrentSession? currentSession;

  const Machine({
    required this.id,
    required this.name,
    required this.place,
    required this.qrCode,
    required this.priceGrosze,
    required this.outOfOrder,
    this.currentSession,
  });

  factory Machine.fromMap(String id, Map<String, dynamic> data) {
    final session = data[MachineFields.currentSession];
    return Machine(
      id: id,
      name: data[MachineFields.name] as String,
      place: data[MachineFields.place] as String,
      qrCode: data[MachineFields.qrCode] as String,
      priceGrosze: (data[MachineFields.priceGrosze] as num).toInt(),
      outOfOrder: data[MachineFields.outOfOrder] as bool,
      currentSession: session is Map
          ? CurrentSession.fromMap(Map<String, dynamic>.from(session))
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    MachineFields.name: name,
    MachineFields.place: place,
    MachineFields.qrCode: qrCode,
    MachineFields.priceGrosze: priceGrosze,
    MachineFields.outOfOrder: outOfOrder,
    MachineFields.currentSession: currentSession?.toMap(),
  };

  bool isBusyAt(DateTime now) =>
      currentSession != null && currentSession!.endsAt.isAfter(now);

  MachineStatus statusAt(DateTime now) {
    if (outOfOrder) return MachineStatus.outOfOrder;
    return isBusyAt(now) ? MachineStatus.busy : MachineStatus.free;
  }

  bool isUsedBy(String? uid, DateTime now) =>
      uid != null && isBusyAt(now) && currentSession!.userId == uid;
}

abstract final class MachineFields {
  static const collection = 'machines';
  static const name = 'name';
  static const place = 'place';
  static const qrCode = 'qrCode';
  static const priceGrosze = 'priceGrosze';
  static const outOfOrder = 'outOfOrder';
  static const currentSession = 'currentSession';
}
