import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/widgets/sunya_glass.dart';

class GoalsPage extends ConsumerStatefulWidget { const GoalsPage({super.key}); @override ConsumerState<GoalsPage> createState() => _GoalsPageState(); }
class _GoalsPageState extends ConsumerState<GoalsPage> {
  final title = TextEditingController(); final target = TextEditingController();
  Future<void> addGoal() async { if (title.text.trim().isEmpty) return; final r = await ref.read(localRecordRepositoryProvider.future); final id = const Uuid().v4(); await r.upsert(domain: 'goal', key: id, payload: {'id': id, 'title': title.text.trim(), 'target': target.text.trim(), 'createdAt': DateTime.now().toIso8601String()}); title.clear(); target.clear(); if (mounted) setState(() {}); }
  Future<void> remove(String id) async { final r = await ref.read(localRecordRepositoryProvider.future); await r.delete('goal', id); if (mounted) setState(() {}); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Goals')), floatingActionButton: FloatingActionButton.extended(onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('New goal'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: title, decoration: const InputDecoration(labelText: 'Goal')), TextField(controller: target, decoration: const InputDecoration(labelText: 'Target / metric'))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () { Navigator.pop(context); addGoal(); }, child: const Text('Save'))])), label: const Text('Add goal'), icon: const Icon(Icons.add)), body: FutureBuilder(future: ref.read(localRecordRepositoryProvider.future).then((r) => r.listDomain('goal')), builder: (context, snapshot) { if (!snapshot.hasData) return const Center(child: CircularProgressIndicator()); final items = snapshot.data!; if (items.isEmpty) return const Center(child: Text('Add the outcomes SUNYA should optimize for.')); return ListView(padding: const EdgeInsets.all(20), children: items.map((r) { final x = jsonDecode(r.payload) as Map<String,dynamic>; return Padding(padding: const EdgeInsets.only(bottom: 10), child: SunyaGlassCard(child: ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.flag_outlined), title: Text(x['title'].toString()), subtitle: Text(x['target']?.toString() ?? ''), trailing: IconButton(onPressed: () => remove(x['id'].toString()), icon: const Icon(Icons.delete_outline))))); }).toList()); }); }
  @override void dispose() { title.dispose(); target.dispose(); super.dispose(); }
}
