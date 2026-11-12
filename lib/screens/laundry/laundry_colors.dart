import 'package:bursa_app/models/machine.dart';
import 'package:material_ui/material_ui.dart';

abstract final class LaundryColors {
  static const card = Color(0xFFF7F2EC);
  static const muted = Color(0xFF5A534B);

  static const freeBg = Color(0xFFD3EEDC);
  static const freeFg = Color(0xFF1B6E3F);
  static const busyBg = Color(0xFFDCE6F7);
  static const busyFg = Color(0xFF2B5C99);
  static const faultBg = Color(0xFFF9DEDC);
  static const faultFg = Color(0xFFB3261E);

  static const fees = Color(0xFFEFE6DA);
  static const feesFg = Color(0xFF3A2F22);
  static const feesDivider = Color(0xFFDCD0C0);

  static (Color, Color) forStatus(MachineStatus status) => switch (status) {
    MachineStatus.free => (freeBg, freeFg),
    MachineStatus.busy => (busyBg, busyFg),
    MachineStatus.outOfOrder => (faultBg, faultFg),
  };
}
