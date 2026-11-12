import 'package:bursa_app/models/machine.dart';
import 'package:bursa_app/screens/laundry/laundry_colors.dart';
import 'package:bursa_app/screens/laundry/sheets/laundry_sheet.dart';
import 'package:bursa_app/screens/laundry/sheets/notice_box.dart';
import 'package:bursa_app/screens/laundry/sheets/sheet_button.dart';
import 'package:bursa_app/screens/laundry/sheets/sheet_header.dart';
import 'package:material_ui/material_ui.dart';

Future<void> showOutOfOrderSheet(
  BuildContext context, {
  required Machine machine,
  Machine? alternative,
}) {
  return showLaundrySheet<void>(
    context,
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetHeader(
          overline: 'Kod ${machine.qrCode}',
          title: '${machine.name} ma awarię',
          background: LaundryColors.faultBg,
          foreground: LaundryColors.faultFg,
          icon: Icons.build,
        ),
        const SizedBox(height: 20),
        const NoticeBox(
          icon: Icons.warning_amber_rounded,
          text:
              'Administrator wie o usterce. Pralka jest wyłączona z użytku do naprawy.',
          background: LaundryColors.faultBg,
          foreground: LaundryColors.faultFg,
        ),
        const SizedBox(height: 16),
        Text(
          alternative == null
              ? 'Nie naliczymy opłaty. Wybierz inną pralkę.'
              : 'Nie naliczymy opłaty. Wybierz inną pralkę – teraz wolna jest ${alternative.name}.',
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 20),
        Builder(
          builder: (context) => SheetButton(
            icon: Icons.qr_code_scanner,
            label: 'Skanuj inną pralkę',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    ),
  );
}
