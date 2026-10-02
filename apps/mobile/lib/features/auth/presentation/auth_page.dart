import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/auth/sunya_auth_service.dart';
import '../../../core/settings/sunya_settings.dart';
import '../../../core/widgets/sunya_glass.dart';

final sunyaAuthServiceProvider = Provider((ref) => SunyaAuthService());

class SunyaAuthPage extends ConsumerStatefulWidget {
  const SunyaAuthPage({super.key, required this.onSignedIn});
  final VoidCallback onSignedIn;
  @override ConsumerState<SunyaAuthPage> createState() => _SunyaAuthPageState();
}

class _SunyaAuthPageState extends ConsumerState<SunyaAuthPage> {
  bool loading = false;
  String? error;

  Future<void> signIn() async {
    setState(() { loading = true; error = null; });
    try {
      final account = await ref.read(sunyaAuthServiceProvider).signIn();
      if (!mounted) return;
      if (account == null) {
        setState(() { loading = false; error = 'Google Sign-In is not configured for this build.'; });
        return;
      }
      final current = ref.read(sunyaSettingsProvider);
      await ref.read(sunyaSettingsProvider.notifier).update(
        current.copyWith(name: (account.name ?? account.email.split('@').first).trim()),
      );
      setState(() => loading = false);
      widget.onSignedIn();
    } catch (e) {
      if (mounted) setState(() { loading = false; error = 'Sign-in failed. Please try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(Icons.bolt_rounded, size: 54),
            const SizedBox(height: 20),
            Text('SUNYA', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            Text('Your personal health intelligence layer', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 28),
            const SunyaGlassCard(
              child: Text('Connect your Google account, then choose which health data SUNYA may import. Your health data stays under your control and is only used for personalization.'),
            ),
            const SizedBox(height: 20),
            SunyaPrimaryButton(
              label: loading ? 'Connecting…' : 'Continue with Google',
              onPressed: loading ? null : signIn,
              icon: Icons.account_circle_outlined,
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 20),
            const Text('You can change AI provider, health permissions, and privacy controls later in Settings.', textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}
