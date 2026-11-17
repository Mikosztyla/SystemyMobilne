import 'package:bursa_app/models/app_user.dart';
import 'package:material_ui/material_ui.dart';

class ProfileHeader extends StatelessWidget{
  final AppUser user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: colorScheme.primary,
          child: Text(
            user.getInitials(),
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${user.name} ${user.surname}",
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (user.isAdmin) ...[
                SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.only(left: 6, right: 8),
                  height: 26,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        size: 16,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Administrator",
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}