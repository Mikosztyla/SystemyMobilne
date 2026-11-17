import 'package:bursa_app/theme/status_colors.dart';
import 'package:material_ui/material_ui.dart';

class WashProgressBar extends StatelessWidget {
  final double value;

  const WashProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final statusColors = StatusColors.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 6,
        backgroundColor: statusColors.busy,
        color: statusColors.onBusy,
      ),
    );
  }
}
