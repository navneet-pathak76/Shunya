import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/widgets/sunya_glass.dart';
import '../../../database/sunya_record.dart';

class DataManagementPage extends ConsumerStatefulWidget { const DataManagementPage({super.key}); @override ConsumerState<DataManagementPage> createState() => _DataManagementPageState(); }
class _DataManagementPageState extends ConsumerState<DataManagementPage> {
  String status = '';
  Future<void> exportData() async { final db = await ref.read(sunyaDatabaseProvider.future); final records = await db.listAll(); final json = const JsonEncoder.withIndent('  ').convert({'format': 'sunya-backup-v1', 'exportedAt': DateTime.now().toUtc().toIso8601String(), 'records': records.map((r) => r.toJson()).toList()}); final uri = await FilePicker.saveFile(dialogTitle: 'Export SUNYA backup', fileName: 'sunya-backup.json', bytes: utf8.encode(json), mimeType: 'application/json'); if (mounted) setState(() => status = uri == null ? 'Export cancelled.' : 'Backup exported.'); }
  Future<void> importData() async { final file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['json']); if (file == null) return; try { final decoded = jsonDecode(utf8.decode(await file.readAsBytes())) as Map<String,dynamic>; if (decoded['format'] != 'sunya-backup-v1') throw const FormatException('Unsupported backup format'); final db = await ref.read(sunyaDatabaseProvider.future); final list = decoded['records'] as List; for (final item in list) await db.put(SunyaRecord.fromJson(Map<String,dynamic>.from(item as Map))); if (mounted) setState(() => status = 'Imported ' + list.length.toString() + ' records.'); } catch (e) { if (mounted) setState(() => status = 'Import failed: ' + e.toString()); } }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Data & Privacy')), body: ListView(padding: const EdgeInsets.all(20), children: [Text('Own your data', style: Theme.of(context).textTheme.displaySmall), const SizedBox(height: 8), const Text('Export and restore the local SUNYA database. AI secrets are never stored in the mobile app.'), const SizedBox(height: 18), SunyaGlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Backup', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 10), FilledButton.icon(onPressed: exportData, icon: const Icon(Icons.download_outlined), label: const Text('Export JSON backup')), OutlinedButton.icon(onPressed: importData, icon: const Icon(Icons.upload_outlined), label: const Text('Import JSON backup'))])), if (status.isNotEmpty) ...[const SizedBox(height: 12), Text(status)] ]));
}
