import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../body/presentation/body_controller.dart';
import '../hydration/presentation/hydration_controller.dart';
import '../nutrition/presentation/nutrition_controller.dart';
import '../sleep/presentation/sleep_controller.dart';
import '../habits/presentation/habits_controller.dart';
import '../../core/widgets/sunya_glass.dart';

class AiPage extends ConsumerWidget{
 const AiPage({super.key});
 @override Widget build(BuildContext context,WidgetRef ref){
  final b=ref.watch(bodyProvider),h=ref.watch(hydrationProvider),n=ref.watch(nutritionProvider),s=ref.watch(sleepProvider),hab=ref.watch(habitsProvider);
  final insights=<String>[
   if(b.weightKg==null)'Log your body weight to establish a baseline.',
   if(h.consumedMl==0)'Start hydration logging today so SUNYA can learn your daily pattern.',
   if(n.meals.isEmpty)'Log meals to build your nutrition history.',
   if(s.latest==null)'Log sleep to connect recovery with your daily behavior.',
   if(hab.items.isEmpty)'Create a habit so SUNYA can track consistency.',
   if(b.weightKg!=null && h.consumedMl>0)'Your body and hydration datasets have started. Keep the same logging cadence to reveal trends.',
  ];
  return Scaffold(appBar:AppBar(title:const Text('SUNYA AI')),body:ListView(padding:const EdgeInsets.all(20),children:[
   Text('Personal intelligence',style:Theme.of(context).textTheme.displaySmall),const SizedBox(height:6),Text('Contextual insights generated from your local SUNYA dataset.',style:Theme.of(context).textTheme.bodyLarge),const SizedBox(height:20),
   ...insights.map((x)=>Padding(padding:const EdgeInsets.only(bottom:10),child:SunyaGlassCard(padding:const EdgeInsets.all(16),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.auto_awesome,color:Colors.orange),const SizedBox(width:12),Expanded(child:Text(x))])))),
   const SizedBox(height:8),Text('AI provider connection',style:Theme.of(context).textTheme.titleLarge),const SizedBox(height:8),const Text('The mobile layer is provider-agnostic. Remote model calls should go through the FastAPI backend so secrets never ship in the app.')
 ]));}
}