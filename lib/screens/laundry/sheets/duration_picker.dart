import 'package:bursa_app/screens/laundry/laundry_format.dart';
import 'package:material_ui/material_ui.dart';

class DurationPicker extends StatelessWidget {
  static const presets = [30, 45, 60, 90, 120];
  static const minMinutes = 5;
  static const maxMinutes = 300;

  final int minutes;
  final ValueChanged<int> onChanged;

  const DurationPicker({
    super.key,
    required this.minutes,
    required this.onChanged,
  });

  void _change(int delta) {
    onChanged((minutes + delta).clamp(minMinutes, maxMinutes).toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSteppers(context),
        const SizedBox(height: 16),
        _buildPresets(context),
      ],
    );
  }

  Widget _buildSteppers(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final end = DateTime.now().add(Duration(minutes: minutes));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TimeStepper(
                value: "${minutes ~/ 60}",
                label: "godz.",
                onUp: () => _change(60),
                onDown: () => _change(-60),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  ":",
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _TimeStepper(
                value: (minutes % 60).toString().padLeft(2, "0"),
                label: "min",
                onUp: () => _change(5),
                onDown: () => _change(-5),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "koniec ok. ${LaundryFormat.time(end)}",
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresets(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        for (final preset in presets)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: OutlinedButton(
                onPressed: () => onChanged(preset),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: preset == minutes
                      ? colorScheme.primaryContainer
                      : null,
                ),
                child: Text(
                  LaundryFormat.duration(preset).replaceAll(" h", ""),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TimeStepper extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback onUp;
  final VoidCallback onDown;

  const _TimeStepper({
    required this.value,
    required this.label,
    required this.onUp,
    required this.onDown,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 96,
      child: Column(
        children: [
          IconButton.filledTonal(
            onPressed: onUp,
            icon: const Icon(Icons.keyboard_arrow_up),
          ),
          Text(
            value,
            style: textTheme.displaySmall?.copyWith(
              fontSize: 44,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton.filledTonal(
            onPressed: onDown,
            icon: const Icon(Icons.keyboard_arrow_down),
          ),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
