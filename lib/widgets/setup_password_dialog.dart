import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'custom_text_field.dart';
import 'primary_button.dart';

Future<void> showSetupPasswordDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => const SetupPasswordDialog(),
  );
}

class SetupPasswordDialog extends StatefulWidget {
  const SetupPasswordDialog({super.key});

  @override
  State<SetupPasswordDialog> createState() => _SetupPasswordDialogState();
}

class _SetupPasswordDialogState extends State<SetupPasswordDialog> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final success = await auth.setupPassword(
      _passwordController.text,
      _confirmController.text,
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
                    'Set Password',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Protect app access with a password. You can remove it later from settings.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _confirmController,
                    hintText: 'Confirm password',
                    prefixIcon: Icons.lock_outline,
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
