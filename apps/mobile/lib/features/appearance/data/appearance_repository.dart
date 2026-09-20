import 'dart:convert';
import '../../../database/local_record_repository.dart';
import '../domain/appearance_snapshot.dart';

class AppearanceRepository {
  AppearanceRepository(this.local);
  final LocalRecordRepository local;
  static const domain='appearance';

  Future<List<AppearanceSnapshot>> list() async {
    final records=await local.listDomain(domain);
    final items=records.map((r)=>AppearanceSnapshot.fromJson(jsonDecode(r.payload) as Map<String,dynamic>)).toList();
    items.sort((a,b)=>b.capturedAt.compareTo(a.capturedAt));
    return items;
  }
  Future<void> save(AppearanceSnapshot item)=>local.upsert(domain:domain,key:item.id,payload:item.toJson(),recordDate:item.capturedAt);
  Future<void> delete(String id)=>local.delete(domain,id);
}