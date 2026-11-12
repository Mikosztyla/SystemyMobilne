import 'package:bursa_app/models/machine.dart';
import 'package:bursa_app/screens/laundry/laundry_colors.dart';
import 'package:bursa_app/screens/laundry/sheets/laundry_sheet.dart';
import 'package:bursa_app/screens/laundry/sheets/notice_box.dart';
import 'package:bursa_app/screens/laundry/sheets/sheet_button.dart';
import 'package:bursa_app/screens/laundry/sheets/sheet_header.dart';
import 'package:bursa_app/screens/laundry/status_chip.dart';
import 'package:material_ui/material_ui.dart';

import '../laundry_format.dart';

Future<bool?> showBusyMachineSheet(BuildContext context, {required Machine machine}) {
  final now = DateTime.now();
  final session = machine.currentSession!;
  return showLaundrySheet<bool>(
    context,
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetHeader(
          overline: 'Kod ${machine.qrCode} rozpoznany',
          title: machine.name,
          background: LaundryColors.busyBg,
          foreground: LaundryColors.busyFg,
          trailing: StatusChip(
            status: MachineStatus.busy,
            busyUntil: session.endsAt,
            short: true,
          ),
        ),
        const SizedBox(height: 20),
        NoticeBox(
          icon: Icons.info_outline,
          text:
              'Według aplikacji ta pralka pierze jeszcze ok. '
              '${LaundryFormat.remaining(session.remainingAt(now))}. '
              'Jeśli jest już pusta, możesz rozpocząć swoje pranie.',
          background: LaundryColors.busyBg,
          foreground: LaundryColors.busyFg,
        ),
        const SizedBox(height: 20),
        Builder(
          builder: (context) => SheetButton(
            icon: Icons.arrow_forward,
            label: 'Kontynuuj',
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ),
        const SizedBox(height: 8),
        Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Skanuj inną pralkę'),
          ),
        ),
      ],
    ),
  );
}
