import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  bool _storageGranted = false;
  bool _notificationsGranted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.grid32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
            ),
            child: Icon(
              Icons.shield_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: DesignTokens.grid32),
          Text(
            'Permissions',
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: DesignTokens.grid12),
          Text(
            'We need a few permissions to provide the best reading experience.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyLarge?.color?.withAlpha(150),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.grid32),
          _PermissionTile(
            icon: Icons.folder_outlined,
            title: 'Storage',
            subtitle: 'Import books from your device',
            granted: _storageGranted,
            onToggle: () => setState(() => _storageGranted = !_storageGranted),
          ),
          const SizedBox(height: DesignTokens.grid12),
          _PermissionTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Reading reminders & updates',
            granted: _notificationsGranted,
            onToggle: () => setState(() => _notificationsGranted = !_notificationsGranted),
          ),
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool granted;
  final VoidCallback onToggle;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.granted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(DesignTokens.grid16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(
          color: granted ? theme.colorScheme.primary : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: DesignTokens.grid16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Switch(
            value: granted,
            onChanged: (_) => onToggle(),
          ),
        ],
      ),
    );
  }
}
