import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/database_provider.dart';
import '../data/appearance_repository.dart';
import '../domain/appearance_snapshot.dart';

final appearanceRepositoryProvider=FutureProvider<AppearanceRepository>((ref)async=>AppearanceRepository(await ref.watch(localRecordRepositoryProvider.future)));
final appearanceProvider=StateNotifierProvider<AppearanceController,List<AppearanceSnapshot>>((ref)=>AppearanceController(ref));

class AppearanceController extends StateNotifier<List<AppearanceSnapshot>>{
 AppearanceController(this.ref):super(const []){_load();}
 final Ref ref;
 Future<void> _load()async{state=await (await ref.read(appearanceRepositoryProvider.future)).list();}
 Future<void> add({required String path,AppearanceArea area=AppearanceArea.face,String notes='',double? userScore,double? hairDensityScore,double? beardCoverageScore,double? underEyeScore,double? skinClarityScore})async{
  final item=AppearanceSnapshot(id:const Uuid().v4(),capturedAt:DateTime.now().toUtc(),imagePath:path,area:area,notes:notes,userScore:userScore,hairDensityScore:hairDensityScore,beardCoverageScore:beardCoverageScore,underEyeScore:underEyeScore,skinClarityScore:skinClarityScore);
  final r=await ref.read(appearanceRepositoryProvider.future);await r.save(item);state=await r.list();
 }
}