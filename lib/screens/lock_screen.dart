import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    final auth = context.read<AuthProvider>();
    if (auth.biometricEnabled && auth.biometricAvailable) {
      await auth.unlockWithBiometric();
    }
  }

  Future<void> _unlock() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    auth.clearError();
    await auth.unlockWithPassword(_passwordController.text);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.lock,
                        size: 64,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'App Locked',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter your password to continue',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 28),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscure,
                        autofocus: true,
                        onSubmitted: (_) => _unlock(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      if (auth.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          auth.errorMessage!,
                          style: const TextStyle(color: AppColors.primary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Unlock',
                        icon: Icons.lock_open,
                        expand: true,
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _unlock,
                      ),
                      if (auth.biometricEnabled && auth.biometricAvailable) ...[
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _tryBiometric,
                          icon: const Icon(Icons.fingerprint, size: 28),
                          label: const Text('Unlock with Biometrics'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
