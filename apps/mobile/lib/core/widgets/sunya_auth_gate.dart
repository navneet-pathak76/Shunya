import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    try {
      final account = await ref.read(sunyaAuthServiceProvider).restore();
      if (!mounted) return;
      setState(() {
        signedIn = account != null;
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
      return SunyaAuthPage(onSignedIn: () => setState(() => signedIn = true));
    }
    return SunyaWelcomeGate(child: widget.child);
  }
}
