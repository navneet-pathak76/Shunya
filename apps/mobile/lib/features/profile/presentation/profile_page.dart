import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../body/presentation/body_controller.dart';
import '../../../core/widgets/sunya_glass.dart';

class ProfilePage extends ConsumerWidget{
 const ProfilePage({super.key});
 @override Widget build(BuildContext context,WidgetRef ref){final b=ref.watch(bodyProvider);return Scaffold(appBar:AppBar(title:const Text('Profile')),body:ListView(padding:const EdgeInsets.all(20),children:[
 Text('Your baseline',style:Theme.of(context).textTheme.displaySmall),const SizedBox(height:6),Text('The personal context SUNYA uses across modules.',style:Theme.of(context).textTheme.bodyLarge),const SizedBox(height:20),
 SunyaGlassCard(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Body profile',style:Theme.of(context).textTheme.titleLarge),const SizedBox(height:12),_row('Height',b.heightCm==null?'—':b.heightCm!.toStringAsFixed(1)+' cm'),_row('Weight',b.weightKg==null?'—':b.weightKg!.toStringAsFixed(1)+' kg'),_row('BMI',b.bmi==null?'—':b.bmi!.toStringAsFixed(1)),_row('Body fat',b.bodyFatPercent==null?'—':b.bodyFatPercent!.toStringAsFixed(1)+' %')])),
 const SizedBox(height:16),SunyaGlassCard(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Privacy',style:Theme.of(context).textTheme.titleLarge),const SizedBox(height:8),const Text('SUNYA is designed local-first. Personal records are stored on-device unless you explicitly connect a remote service.'),const SizedBox(height:12),const Text('AI providers must be connected through the backend; API keys should never live in the Flutter client.')]))
 ]));}
 static Widget _row(String a,String b)=>Padding(padding:const EdgeInsets.symmetric(vertical:7),child:Row(children:[Expanded(child:Text(a)),Text(b)]));
}