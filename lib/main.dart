import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const green = Color(0xFF08A957);
const greenDark = Color(0xFF078845);
const ink = Color(0xFF0B1726);
const muted = Color(0xFF64748B);
const soft = Color(0xFFF4F8F6);
const line = Color(0xFFE2E8F0);

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
  @override void initState() {
    super.initState();
    dark = widget.prefs.getBool('dark') ?? false;
  }
  void setDark(bool value) {
    setState(() => dark = value);
    widget.prefs.setBool('dark', value);
  }
  ThemeData _theme(Brightness brightness) => ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: green,
      brightness: brightness,
      primary: green,
    ),
    scaffoldBackgroundColor: brightness == Brightness.dark ? const Color(0xFF0B1726) : Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: brightness == Brightness.dark ? const Color(0xFF0B1726) : Colors.white,
      foregroundColor: brightness == Brightness.dark ? Colors.white : ink,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: line)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: brightness == Brightness.dark ? const Color(0xFF132231) : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: line)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: line)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: green, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: green,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
  );

  @override Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'FitCalcHub',
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    home: MainShell(prefs: widget.prefs, dark: dark, onDark: setDark),
  );
}

class Brand extends StatelessWidget {
  const Brand({super.key});
  @override Widget build(BuildContext context) => Row(children: [
    Container(
      width: 42, height: 42,
      decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(13)),
      child: const Icon(Icons.monitor_heart_outlined, color: Colors.white, size: 25),
    ),
    const SizedBox(width: 10),
    RichText(text: const TextSpan(
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: ink, letterSpacing: -0.7),
      children: [TextSpan(text: 'FitCalc'), TextSpan(text: 'Hub', style: TextStyle(color: green))],
    )),
  ]);
}

class MainShell extends StatefulWidget {
  final SharedPreferences prefs;
  final bool dark;
  final ValueChanged<bool> onDark;
  const MainShell({super.key, required this.prefs, required this.dark, required this.onDark});
  @override State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  void openCalc(Calc calc) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => calc == Calc.meal ? MealPage(prefs: widget.prefs) : CalcPage(calc: calc, prefs: widget.prefs),
    ));
  }

  @override Widget build(BuildContext context) {
    final pages = [
      HomePage(onOpen: openCalc),
      CalculatorList(prefs: widget.prefs, onOpen: openCalc),
      SavedPage(prefs: widget.prefs),
      SettingsPage(prefs: widget.prefs, dark: widget.dark, onDark: widget.onDark),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        indicatorColor: green.withOpacity(.13),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: green), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calculate_outlined), selectedIcon: Icon(Icons.calculate, color: green), label: 'Calculators'),
          NavigationDestination(icon: Icon(Icons.bookmark_border), selectedIcon: Icon(Icons.bookmark, color: green), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings, color: green), label: 'Settings'),
        ],
      ),
    );
  }
}

enum Calc { bmi, bmr, tdee, bodyFat, meal, deficit }

String calcName(Calc c) => switch (c) {
  Calc.bmi => 'BMI Calculator',
  Calc.bmr => 'BMR Calculator',
  Calc.tdee => 'TDEE Calculator',
  Calc.bodyFat => 'Body Fat Calculator',
  Calc.meal => 'Meal Calorie Calculator',
  Calc.deficit => 'Calorie Deficit Calculator',
};

IconData calcIcon(Calc c) => switch (c) {
  Calc.bmi => Icons.monitor_weight_outlined,
  Calc.bmr => Icons.local_fire_department_outlined,
  Calc.tdee => Icons.bolt_outlined,
  Calc.bodyFat => Icons.accessibility_new_outlined,
  Calc.meal => Icons.restaurant_menu_outlined,
  Calc.deficit => Icons.trending_down_outlined,
};

String calcDesc(Calc c) => switch (c) {
  Calc.bmi => 'Body Mass Index estimate',
  Calc.bmr => 'Resting calorie estimate',
  Calc.tdee => 'Estimated daily energy needs',
  Calc.bodyFat => 'US Navy method estimate',
  Calc.meal => 'Calories and macros for a meal',
  Calc.deficit => 'Maintenance and example deficit range',
};

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const PageHeader({super.key, required this.title, this.subtitle});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Brand(),
      const SizedBox(height: 24),
      Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1.2)),
      if (subtitle != null) ...[
        const SizedBox(height: 7),
        Text(subtitle!, style: const TextStyle(color: muted, fontSize: 15)),
      ],
    ]),
  );
}

class HomePage extends StatelessWidget {
  final ValueChanged<Calc> onOpen;
  const HomePage({super.key, required this.onOpen});

  @override Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.only(bottom: 35),
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFEEF9F3), Color(0xFFE3F3EB)]),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Brand(),
            const SizedBox(height: 30),
            const Text('HEALTH & FITNESS', style: TextStyle(color: green, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 9),
            Text('Simple tools for\nbetter health.', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -2)),
            const SizedBox(height: 14),
            const Text('Free, fast and private calculators to help you understand your fitness numbers.', style: TextStyle(color: muted, fontSize: 16, height: 1.5)),
            const SizedBox(height: 22),
            FilledButton.icon(onPressed: () => onOpen(Calc.bmi), icon: const Icon(Icons.calculate_outlined), label: const Text('Start calculating')),
          ]),
        ),
        const SizedBox(height: 30),
        _sectionTitle(context, 'Popular calculators', 'Explore the most used tools.'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .92,
            children: [Calc.bmi, Calc.tdee, Calc.bmr, Calc.bodyFat].map((c) => ToolCard(calc: c, onTap: () => onOpen(c))).toList(),
          ),
        ),
        const SizedBox(height: 28),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(24)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Free & private', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19)),
            SizedBox(height: 7),
            Text('Calculations run locally on your device. No account or backend is required.', style: TextStyle(color: muted, height: 1.45)),
            SizedBox(height: 18),
            Text('Important', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19)),
            SizedBox(height: 7),
            Text('Results are estimates for informational purposes and are not medical advice.', style: TextStyle(color: muted, height: 1.45)),
          ]),
        ),
      ],
    ),
  );

  Widget _sectionTitle(BuildContext context, String title, String sub) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1)),
      const SizedBox(height: 4),
      Text(sub, style: const TextStyle(color: muted)),
    ]),
  );
}

class ToolCard extends StatelessWidget {
  final Calc calc;
  final VoidCallback onTap;
  const ToolCard({super.key, required this.calc, required this.onTap});
  @override Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(22),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: line),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x0C0F172A), blurRadius: 20, offset: Offset(0, 7))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 50, height: 50, decoration: BoxDecoration(color: const Color(0xFFE8F8EF), borderRadius: BorderRadius.circular(15)), child: Icon(calcIcon(calc), color: green, size: 25)),
        const SizedBox(height: 15),
        Text(calcName(calc), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 5),
        Expanded(child: Text(calcDesc(calc), style: const TextStyle(color: muted, fontSize: 12.5, height: 1.35))),
        const Text('Calculate →', style: TextStyle(color: green, fontWeight: FontWeight.w900)),
      ]),
    ),
  );
}

class CalculatorList extends StatelessWidget {
  final SharedPreferences prefs;
  final ValueChanged<Calc> onOpen;
  const CalculatorList({super.key, required this.prefs, required this.onOpen});
  @override Widget build(BuildContext context) => SafeArea(
    child: ListView(padding: const EdgeInsets.only(bottom: 25), children: [
      const PageHeader(title: 'Calculators', subtitle: 'Choose a tool and get your result in seconds.'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(children: Calc.values.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(22), onTap: () => onOpen(c),
            child: Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, border: Border.all(color: line), borderRadius: BorderRadius.circular(22)),
              child: Row(children: [
                Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFFE8F8EF), borderRadius: BorderRadius.circular(16)), child: Icon(calcIcon(c), color: green)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(calcName(c), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 4), Text(calcDesc(c), style: const TextStyle(color: muted, fontSize: 13)),
                ])),
                const Icon(Icons.chevron_right, color: green),
              ]),
            ),
          ),
        )).toList()),
      ),
    ]),
  );
}

class CalcPage extends StatefulWidget {
  final Calc calc; final SharedPreferences prefs;
  const CalcPage({super.key, required this.calc, required this.prefs});
  @override State<CalcPage> createState() => _CalcPageState();
}

class _CalcPageState extends State<CalcPage> {
  final Map<String, TextEditingController> c = {};
  String sex = 'male', activity = '1.2', result = '';

  @override void initState() {
    super.initState();
    for (final k in ['age','weight','height','weightKg','heightCm','neck','waist','hip']) c[k] = TextEditingController();
  }
  @override void dispose() { for (final x in c.values) x.dispose(); super.dispose(); }
  double n(String k) => double.tryParse(c[k]!.text.trim()) ?? 0;

  void save() {
    if (result.isEmpty) return;
    final old = widget.prefs.getStringList('results') ?? [];
    old.insert(0, '${calcName(widget.calc)}: $result');
    if (old.length > 30) old.removeLast();
    widget.prefs.setStringList('results', old);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Result saved')));
  }

  void calculate() {
    final age=n('age'), w=n('weight'), h=n('height'), bmiWeight=n('weightKg'), bmiHeight=n('heightCm');
    String r='';
    if(widget.calc==Calc.bmi){
      if(bmiWeight<=0||bmiHeight<=0) r='Please enter valid weight and height.';
      else { final bmi=bmiWeight/((bmiHeight/100)*(bmiHeight/100)); final cat=bmi<18.5?'Underweight':bmi<25?'Normal range':bmi<30?'Overweight':'Obesity'; r='${bmi.toStringAsFixed(1)} — $cat'; }
    } else if(widget.calc==Calc.bmr||widget.calc==Calc.tdee||widget.calc==Calc.deficit){
      if(age<18||w<=0||h<=0) r='Please enter valid adult age, weight and height.';
      else { final kg=widget.calc==Calc.bmr?w/2.20462:bmiWeight, cm=widget.calc==Calc.bmr?h*2.54:bmiHeight, bmr=sex=='male'?10*kg+6.25*cm-5*age+5:10*kg+6.25*cm-5*age-161;
        if(widget.calc==Calc.bmr) r='${bmr.round()} kcal/day estimated BMR';
        else { final t=bmr*double.parse(activity); if(widget.calc==Calc.tdee) r='${t.round()} kcal/day estimated TDEE'; else { final low=(t-500).round()<1200?1200:(t-500).round(), high=(t-300).round()<1200?1200:(t-300).round(); r='Maintenance: ${t.round()} kcal/day\nExample deficit range: $low–$high kcal/day'; } }
      }
    } else if(widget.calc==Calc.bodyFat){
      final hh=n('heightCm'), neck=n('neck'), waist=n('waist'), hip=n('hip'), female=sex=='female';
      if(hh<=0||neck<=0||waist<=0||(female&&hip<=0)) r='Please enter valid measurements.';
      else { final x=female?waist+hip-neck:waist-neck; if(x<=0) r='Please check your measurements.'; else { final bf=female?495/(1.29579-0.35004*log10(x)+0.221*log10(hh))-450:495/(1.0324-0.19077*log10(x)+0.15456*log10(hh))-450; r='${bf.toStringAsFixed(1)}% estimated body fat'; } }
    }
    setState(()=>result=r);
  }

  double log10(double x) => Math.log(x) / Math.ln10;

  @override Widget build(BuildContext context) {
    final labels=switch(widget.calc){
      Calc.bmi=>['weightKg','heightCm'], Calc.bmr=>['age','weight','height'], Calc.tdee=>['age','weightKg','heightCm'],
      Calc.deficit=>['age','weightKg','heightCm'], Calc.bodyFat=>['heightCm','neck','waist','hip'], Calc.meal=>[]
    };
    return Scaffold(
      appBar: AppBar(title: Text(calcName(widget.calc))),
      body: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 35), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFEEF9F3), Color(0xFFF8FBF9)]), borderRadius: BorderRadius.circular(24)),
          child: Row(children: [
            Container(width: 52,height: 52,decoration:BoxDecoration(color:green,borderRadius:BorderRadius.circular(16)),child:Icon(calcIcon(widget.calc),color:Colors.white)),
            const SizedBox(width:14), Expanded(child: Text(calcDesc(widget.calc),style:const TextStyle(color:muted,height:1.35))),
          ]),
        ),
        const SizedBox(height:18),
        if(widget.calc!=Calc.bmi) ...[
          DropdownButtonFormField<String>(value:sex,decoration:const InputDecoration(labelText:'Sex'),items:const[
            DropdownMenuItem(value:'male',child:Text('Male')),DropdownMenuItem(value:'female',child:Text('Female'))
          ],onChanged:(v)=>setState(()=>sex=v!)),
          const SizedBox(height:12),
        ],
        for(final k in labels)...[_field(k),const SizedBox(height:12)],
        if(widget.calc==Calc.tdee||widget.calc==Calc.deficit)...[
          DropdownButtonFormField<String>(value:activity,decoration:const InputDecoration(labelText:'Activity level'),items:const[
            DropdownMenuItem(value:'1.2',child:Text('Sedentary')),DropdownMenuItem(value:'1.375',child:Text('Lightly active')),
            DropdownMenuItem(value:'1.55',child:Text('Moderately active')),DropdownMenuItem(value:'1.725',child:Text('Very active')),DropdownMenuItem(value:'1.9',child:Text('Extra active'))
          ],onChanged:(v)=>setState(()=>activity=v!)),const SizedBox(height:14)
        ],
        FilledButton.icon(onPressed:calculate,icon:const Icon(Icons.calculate_outlined),label:const Text('Calculate')),
        if(result.isNotEmpty)...[
          const SizedBox(height:18),
          Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:const Color(0xFFE8F8EF),borderRadius:BorderRadius.circular(22)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Text('YOUR RESULT',style:TextStyle(color:green,fontWeight:FontWeight.w900,letterSpacing:1.5)),
            const SizedBox(height:9),Text(result,style:const TextStyle(fontSize:19,fontWeight:FontWeight.w900,height:1.4)),
          ])),
          const SizedBox(height:10),
          OutlinedButton.icon(onPressed:save,icon:const Icon(Icons.bookmark_add_outlined),label:const Text('Save result')),
        ],
        const SizedBox(height:18),
        const Text('For informational purposes only. This calculator does not provide medical advice.',style:TextStyle(color:muted,fontSize:12.5,height:1.4)),
      ]),
    );
  }

  Widget _field(String k) {
    const units={'weight':'Weight (lb)','height':'Height (in)','weightKg':'Weight (kg)','heightCm':'Height (cm)','age':'Age','neck':'Neck (cm)','waist':'Waist (cm)','hip':'Hip (cm)'};
    return TextField(controller:c[k],keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:units[k]));
  }
}

class MealPage extends StatefulWidget {
  final SharedPreferences prefs;
  const MealPage({super.key, required this.prefs});
  @override State<MealPage> createState()=>_MealPageState();
}

class _MealPageState extends State<MealPage>{
  final rows=<Map<String,TextEditingController>>[];
  @override void initState(){super.initState();addRow();}
  void addRow(){setState(()=>rows.add({for(final k in ['food','qty','cal','pro','carb','fat'])k:TextEditingController(text:k=='qty'?'1':'')}));}
  void remove(int i){for(final x in rows[i].values)x.dispose();setState(()=>rows.removeAt(i));}
  double sum(String key){double total=0;for(final row in rows){final value=double.tryParse(row[key]!.text)??0;final qty=double.tryParse(row['qty']!.text)??0;total+=value*qty;}return total;}
  @override void dispose(){for(final row in rows){for(final controller in row.values)controller.dispose();}super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Meal Calorie Calculator')),body:ListView(padding:const EdgeInsets.fromLTRB(16,8,16,30),children:[
    Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:soft,borderRadius:BorderRadius.circular(24)),child:const Text('Build your meal and see calories and macros instantly.',style:TextStyle(color:muted,fontSize:15,height:1.45))),
    const SizedBox(height:14),
    for(int i=0;i<rows.length;i++)Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(children:[
      Row(children:[Expanded(child:TextField(controller:rows[i]['food'],decoration:const InputDecoration(labelText:'Food'))),IconButton(onPressed:()=>remove(i),icon:const Icon(Icons.delete_outline))]),
      Row(children:[Expanded(child:_field(rows[i]['qty']!,'Qty')),Expanded(child:_field(rows[i]['cal']!,'Calories'))]),
      Row(children:[Expanded(child:_field(rows[i]['pro']!,'Protein g')),Expanded(child:_field(rows[i]['carb']!,'Carbs g')),Expanded(child:_field(rows[i]['fat']!,'Fat g'))]),
    ]))),
    const SizedBox(height:8),
    OutlinedButton.icon(onPressed:addRow,icon:const Icon(Icons.add),label:const Text('Add Food')),
    const SizedBox(height:14),
    Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:const Color(0xFFE8F8EF),borderRadius:BorderRadius.circular(22)),child:Text(
      'Calories: ${sum('cal').toStringAsFixed(1)} kcal\nProtein: ${sum('pro').toStringAsFixed(1)} g\nCarbs: ${sum('carb').toStringAsFixed(1)} g\nFat: ${sum('fat').toStringAsFixed(1)} g',
      style:const TextStyle(fontSize:17,fontWeight:FontWeight.w800,height:1.6),
    )),
  ]);
  Widget _field(TextEditingController controller,String label)=>Padding(padding:const EdgeInsets.all(4),child:TextField(controller:controller,onChanged:(_)=>setState((){}),keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:label)));
}

class SavedPage extends StatefulWidget {
  final SharedPreferences prefs;
  const SavedPage({super.key,required this.prefs});
  @override State<SavedPage> createState()=>_SavedPageState();
}
class _SavedPageState extends State<SavedPage>{
  @override Widget build(BuildContext context){final r=widget.prefs.getStringList('results')??[];return SafeArea(child:ListView(padding:const EdgeInsets.only(bottom:30),children:[
    const PageHeader(title:'Saved Results',subtitle:'Your recent calculator results stay on this device.'),
    if(r.isEmpty)Padding(padding:const EdgeInsets.all(20),child:Container(padding:const EdgeInsets.all(25),decoration:BoxDecoration(color:soft,borderRadius:BorderRadius.circular(22)),child:const Column(children:[Icon(Icons.bookmark_border,size:42,color:green),SizedBox(height:10),Text('No saved results yet.',style:TextStyle(fontWeight:FontWeight.w700))])))
    else ...r.map((x)=>Padding(padding:const EdgeInsets.fromLTRB(14,0,14,10),child:Card(child:ListTile(leading:const Icon(Icons.bookmark,color:green),title:Text(x))))),
  ]));}
}

class SettingsPage extends StatelessWidget{
  final SharedPreferences prefs;final bool dark;final ValueChanged<bool> onDark;
  const SettingsPage({super.key,required this.prefs,required this.dark,required this.onDark});
  @override Widget build(BuildContext context)=>SafeArea(child:ListView(padding:const EdgeInsets.only(bottom:30),children:[
    const PageHeader(title:'Settings',subtitle:'Keep FitCalcHub simple and personalized.'),
    Padding(padding:const EdgeInsets.symmetric(horizontal:14),child:Card(child:Column(children:[
      SwitchListTile(value:dark,onChanged:onDark,title:const Text('Dark mode',style:TextStyle(fontWeight:FontWeight.w700)),secondary:const Icon(Icons.dark_mode_outlined,color:green)),
      const Divider(height:1),
      const ListTile(leading:Icon(Icons.straighten_outlined,color:green),title:Text('Units',style:TextStyle(fontWeight:FontWeight.w700)),subtitle:Text('Calculator input units follow the FitCalcHub website.')),
      const Divider(height:1),
      const ListTile(leading:Icon(Icons.lock_outline,color:green),title:Text('Privacy',style:TextStyle(fontWeight:FontWeight.w700)),subtitle:Text('No account or backend is required. Saved results stay locally.')),
      const Divider(height:1),
      const ListTile(leading:Icon(Icons.info_outline,color:green),title:Text('Medical disclaimer',style:TextStyle(fontWeight:FontWeight.w700)),subtitle:Text('Results are estimates for informational use only.')),
    ]))),
  ]));
}
