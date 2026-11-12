import 'package:bursa_app/models/laundry_session.dart';
import 'package:bursa_app/screens/laundry/fees_card.dart';
import 'package:bursa_app/screens/laundry/laundry_colors.dart';
import 'package:bursa_app/screens/laundry/laundry_format.dart';
import 'package:bursa_app/services/laundry_store.dart';
import 'package:material_ui/material_ui.dart';

class FeesHistoryScreen extends StatelessWidget {
  const FeesHistoryScreen({super.key, required this.store});

  final LaundryStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moje opłaty')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final months = store.sessionsByMonth;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              FeesCard(store: store),
              if (months.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Nie masz jeszcze żadnych prań.',
                    textAlign: TextAlign.center,
                  ),
                ),
              for (final entry in months.entries) ...[
                const SizedBox(height: 20),
                _MonthHeader(
                  month: entry.key,
                  totalGrosze: store.totalGrosze(entry.value),
                ),
                const SizedBox(height: 8),
                _SessionList(sessions: entry.value),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.month, required this.totalGrosze});

  final DateTime month;
  final int totalGrosze;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: LaundryColors.muted,
      letterSpacing: 0.5,
    );
    return Row(
      children: [
        Expanded(
          child: Text(LaundryFormat.monthYear(month).toUpperCase(), style: style),
        ),
        Text(LaundryFormat.money(totalGrosze), style: style),
      ],
    );
  }
}

class _SessionList extends StatelessWidget {
  const _SessionList({required this.sessions});

  final List<LaundrySession> sessions;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LaundryColors.card,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          for (var i = 0; i < sessions.length; i++) ...[
            if (i != 0) const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.local_laundry_service),
              title: Text(
                sessions[i].machineName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${LaundryFormat.shortDate(sessions[i].startedAt)}, '
                '${LaundryFormat.time(sessions[i].startedAt)} · '
                '${LaundryFormat.duration(sessions[i].durationMinutes)}',
              ),
              trailing: Text(
                LaundryFormat.money(sessions[i].costGrosze),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
