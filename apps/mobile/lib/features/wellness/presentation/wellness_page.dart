import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/widgets/sunya_glass.dart';

class WellnessPage extends ConsumerStatefulWidget { const WellnessPage({super.key}); @override ConsumerState<WellnessPage> createState() => _WellnessPageState(); }
class _WellnessPageState extends ConsumerState<WellnessPage> with SingleTickerProviderStateMixin {
  late final tabs = TabController(length: 3, vsync: this);
  Future<void> add(String domain, String title, String body) async { final r = await ref.read(localRecordRepositoryProvider.future); final id = const Uuid().v4(); await r.upsert(domain: domain, key: id, payload: {'id': id, 'title': title, 'body': body, 'createdAt': DateTime.now().toIso8601String()}); if (mounted) setState(() {}); }
  Future<void> dialog(String domain, String label) async { final t = TextEditingController(); final b = TextEditingController(); await showDialog(context: context, builder: (_) => AlertDialog(title: Text('Add ' + label), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: t, decoration: InputDecoration(labelText: label)), TextField(controller: b, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes'))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () { Navigator.pop(context); add(domain, t.text.trim(), b.text.trim()); }, child: const Text('Save'))])); t.dispose(); b.dispose(); }
  Widget tab(String domain, String label, IconData icon) => FutureBuilder(future: ref.read(localRecordRepositoryProvider.future).then((r) => r.listDomain(domain)), builder: (context, snapshot) { if (!snapshot.hasData) return const Center(child: CircularProgressIndicator()); final items = snapshot.data!; return ListView(padding: const EdgeInsets.all(20), children: [FilledButton.icon(onPressed: () => dialog(domain, label), icon: Icon(icon), label: Text('Add ' + label)), const SizedBox(height: 12), if (items.isEmpty) const SunyaGlassCard(child: Text('Nothing logged yet.')), ...items.map((r) { final x = jsonDecode(r.payload) as Map<String,dynamic>; return Padding(padding: const EdgeInsets.only(bottom: 8), child: SunyaGlassCard(child: ListTile(contentPadding: EdgeInsets.zero, title: Text(x['title']?.toString() ?? label), subtitle: Text(x['body']?.toString() ?? '')))); })]); });
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Wellness'), bottom: TabBar(controller: tabs, tabs: const [Tab(text: 'Mood', icon: Icon(Icons.mood_outlined)), Tab(text: 'Journal', icon: Icon(Icons.book_outlined)), Tab(text: 'Medications', icon: Icon(Icons.medication_outlined))])), body: TabBarView(controller: tabs, children: [tab('mood', 'Mood', Icons.mood_outlined), tab('journal', 'Journal entry', Icons.book_outlined), tab('medication', 'Medication', Icons.medication_outlined)]));
  @override void dispose() { tabs.dispose(); super.dispose(); }
}
