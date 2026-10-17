import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

Future<void> showChangePasswordDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => const ChangePasswordDialog(),
  );
}

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final success = await auth.changePassword(
      current: _currentController.text,
      newPassword: _newController.text,
      confirm: _confirmController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _currentController,
                    hintText: 'Current password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _newController,
                    hintText: 'New password',
                    prefixIcon: Icons.lock_reset,
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _confirmController,
                    hintText: 'Confirm new password',
                    prefixIcon: Icons.lock_reset,
                    obscureText: true,
                    onSubmitted: (_) => _submit(),
                  ),
                  if (auth.errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      auth.errorMessage!,
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      PrimaryButton(
                        label: 'Save',
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _submit,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
