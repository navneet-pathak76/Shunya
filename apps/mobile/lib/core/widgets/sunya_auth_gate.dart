import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/auth_page.dart';
import '../widgets/sunya_welcome.dart';

class SunyaAuthGate extends ConsumerStatefulWidget {
  const SunyaAuthGate({super.key, required this.child});
  final Widget child;
  @override ConsumerState<SunyaAuthGate> createState() => _SunyaAuthGateState();
}

class _SunyaAuthGateState extends ConsumerState<SunyaAuthGate> {
  bool loading = true;
  bool signedIn = false;
  bool adminEarlyAccess = false;
  static const adminMode = bool.fromEnvironment('SUNYA_ADMIN_MODE', defaultValue: false);

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    try {
      final account = await ref.read(sunyaAuthServiceProvider).restore();
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final adminUnlocked = adminMode && (prefs.getBool('sunya.adminEarlyAccess') ?? false);
      setState(() {
        signedIn = account != null || adminUnlocked;
        adminEarlyAccess = adminUnlocked;
        loading = false;
      });
    } catch (_) {
      if (mounted) setState(() { signedIn = false; loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!signedIn) {
      return SunyaAuthPage(
        onSignedIn: () => setState(() => signedIn = true),
        onAdminEarlyAccess: adminMode
            ? () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('sunya.adminEarlyAccess', true);
                if (mounted) {
                  setState(() {
                    adminEarlyAccess = true;
                    signedIn = true;
                  });
                }
              }
            : null,
      );
    }
    return SunyaWelcomeGate(child: widget.child);
  }
}
