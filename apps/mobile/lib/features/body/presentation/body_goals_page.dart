import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/database_provider.dart';
import '../domain/entities/body_goal.dart';
class BodyGoalsPage extends ConsumerStatefulWidget{const BodyGoalsPage({super.key});@override ConsumerState<BodyGoalsPage> createState()=>_BodyGoalsPageState();}
class _BodyGoalsPageState extends ConsumerState<BodyGoalsPage>{List<BodyGoal> goals=[];static const domain='body_goal';
@override void initState(){super.initState();_load();}
Future<void> _load()async{final r=await ref.read(localRecordRepositoryProvider.future);final x=await r.listDomain(domain);setState(()=>goals=x.map((e)=>BodyGoal.fromJson(Map<String,dynamic>.from(jsonDecode(e.payload) as Map))).toList());}
Future<void> _add() async {
  final label = TextEditingController();
  final value = TextEditingController();
  var type = BodyGoalType.targetWeight;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Body goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<BodyGoalType>(
              initialValue: type,
              items: BodyGoalType.values.map((x) => DropdownMenuItem<BodyGoalType>(value: x, child: Text(x.name))).toList(),
              onChanged: (x) { if (x != null) setState(() => type = x); },
            ),
            TextField(controller: label, decoration: const InputDecoration(labelText: 'Goal')),
            TextField(controller: value, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Target value')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final target = double.tryParse(value.text);
              if (target == null) return;
              final goal = BodyGoal(
                id: const Uuid().v4(),
                type: type,
                label: label.text.trim().isEmpty ? type.name : label.text.trim(),
                targetValue: target,
                unit: type == BodyGoalType.targetWeight ? 'kg' : type == BodyGoalType.targetBodyFat ? '%' : 'cm',
                createdAt: DateTime.now().toUtc(),
              );
              final repository = await ref.read(localRecordRepositoryProvider.future);
              await repository.upsert(domain: domain, key: goal.id, payload: goal.toJson(), recordDate: goal.createdAt);
              if (mounted) await _load();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
  label.dispose();
  value.dispose();
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Body goals')),
    floatingActionButton: FloatingActionButton.extended(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Goal')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Direction matters.', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 6),
        Text('Set measurable body targets.', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),
        ...goals.map((g) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            tileColor: Theme.of(context).cardColor,
            title: Text(g.label),
            subtitle: Text(g.type.name),
            trailing: Text(g.targetValue.toStringAsFixed(1) + ' ' + g.unit),
          ),
        )),
      ],
    ),
  );
}
}