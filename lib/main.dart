import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

double log10(double x) => math.log(x) / math.ln10;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(FitCalcHubApp(prefs: prefs));
}

class FitCalcHubApp extends StatefulWidget {
  final SharedPreferences prefs;
  const FitCalcHubApp({super.key, required this.prefs});
  @override State<FitCalcHubApp> createState() => _FitCalcHubAppState();
}
class _FitCalcHubAppState extends State<FitCalcHubApp> {
  bool dark = false;
  @override void initState(){ super.initState(); dark=widget.prefs.getBool('dark')??false; }
  void setDark(bool v){ setState(()=>dark=v); widget.prefs.setBool('dark',v); }
  @override Widget build(BuildContext context)=>MaterialApp(
    debugShowCheckedModeBanner:false, title:'FitCalcHub',
    themeMode: dark?ThemeMode.dark:ThemeMode.light,
    theme: ThemeData(useMaterial3:true,colorSchemeSeed:const Color(0xFF10B981)),
    darkTheme: ThemeData(useMaterial3:true,colorSchemeSeed:const Color(0xFF10B981),brightness:Brightness.dark),
    home: MainShell(prefs:widget.prefs,dark:dark,onDark:setDark),
  );
}

class MainShell extends StatefulWidget {
  final SharedPreferences prefs; final bool dark; final ValueChanged<bool> onDark;
  const MainShell({super.key,required this.prefs,required this.dark,required this.onDark});
  @override State<MainShell> createState()=>_MainShellState();
}
class _MainShellState extends State<MainShell>{
  int index=0;
  @override Widget build(BuildContext context){
    final pages=[
      HomePage(onOpen:(c)=>Navigator.push(context,MaterialPageRoute(builder:(_)=>c==Calc.meal?MealPage(prefs:widget.prefs):CalcPage(calc:c,prefs:widget.prefs)))),
      CalculatorList(prefs:widget.prefs),
      SavedPage(prefs:widget.prefs),
      SettingsPage(prefs:widget.prefs,dark:widget.dark,onDark:widget.onDark),
    ];
    return Scaffold(body:Stack(children:[Positioned.fill(child:Image.asset('assets/fitcalchub-hero.svg',fit:BoxFit.cover,opacity:const AlwaysStoppedAnimation(.14))),Positioned.fill(child:Container(color:Colors.white.withOpacity(widget.dark?.04:.76))),pages[index]]),bottomNavigationBar:NavigationBar(selectedIndex:index,onDestinationSelected:(i)=>setState(()=>index=i),destinations:const[
      NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home),label:'Home'),
      NavigationDestination(icon:Icon(Icons.calculate_outlined),selectedIcon:Icon(Icons.calculate),label:'Calculators'),
      NavigationDestination(icon:Icon(Icons.bookmark_border),selectedIcon:Icon(Icons.bookmark),label:'Saved'),
      NavigationDestination(icon:Icon(Icons.settings_outlined),selectedIcon:Icon(Icons.settings),label:'Settings'),
    ]));
  }
}

enum Calc { bmi,bmr,tdee,bodyFat,meal,deficit }
String calcName(Calc c)=>switch(c){Calc.bmi=>'BMI Calculator',Calc.bmr=>'BMR Calculator',Calc.tdee=>'TDEE Calculator',Calc.bodyFat=>'Body Fat Calculator',Calc.meal=>'Meal Calorie Calculator',Calc.deficit=>'Calorie Deficit Calculator'};

class HomePage extends StatelessWidget{
 final ValueChanged<Calc> onOpen; const HomePage({super.key,required this.onOpen});
 @override Widget build(BuildContext context)=>SafeArea(child:ListView(padding:const EdgeInsets.all(20),children:[
   const SizedBox(height:12), Text('FitCalcHub',style:Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight:FontWeight.bold)),
   const SizedBox(height:6), const Text('Simple, free health & fitness calculators.'),
   const SizedBox(height:24), Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Text('Popular calculators',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.bold)),
     const SizedBox(height:12), Wrap(spacing:10,runSpacing:10,children:[
       for(final c in [Calc.bmi,Calc.tdee,Calc.bmr]) ActionChip(label:Text(calcName(c)),onPressed:()=>onOpen(c))
     ])
   ]))),
   const SizedBox(height:18), const InfoCard(title:'Free & private',text:'Calculations run locally on your device. No account or backend is required.'),
   const SizedBox(height:12), const InfoCard(title:'Important',text:'Results are estimates for informational use and are not medical advice.'),
 ]));
}

class CalculatorList extends StatelessWidget{
 final SharedPreferences prefs; const CalculatorList({super.key,required this.prefs});
 @override Widget build(BuildContext context)=>SafeArea(child:ListView(padding:const EdgeInsets.all(20),children:[
   Text('Calculators',style:Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.bold)),
   const SizedBox(height:16), for(final c in Calc.values) Card(child:ListTile(
     leading:const CircleAvatar(child:Icon(Icons.calculate_outlined)),title:Text(calcName(c)),subtitle:Text(_desc(c)),
     trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>c==Calc.meal?MealPage(prefs:prefs):CalcPage(calc:c,prefs:prefs))))),
 ]));
}
String _desc(Calc c)=>switch(c){
 Calc.bmi=>'Body Mass Index estimate',Calc.bmr=>'Resting calorie estimate',Calc.tdee=>'Estimated daily energy needs',
 Calc.bodyFat=>'US Navy method estimate',Calc.meal=>'Calories and macros for a meal',Calc.deficit=>'Maintenance and example deficit range'};

class CalcPage extends StatefulWidget{
 final Calc calc; final SharedPreferences prefs;
 const CalcPage({super.key,required this.calc,required this.prefs});
 @override State<CalcPage> createState()=>_CalcPageState();
}
class _CalcPageState extends State<CalcPage>{
 final Map<String,TextEditingController> c={};
 String sex='male',activity='1.2',result='';
 @override void initState(){super.initState(); for(final k in ['age','weight','height','weightKg','heightCm','neck','waist','hip'])c[k]=TextEditingController();}
 @override void dispose(){for(final x in c.values)x.dispose();super.dispose();}
 double n(String k)=>double.tryParse(c[k]!.text.trim())??0;
 void save(){if(result.isEmpty)return; final old=widget.prefs.getStringList('results')??[]; old.insert(0,'${calcName(widget.calc)}: $result'); if(old.length>30)old.removeLast(); widget.prefs.setStringList('results',old); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Result saved')));}
 void calculate(){
   final age=n('age'),w=n('weight'),h=n('height');
   final bmiWeight=n('weightKg'), bmiHeight=n('heightCm');
   String r='';
   if(widget.calc==Calc.bmi){
     if(bmiWeight<=0||bmiHeight<=0){r='Please enter valid weight and height.';} else {final bmi=bmiWeight/((bmiHeight/100)*(bmiHeight/100)); final cat=bmi<18.5?'Underweight':bmi<25?'Normal range':bmi<30?'Overweight':'Obesity'; r='${bmi.toStringAsFixed(1)} — $cat';}
   } else if(widget.calc==Calc.bmr || widget.calc==Calc.tdee || widget.calc==Calc.deficit){
     if(age<18||w<=0||h<=0){r='Please enter valid adult age, weight and height.';} else {
       final kg=(widget.calc==Calc.bmr? w/2.20462 : bmiWeight),cm=(widget.calc==Calc.bmr? h*2.54 : bmiHeight),bmr=sex=='male'?10*kg+6.25*cm-5*age+5:10*kg+6.25*cm-5*age-161;
       if(widget.calc==Calc.bmr) r='${bmr.round()} kcal/day estimated BMR';
       else {final t=bmr*double.parse(activity); if(widget.calc==Calc.tdee) r='${t.round()} kcal/day estimated TDEE'; else {final low=(t-500).round()<1200?1200:(t-500).round(); final high=(t-300).round()<1200?1200:(t-300).round(); r='Maintenance: ${t.round()} kcal/day\nExample deficit range: $low–$high kcal/day';}}
     }
   } else if(widget.calc==Calc.bodyFat){
     final hh=n('heightCm'), neck=n('neck'), waist=n('waist'), hip=n('hip'), female=sex=='female';
     if(hh<=0||neck<=0||waist<=0||(female&&hip<=0)) r='Please enter valid measurements.';
     else {final x=female?waist+hip-neck:waist-neck; if(x<=0) r='Please check your measurements.'; else {final bf=female?495/(1.29579-0.35004*log10(x)+0.221*log10(hh))-450:495/(1.0324-0.19077*log10(x)+0.15456*log10(hh))-450; r='${bf.toStringAsFixed(1)}% estimated body fat';}}
   }
   setState(()=>result=r);
 }
 @override Widget build(BuildContext context){
   final labels=switch(widget.calc){
     Calc.bmi=>['weightKg','heightCm'], Calc.bmr=>['age','weight','height'], Calc.tdee=>['age','weightKg','heightCm'],
     Calc.deficit=>['age','weightKg','heightCm'], Calc.bodyFat=>['heightCm','neck','waist','hip'], Calc.meal=>[]
   };
   return Scaffold(appBar:AppBar(title:Text(calcName(widget.calc))),body:ListView(padding:const EdgeInsets.all(20),children:[
     if(widget.calc!=Calc.bmi)DropdownButtonFormField<String>(value:sex,decoration:const InputDecoration(labelText:'Sex',border:OutlineInputBorder()),items:const[DropdownMenuItem(value:'male',child:Text('Male')),DropdownMenuItem(value:'female',child:Text('Female'))],onChanged:(v)=>setState(()=>sex=v!)),
     if(widget.calc!=Calc.bmi)const SizedBox(height:12),
     for(final k in labels)...[_field(k),const SizedBox(height:12)],
     if(widget.calc==Calc.tdee||widget.calc==Calc.deficit) ...[DropdownButtonFormField<String>(value:activity,decoration:const InputDecoration(labelText:'Activity',border:OutlineInputBorder()),items:const[
       DropdownMenuItem(value:'1.2',child:Text('Sedentary')),DropdownMenuItem(value:'1.375',child:Text('Lightly active')),DropdownMenuItem(value:'1.55',child:Text('Moderately active')),DropdownMenuItem(value:'1.725',child:Text('Very active')),DropdownMenuItem(value:'1.9',child:Text('Extra active'))],onChanged:(v)=>setState(()=>activity=v!)),const SizedBox(height:12)],
     FilledButton(onPressed:calculate,child:const Text('Calculate')),
     if(result.isNotEmpty)...[const SizedBox(height:16),Card(color:Theme.of(context).colorScheme.primaryContainer,child:Padding(padding:const EdgeInsets.all(18),child:Text(result,style:Theme.of(context).textTheme.titleMedium))),const SizedBox(height:10),OutlinedButton.icon(onPressed:save,icon:const Icon(Icons.bookmark_add),label:const Text('Save result'))],
     const SizedBox(height:18),const Text('For informational purposes only. This calculator does not provide medical advice.')
   ]));
 }
 Widget _field(String k){final units={'weight':'Weight (lb)','height':'Height (in)','weightKg':'Weight (kg)','heightCm':'Height (cm)','age':'Age','neck':'Neck (cm)','waist':'Waist (cm)','hip':'Hip (cm)'};return TextField(controller:c[k],keyboardType:TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:units[k],border:const OutlineInputBorder()));}
}

class MealPage extends StatefulWidget {
  final SharedPreferences prefs;
  const MealPage({super.key, required this.prefs});
  @override State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  final rows = <Map<String, TextEditingController>>[];

  @override
  void initState() {
    super.initState();
    addRow();
  }

  void addRow() {
    setState(() {
      rows.add({
        for (final k in ['food','qty','cal','pro','carb','fat'])
          k: TextEditingController(text: k == 'qty' ? '1' : ''),
      });
    });
  }

  void remove(int i) {
    for (final x in rows[i].values) {
      x.dispose();
    }
    setState(() => rows.removeAt(i));
  }

  double sum(String key) {
    double total = 0;
    for (final row in rows) {
      final value = double.tryParse(row[key]!.text) ?? 0;
      final qty = double.tryParse(row['qty']!.text) ?? 0;
      total += value * qty;
    }
    return total;
  }

  @override
  void dispose() {
    for (final row in rows) {
      for (final controller in row.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meal Calorie Calculator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (int i = 0; i < rows.length; i++)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: TextField(
                          controller: rows[i]['food'],
                          decoration: const InputDecoration(labelText: 'Food'),
                        )),
                        IconButton(
                          onPressed: () => remove(i),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _field(rows[i]['qty']!, 'Qty')),
                        Expanded(child: _field(rows[i]['cal']!, 'Calories')),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _field(rows[i]['pro']!, 'Protein g')),
                        Expanded(child: _field(rows[i]['carb']!, 'Carbs g')),
                        Expanded(child: _field(rows[i]['fat']!, 'Fat g')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          OutlinedButton.icon(
            onPressed: addRow,
            icon: const Icon(Icons.add),
            label: const Text('Add Food'),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                'Calories: ${sum('cal').toStringAsFixed(1)} kcal\n'
                'Protein: ${sum('pro').toStringAsFixed(1)} g\n'
                'Carbs: ${sum('carb').toStringAsFixed(1)} g\n'
                'Fat: ${sum('fat').toStringAsFixed(1)} g',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: TextField(
        controller: controller,
        onChanged: (_) => setState(() {}),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class SavedPage extends StatelessWidget{final SharedPreferences prefs;const SavedPage({super.key,required this.prefs});@override Widget build(BuildContext context){final r=prefs.getStringList('results')??[];return SafeArea(child:ListView(padding:const EdgeInsets.all(20),children:[Text('Saved Results',style:Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.bold)),const SizedBox(height:12),if(r.isEmpty)const Text('No saved results yet.') else for(final x in r)Card(child:ListTile(leading:const Icon(Icons.bookmark),title:Text(x)))]));}}
class SettingsPage extends StatelessWidget{final SharedPreferences prefs;final bool dark;final ValueChanged<bool> onDark;const SettingsPage({super.key,required this.prefs,required this.dark,required this.onDark});@override Widget build(BuildContext context)=>SafeArea(child:ListView(padding:const EdgeInsets.all(20),children:[Text('Settings',style:Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.bold)),SwitchListTile(value:dark,onChanged:onDark,title:const Text('Dark mode')),const ListTile(title:Text('Units'),subtitle:Text('The current calculator formulas follow the website input units.')),const ListTile(title:Text('Privacy'),subtitle:Text('No account or backend is required; saved results stay locally on the device.')),const ListTile(title:Text('Disclaimer'),subtitle:Text('Results are estimates for informational use only.'))]));}
class InfoCard extends StatelessWidget{final String title,text;const InfoCard({super.key,required this.title,required this.text});@override Widget build(BuildContext context)=>Card(child:ListTile(title:Text(title,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text(text)));}
