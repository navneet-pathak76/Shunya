import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/database_provider.dart';
class Habit {
 const Habit({required this.id,required this.name,required this.completedDates});
 final String id,name; final List<String> completedDates;
 Map<String,dynamic> toJson()=>{'id':id,'name':name,'completedDates':completedDates};
 factory Habit.fromJson(Map<String,dynamic> j)=>Habit(id:j['id'] as String? ?? '',name:j['name'] as String? ?? 'Habit',completedDates:(j['completedDates'] as List? ?? const []).map((x)=>x.toString()).toList());
 bool completedOn(DateTime d)=>completedDates.contains(_day(d));
 static String _day(DateTime d)=>d.year.toString().padLeft(4,'0')+'-'+d.month.toString().padLeft(2,'0')+'-'+d.day.toString().padLeft(2,'0');
}
class HabitsState{const HabitsState({this.items=const []}); final List<Habit> items; int get completedToday=>items.where((h)=>h.completedOn(DateTime.now())).length;}
final habitsProvider=StateNotifierProvider<HabitsController,HabitsState>((ref)=>HabitsController(ref));
class HabitsController extends StateNotifier<HabitsState>{
 HabitsController(this.ref):super(const HabitsState()){_load();} final Ref ref; static const domain='habit';
 Future<void> _load()async{final r=await ref.read(localRecordRepositoryProvider.future);final list=(await r.listDomain(domain)).map((x)=>Habit.fromJson(jsonDecode(x.payload) as Map<String,dynamic>)).toList();state=HabitsState(items:list);}
 Future<void> add(String name)async{final r=await ref.read(localRecordRepositoryProvider.future);final h=Habit(id:const Uuid().v4(),name:name.trim(),completedDates:const []);await r.upsert(domain:domain,key:h.id,payload:h.toJson(),recordDate:DateTime.now().toUtc());await _load();}
 Future<void> toggle(Habit h)async{final today=Habit._day(DateTime.now());final dates=[...h.completedDates];dates.contains(today)?dates.remove(today):dates.add(today);final next=Habit(id:h.id,name:h.name,completedDates:dates);final r=await ref.read(localRecordRepositoryProvider.future);await r.upsert(domain:domain,key:h.id,payload:next.toJson(),recordDate:DateTime.now().toUtc());await _load();}
}