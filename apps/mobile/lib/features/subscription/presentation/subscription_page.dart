import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ai/sunya_ai_provider.dart';
import '../../../core/services/subscription/sunya_subscription_service.dart';
import '../../../core/widgets/sunya_glass.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});
  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  bool loading = false;
  String? status;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(sunyaSubscriptionServiceProvider).initialize());
  }

  Future<void> trial() async {
    setState(() => loading = true);
    await ref.read(sunyaSubscriptionServiceProvider).startTrial();
    if (!mounted) return;
    setState(() { loading = false; status = 'Your 7-day SUNYA AI trial is active.'; });
  }

  Future<void> buy() async {
    setState(() => loading = true);
    final ok = await ref.read(sunyaSubscriptionServiceProvider).purchaseMonthly();
    if (!mounted) return;
    setState(() {
      loading = false;
      status = ok ? 'Purchase flow opened in Google Play.' : 'SUNYA AI monthly is not configured in the current Play Store build.';
    });
  }

  Future<void> restore() async {
    setState(() => loading = true);
    await ref.read(sunyaSubscriptionServiceProvider).restore();
    if (!mounted) return;
    setState(() { loading = false; status = 'Purchase restoration requested.'; });
  }

  @override
  Widget build(BuildContext context) {
    final access = ref.watch(sunyaAiAccessProvider);
    final ends = access.trialEndsAt;
    return Scaffold(
      appBar: AppBar(title: const Text('SUNYA AI')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text('Personal health intelligence', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          const Text('SUNYA AI analyses your connected health data together with everything you enter in SUNYA, then turns the combined history into personalized insights.'),
          const SizedBox(height: 20),
          SunyaGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('7-day free trial', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                const Text('Try the complete SUNYA AI experience for one week before choosing a monthly plan.'),
                const SizedBox(height: 14),
                if (access.trialActive && ends != null)
                  Text('Trial active until ${ends.toLocal()}')
                else
                  SunyaPrimaryButton(
                    label: loading ? 'Starting…' : 'Start 7-day trial',
                    onPressed: loading ? null : trial,
                    icon: Icons.auto_awesome_rounded,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SunyaGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SUNYA AI Monthly', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 6),
                Text(
                  ref.read(sunyaSubscriptionServiceProvider).monthlyProduct?.price ?? '₹79/month target price',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                const Text('Final price and introductory offers are controlled by Google Play.'),
                const SizedBox(height: 14),
                SunyaPrimaryButton(
                  label: loading ? 'Opening…' : 'Continue with monthly plan',
                  onPressed: loading ? null : buy,
                  icon: Icons.workspace_premium_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const SunyaGlassCard(
            child: Text('Included\\n\\n• Whole-person health context\\n• Longitudinal trend analysis\\n• Personalized daily priorities\\n• Body, nutrition, hydration, sleep and activity cross-analysis\\n• AI conversations grounded in your tracked data'),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: loading ? null : restore,
            icon: const Icon(Icons.restore_rounded),
            label: const Text('Restore purchases'),
          ),
          if (status != null) ...[
            const SizedBox(height: 12),
            Text(status!, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
