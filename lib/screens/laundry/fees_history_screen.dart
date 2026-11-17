import 'package:bursa_app/models/laundry_session.dart';
import 'package:bursa_app/screens/laundry/fees_card.dart';
import 'package:bursa_app/screens/laundry/laundry_format.dart';
import 'package:bursa_app/services/laundry_fees.dart';
import 'package:bursa_app/services/laundry_store.dart';
import 'package:bursa_app/widgets/settings_group.dart';
import 'package:material_ui/material_ui.dart';

class FeesHistoryScreen extends StatelessWidget {
  final LaundryStore store;

  const FeesHistoryScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Moje opłaty")),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final months = LaundryFees.byMonth(store.mySessions);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              FeesCard(store: store),
              if (months.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    "Nie masz jeszcze żadnych prań.",
                    textAlign: TextAlign.center,
                  ),
                ),
              for (final entry in months.entries) ...[
                const SizedBox(height: 20),
                _MonthHeader(
                  month: entry.key,
                  totalGrosze: LaundryFees.totalGrosze(entry.value),
                ),
                const SizedBox(height: 8),
                SettingsGroup(
                  children: [
                    for (final session in entry.value)
                      _SessionTile(session: session),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime month;
  final int totalGrosze;

  const _MonthHeader({required this.month, required this.totalGrosze});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final style = textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: colorScheme.onSurfaceVariant,
    );

    return Row(
      children: [
        Expanded(
          child: Text(
            LaundryFormat.monthYear(month).toUpperCase(),
            style: style,
          ),
        ),
        Text(LaundryFormat.money(totalGrosze), style: style),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  final LaundrySession session;

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: const Icon(Icons.local_laundry_service),
      title: Text(
        session.machineName,
        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        "${LaundryFormat.shortDate(session.startedAt)}, "
        "${LaundryFormat.time(session.startedAt)} · "
        "${LaundryFormat.duration(session.durationMinutes)}",
      ),
      trailing: Text(
        LaundryFormat.money(session.costGrosze),
        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
