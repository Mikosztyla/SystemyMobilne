import 'package:bursa_app/models/machine.dart';
import 'package:bursa_app/theme/status_colors.dart';
import 'package:material_ui/material_ui.dart';

extension MachineStatusColors on MachineStatus {
  (Color, Color) colors(BuildContext context) {
    final statusColors = StatusColors.of(context);
    return switch (this) {
      MachineStatus.free => (statusColors.free, statusColors.onFree),
      MachineStatus.busy => (statusColors.busy, statusColors.onBusy),
      MachineStatus.outOfOrder => (
        statusColors.outOfOrder,
        statusColors.onOutOfOrder,
      ),
    };
  }
}
