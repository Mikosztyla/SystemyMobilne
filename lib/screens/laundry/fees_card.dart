import 'package:bursa_app/screens/laundry/laundry_colors.dart';
import 'package:bursa_app/screens/laundry/laundry_format.dart';
import 'package:bursa_app/services/laundry_store.dart';
import 'package:material_ui/material_ui.dart';

class FeesCard extends StatelessWidget {
  const FeesCard({super.key, required this.store, this.onOpenHistory});

  final LaundryStore store;
  final VoidCallback? onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final sessions = store.sessionsInMonth(store.now);
    final fee = store.nextFeeCollection;
    final label = onOpenHistory == null
        ? 'Do zapłaty · ${LaundryFormat.month(store.now)}'
        : 'Do zapłaty';

    return Material(
      color: LaundryColors.fees,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onOpenHistory,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: LaundryColors.feesFg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: const TextStyle(fontSize: 13)),
                          Text(
                            LaundryFormat.money(store.totalGrosze(sessions)),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Liczba prań', style: TextStyle(fontSize: 13)),
                        Text(
                          '${sessions.length}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (fee != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.event,
                        size: 18,
                        color: LaundryColors.feesFg,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Zbiórka opłat: ${_feeText(fee)}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
                if (onOpenHistory != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: LaundryColors.feesDivider),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 20,
                        color: LaundryColors.feesFg,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Historia prań i rozliczenie',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: LaundryColors.feesFg),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _feeText(FeeCollection fee) {
    final start = '${LaundryFormat.shortDate(fee.start)}, ${LaundryFormat.time(fee.start)}';
    return fee.end == null ? start : '$start–${LaundryFormat.time(fee.end!)}';
  }
}
