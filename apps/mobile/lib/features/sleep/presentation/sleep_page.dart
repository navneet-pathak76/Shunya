import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/sunya_glass.dart';
import 'sleep_controller.dart';
class SleepPage extends ConsumerWidget {
 const SleepPage({super.key});
 @override Widget build(BuildContext context,WidgetRef ref){
  final s=ref.watch(sleepProvider), latest=s.latest;
  return Scaffold(appBar:AppBar(title:const Text('Sleep')),floatingActionButton:FloatingActionButton.extended(onPressed:()=>_add(context,ref),icon:const Icon(Icons.add),label:const Text('Log sleep')),body:ListView(padding:const EdgeInsets.all(20),children:[
   Text('Recovery starts at night.',style:Theme.of(context).textTheme.displaySmall),const SizedBox(height:6),Text('Track duration and perceived sleep quality.',style:Theme.of(context).textTheme.bodyLarge),const SizedBox(height:20),
   Row(children:[Expanded(child:_Stat('Last night',latest==null?'—':latest.hours.toStringAsFixed(1)+' h')),const SizedBox(width:10),Expanded(child:_Stat('Average',s.entries.isEmpty?'—':s.averageHours.toStringAsFixed(1)+' h')),const SizedBox(width:10),Expanded(child:_Stat('Quality',latest==null?'—':latest.quality.toString()+'/10'))]),const SizedBox(height:20),
   ...s.entries.take(14).map((e)=>Padding(padding:const EdgeInsets.only(bottom:10),child:SunyaGlassCard(padding:const EdgeInsets.all(16),child:Row(children:[const Icon(Icons.bedtime_outlined),const SizedBox(width:12),Expanded(child:Text(e.hours.toStringAsFixed(1)+' h\n'+e.endedAt.toLocal().toString().split('.').first)),Text(e.quality.toString()+'/10')]))))
  ]));
 }
 static Future<void> _add(BuildContext context,WidgetRef ref)async{final start=DateTime.now().subtract(const Duration(hours:8));final end=DateTime.now();await showDialog(context:context,builder:(c)=>AlertDialog(title:const Text('Log sleep'),content:const Text('SUNYA will record the last 8 hours as a sleep session. Quality can be refined later.'),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Cancel')),FilledButton(onPressed:(){ref.read(sleepProvider.notifier).add(start:start,end:end,quality:7);Navigator.pop(c);},child:const Text('Save'))]));}
}
class _Stat extends StatelessWidget{const _Stat(this.label,this.value);final String label,value;@override Widget build(BuildContext c)=>SunyaGlassCard(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label),const SizedBox(height:5),Text(value,style:Theme.of(c).textTheme.titleLarge)]));}