import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'change_password_dialog.dart';
import 'event_switcher_sheet.dart';
import 'remove_password_dialog.dart';
import 'setup_password_dialog.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key, this.showBackButton = false, this.onBack});

  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, _) {
        final event = eventProvider.currentEvent;
        if (event == null) {
          return AppBar(toolbarHeight: 72);
        }
        return AppBar(
          toolbarHeight: 72,
          leading: showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack ?? () => Navigator.pop(context),
                )
              : null,
          title: Row(
            children: [
              Hero(
                tag: 'event_logo',
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('💎', style: TextStyle(fontSize: 22)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => showEventSwitcherSheet(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              event.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.unfold_more,
                            size: 18,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        Formatters.date(event.date),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Switch event',
              icon: const Icon(Icons.swap_horiz),
              onPressed: () => showEventSwitcherSheet(context),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => _showNotifications(context),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => _showSettings(context),
            ),
            const SizedBox(width: 4),
          ],
        );
      },
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_none_outlined,
                    size: 48,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sales and alerts will appear here.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return AlertDialog(
            title: const Text('Settings'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Security',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (auth.isPasswordSet) ...[
                    _SettingsTile(
                      icon: Icons.lock_reset,
                      title: 'Change Password',
                      onTap: () {
                        Navigator.pop(context);
                        showChangePasswordDialog(context);
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.lock_open_outlined,
                      title: 'Remove Password',
                      subtitle: 'Disable app lock',
                      onTap: () {
                        Navigator.pop(context);
                        showRemovePasswordDialog(context);
                      },
                    ),
                    if (auth.biometricAvailable)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(
                          Icons.fingerprint,
                          color: AppColors.primary,
                        ),
                        title: const Text('Biometric Unlock'),
                        subtitle: const Text('Use fingerprint or Face ID'),
                        value: auth.biometricEnabled,
                        activeThumbColor: AppColors.primary,
                        onChanged: (value) async {
                          await auth.setBiometricEnabled(value);
                        },
                      ),
                    _SettingsTile(
                      icon: Icons.lock_outline,
                      title: 'Lock Now',
                      subtitle: 'Lock the app immediately',
                      onTap: () {
                        Navigator.pop(context);
                        auth.lock();
                      },
                    ),
                  ] else
                    _SettingsTile(
                      icon: Icons.lock_outline,
                      title: 'Set Password',
                      subtitle: 'Protect app access with a password',
                      onTap: () {
                        Navigator.pop(context);
                        showSetupPasswordDialog(context);
                      },
                    ),
                  const Divider(height: 24),
                  _SettingsTile(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () {
                      Navigator.pop(context);
                      _showProfile(context);
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.file_download_outlined,
                    title: 'Export Data',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Export started...')),
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Always on',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'Black Diamond v1.0.0',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          final settings = settingsProvider.settings;
          final businessName = settings?.businessName.trim().isNotEmpty == true
              ? settings!.businessName
              : 'Black Diamond Promotions';

          return AlertDialog(
            title: const Text('Profile'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.surfaceElevated,
                  child: Text('👤', style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Staff',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  businessName,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
