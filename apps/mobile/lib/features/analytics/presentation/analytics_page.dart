import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../body/presentation/body_controller.dart';
import '../hydration/presentation/hydration_controller.dart';
import '../nutrition/presentation/nutrition_controller.dart';
import '../sleep/presentation/sleep_controller.dart';
import '../habits/presentation/habits_controller.dart';
import '../workout/presentation/workout_controller.dart';
import '../../core/widgets/sunya_glass.dart';

class AnalyticsPage extends ConsumerWidget{
 const AnalyticsPage({super.key});
 @override Widget build(BuildContext context,WidgetRef ref){
  final b=ref.watch(bodyProvider),h=ref.watch(hydrationProvider),n=ref.watch(nutritionProvider),s=ref.watch(sleepProvider),hab=ref.watch(habitsProvider),w=ref.watch(workoutControllerProvider);
  return Scaffold(appBar:AppBar(title:const Text('Analytics')),body:ListView(padding:const EdgeInsets.all(20),children:[
   Text('Your data, in one place.',style:Theme.of(context).textTheme.displaySmall),const SizedBox(height:6),Text('SUNYA analytics are derived from your locally stored records.',style:Theme.of(context).textTheme.bodyLarge),const SizedBox(height:20),
   Wrap(spacing:12,runSpacing:12,children:[
    _Metric('Weight',b.weightKg==null?'—':b.weightKg!.toStringAsFixed(1)+' kg',Icons.monitor_weight_outlined),
    _Metric('Water',h.consumedMl.toString()+' ml',Icons.water_drop_outlined),
    _Metric('Calories',n.calories.toString()+' kcal',Icons.restaurant_outlined),
    _Metric('Protein',n.protein.toStringAsFixed(0)+' g',Icons.egg_alt_outlined),
    _Metric('Sleep',s.latest==null?'—':s.latest!.hours.toStringAsFixed(1)+' h',Icons.bedtime_outlined),
    _Metric('Habits',hab.completedToday.toString()+'/'+hab.items.length,Icons.repeat_outlined),
    _Metric('Workouts',w.length.toString(),Icons.fitness_center_outlined),
   ]),
   const SizedBox(height:20),SunyaGlassCard(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Data maturity',style:Theme.of(context).textTheme.titleLarge),const SizedBox(height:8),Text(_message(b,h,n,s,hab,w))]))
 ]));
 }
 static String _message(BodyState b,HydrationState h,NutritionState n,SleepState s,HabitsState hab,List w){int filled=0;if(b.measurements.isNotEmpty)filled++;if(h.consumedMl>0)filled++;if(n.meals.isNotEmpty)filled++;if(s.entries.isNotEmpty)filled++;if(hab.items.isNotEmpty)filled++;if(w.isNotEmpty)filled++;return filled<3?'Keep logging across modules. Cross-domain analytics become meaningful as your history grows.':'Your core dataset is active across '+filled.toString()+' domains. Continue consistent logging for longitudinal patterns.';}
}
class _Metric extends StatelessWidget{const _Metric(this.label,this.value,this.icon);final String label,value;final IconData icon;@override Widget build(BuildContext c)=>SizedBox(width:170,child:SunyaGlassCard(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(icon,color:Colors.orange),const SizedBox(height:12),Text(label),const SizedBox(height:4),Text(value,style:Theme.of(c).textTheme.titleLarge)])));}
