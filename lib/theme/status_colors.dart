import 'package:material_ui/material_ui.dart';

class StatusColors extends ThemeExtension<StatusColors> {
  final Color free;
  final Color onFree;
  final Color busy;
  final Color onBusy;
  final Color outOfOrder;
  final Color onOutOfOrder;

  const StatusColors({
    required this.free,
    required this.onFree,
    required this.busy,
    required this.onBusy,
    required this.outOfOrder,
    required this.onOutOfOrder,
  });

  static const light = StatusColors(
    free: Color(0xFFD3EEDC),
    onFree: Color(0xFF1B6E3F),
    busy: Color(0xFFDCE6F7),
    onBusy: Color(0xFF2B5C99),
    outOfOrder: Color(0xFFF9DEDC),
    onOutOfOrder: Color(0xFFB3261E),
  );

  static StatusColors of(BuildContext context) {
    return Theme.of(context).extension<StatusColors>() ?? light;
  }

  @override
  StatusColors copyWith({
    Color? free,
    Color? onFree,
    Color? busy,
    Color? onBusy,
    Color? outOfOrder,
    Color? onOutOfOrder,
  }) {
    return StatusColors(
      free: free ?? this.free,
      onFree: onFree ?? this.onFree,
      busy: busy ?? this.busy,
      onBusy: onBusy ?? this.onBusy,
      outOfOrder: outOfOrder ?? this.outOfOrder,
      onOutOfOrder: onOutOfOrder ?? this.onOutOfOrder,
    );
  }

  @override
  StatusColors lerp(StatusColors? other, double t) {
    if (other == null) return this;
    return StatusColors(
      free: Color.lerp(free, other.free, t)!,
      onFree: Color.lerp(onFree, other.onFree, t)!,
      busy: Color.lerp(busy, other.busy, t)!,
      onBusy: Color.lerp(onBusy, other.onBusy, t)!,
      outOfOrder: Color.lerp(outOfOrder, other.outOfOrder, t)!,
      onOutOfOrder: Color.lerp(onOutOfOrder, other.onOutOfOrder, t)!,
    );
  }
}
