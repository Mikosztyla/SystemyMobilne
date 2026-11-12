import 'package:material_ui/material_ui.dart';

class NoticeBox extends StatelessWidget {
  const NoticeBox({
    super.key,
    required this.icon,
    required this.text,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 14, color: foreground)),
          ),
        ],
      ),
    );
  }
}
