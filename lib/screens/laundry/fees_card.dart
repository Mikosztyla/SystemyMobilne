import 'package:bursa_app/screens/laundry/laundry_format.dart';
import 'package:bursa_app/services/laundry_fees.dart';
import 'package:bursa_app/services/laundry_repository.dart';
import 'package:bursa_app/services/laundry_store.dart';
import 'package:material_ui/material_ui.dart';

class FeesCard extends StatelessWidget {
  final LaundryStore store;
  final VoidCallback? onOpenHistory;

  const FeesCard({super.key, required this.store, this.onOpenHistory});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fee = store.nextFeeCollection;

    return Material(
      color: colorScheme.secondaryContainer,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onOpenHistory,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummary(context),
              if (fee != null) ...[
                const SizedBox(height: 12),
                _buildFeeCollection(context, fee),
              ],
              if (onOpenHistory != null) ...[
                const SizedBox(height: 12),
                Divider(height: 1, color: colorScheme.outlineVariant),
                const SizedBox(height: 10),
                _buildHistoryLink(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sessions = LaundryFees.inMonth(store.mySessions, store.now);
    final label = onOpenHistory == null
        ? "Do zapłaty · ${LaundryFormat.month(store.now)}"
        : "Do zapłaty";
    final labelStyle = textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSecondaryContainer,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: labelStyle),
              Text(
                LaundryFormat.money(LaundryFees.totalGrosze(sessions)),
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("Liczba prań", style: labelStyle),
            Text(
              "${sessions.length}",
              style: textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeeCollection(BuildContext context, FeeCollection fee) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(Icons.event, size: 18, color: colorScheme.onSecondaryContainer),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            "Zbiórka opłat: ${_feeText(fee)}",
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryLink(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(
          Icons.receipt_long,
          size: 20,
          color: colorScheme.onSecondaryContainer,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "Historia prań i rozliczenie",
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ),
        Icon(Icons.chevron_right, color: colorScheme.onSecondaryContainer),
      ],
    );
  }

  String _feeText(FeeCollection fee) {
    final start =
        "${LaundryFormat.shortDate(fee.start)}, ${LaundryFormat.time(fee.start)}";
    return fee.end == null ? start : "$start–${LaundryFormat.time(fee.end!)}";
  }
}
