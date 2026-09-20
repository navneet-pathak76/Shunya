import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/database_provider.dart';
class SleepEntry {
 const SleepEntry({required this.id,required this.startedAt,required this.endedAt,required this.quality});
 final String id; final DateTime startedAt,endedAt; final int quality;
 double get hours=>endedAt.difference(startedAt).inMinutes/60.0;
 Map<String,dynamic> toJson()=>{'id':id,'startedAt':startedAt.toUtc().toIso8601String(),'endedAt':endedAt.toUtc().toIso8601String(),'quality':quality};
 factory SleepEntry.fromJson(Map<String,dynamic> j)=>SleepEntry(id:j['id'] as String? ?? '',startedAt:DateTime.tryParse(j['startedAt'] as String? ?? '')?.toUtc() ?? DateTime.now().toUtc(),endedAt:DateTime.tryParse(j['endedAt'] as String? ?? '')?.toUtc() ?? DateTime.now().toUtc(),quality:(j['quality'] as num? ?? 0).toInt());
}
class SleepState{const SleepState({this.entries=const []}); final List<SleepEntry> entries; SleepEntry? get latest=>entries.isEmpty?null:entries.first; double get averageHours=>entries.isEmpty?0:entries.fold<double>(0,(s,e)=>s+e.hours)/entries.length;}
final sleepProvider=StateNotifierProvider<SleepController,SleepState>((ref)=>SleepController(ref));
class SleepController extends StateNotifier<SleepState>{
 SleepController(this.ref):super(const SleepState()){_load();} final Ref ref; static const domain='sleep';
 Future<void> _load()async{final r=await ref.read(localRecordRepositoryProvider.future);final list=(await r.listDomain(domain)).map((x)=>SleepEntry.fromJson(jsonDecode(x.payload) as Map<String,dynamic>)).toList();list.sort((a,b)=>b.endedAt.compareTo(a.endedAt));state=SleepState(entries:list);}
 Future<void> add({required DateTime start,required DateTime end,required int quality})async{final r=await ref.read(localRecordRepositoryProvider.future);final e=SleepEntry(id:const Uuid().v4(),startedAt:start,endedAt:end,quality:quality);await r.upsert(domain:domain,key:e.id,payload:e.toJson(),recordDate:end);await _load();}
}