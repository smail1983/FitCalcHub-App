import 'dart:math' as math;
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
    scaffoldBackgroundColor: brightness == Brightness.dark ? const Color(0xFF0B1726) : const Color(0xFFF7FAF8),
    appBarTheme: AppBarTheme(
      backgroundColor: brightness == Brightness.dark ? const Color(0xFF0B1726) : Colors.white,
      foregroundColor: brightness == Brightness.dark ? Colors.white : ink,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardTheme(
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
  @override Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(children: [
      Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: green,
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Icon(Icons.monitor_heart_outlined, color: Colors.white, size: 25),
      ),
      const SizedBox(width: 10),
      RichText(text: TextSpan(
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: dark ? Colors.white : ink,
          letterSpacing: -0.7,
        ),
        children: const [
          TextSpan(text: 'FitCalc'),
          TextSpan(text: 'Hub', style: TextStyle(color: green)),
        ],
      )),
    ]);
  }
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

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final card = dark ? const Color(0xFF132231) : const Color(0xFFF0F5F2);
    final border = dark ? const Color(0xFF263847) : const Color(0xFFDDE6E1);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
            child: const Brand(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
            child: Text(
              'Simple, free health & fitness calculators.',
              style: TextStyle(
                color: dark ? const Color(0xFFCBD5DE) : const Color(0xFF334155),
                fontSize: 17,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Popular calculators — intentionally simple like the website's mobile layout.
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 25),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x100F172A),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Popular calculators',
                  style: TextStyle(
                    color: dark ? Colors.white : ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    _homeCalculatorButton(context, Calc.bmi),
                    _homeCalculatorButton(context, Calc.tdee),
                    _homeCalculatorButton(context, Calc.bmr),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          _infoCard(
            context,
            title: 'Free & private',
            body: 'Calculations run locally on your device. No account or backend is required.',
          ),

          const SizedBox(height: 20),

          _infoCard(
            context,
            title: 'Important',
            body: 'Results are estimates for informational use and are not medical advice.',
          ),

          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Latest articles', style: TextStyle(
                  color: dark ? Colors.white : ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                )),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArticlesPage())),
                  child: const Text('View all', style: TextStyle(color: green, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          ...appArticles.take(3).map((article) => Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: ArticleCard(article: article),
          )),
        ],
      ),
    );
  }

  Widget _homeCalculatorButton(BuildContext context, Calc calc) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onOpen(calc),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minWidth: 150, minHeight: 58),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF172A39) : const Color(0xFFF8FBF9),
            border: Border.all(
              color: dark ? const Color(0xFF60717D) : const Color(0xFF7D8B86),
              width: 1.6,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            calcName(calc),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: dark ? Colors.white : ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 21),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF132231) : const Color(0xFFF0F5F2),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: dark ? const Color(0xFF263847) : const Color(0xFFDDE6E1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 9,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: dark ? Colors.white : ink,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            body,
            style: TextStyle(
              color: dark ? const Color(0xFFCBD5DE) : muted,
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}


class Article {
  final String category;
  final String title;
  final String summary;
  final String body;
  final IconData icon;
  final String imageUrl;
  const Article({required this.category, required this.title, required this.summary, required this.body, required this.icon, required this.imageUrl});
}

const appArticles = <Article>[
  Article(
    category: 'Nutrition',
    title: 'How Many Calories Should I Eat a Day?',
    summary: 'Understand daily calorie needs and the factors that affect them.',
    icon: Icons.restaurant_outlined,
    imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&w=1200&q=80',
    body: 'Daily calorie needs vary from person to person. Age, body size, sex, activity level and goals all influence how much energy you may need.\\n\\nA useful starting point is to estimate your basal metabolic rate (BMR), then account for activity to estimate total daily energy expenditure (TDEE). These numbers are estimates, not exact measurements.\\n\\nUse the FitCalcHub BMR and TDEE calculators as a starting point, then consider your real-world progress and professional guidance when appropriate.',
  ),
  Article(
    category: 'Fitness',
    title: 'BMR vs TDEE: What Is the Difference?',
    summary: 'Learn how these two calorie estimates are different and when they are useful.',
    icon: Icons.local_fire_department_outlined,
    imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=1200&q=80',
    body: 'BMR is an estimate of the energy your body uses at rest to support basic functions. TDEE is an estimate of your total daily energy expenditure after activity is included.\\n\\nBecause activity changes from day to day, TDEE is best viewed as an estimate rather than a fixed number. Understanding the difference can make calorie planning easier to interpret.\\n\\nFitCalcHub provides separate BMR and TDEE calculators so you can explore both estimates.',
  ),
  Article(
    category: 'Nutrition',
    title: 'How Much Protein Do I Need?',
    summary: 'A practical guide to protein intake for everyday fitness goals.',
    icon: Icons.egg_alt_outlined,
    imageUrl: 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=1200&q=80',
    body: 'Protein is an important nutrient used to build and maintain body tissues. The amount a person needs depends on factors such as body size, age, activity and overall diet.\\n\\nFor active people, spreading protein-containing foods across meals can be a practical way to include it regularly. Foods such as eggs, dairy, fish, meat, beans and lentils can all contribute protein.\\n\\nIndividual needs can differ, so use general guidance as a starting point rather than a medical prescription.',
  ),
  Article(
    category: 'Health',
    title: 'Understanding BMI: What It Can and Cannot Tell You',
    summary: 'Learn what BMI measures and why it should be interpreted with context.',
    icon: Icons.monitor_weight_outlined,
    imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=1200&q=80',
    body: 'Body Mass Index (BMI) is calculated from height and weight. It is commonly used as a screening measure, but it does not directly measure body fat or distinguish muscle from fat.\\n\\nFor that reason, BMI is most useful when considered alongside other information such as waist measurement, body composition, fitness and overall health.\\n\\nThe FitCalcHub BMI calculator provides an estimate for informational use and is not a diagnosis.',
  ),
];

class ArticlesPage extends StatelessWidget {
  const ArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Articles')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: dark
                ? const [Color(0xFF0B1726), Color(0xFF102332)]
                : const [Color(0xFFF7FBF8), Color(0xFFEAF5EF)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 35),
          children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF132231) : const Color(0xFFF0F7F3),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: dark ? const Color(0xFF263847) : const Color(0xFFDDE8E2)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Learn & improve', style: TextStyle(color: green, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                SizedBox(height: 6),
                Text('Health & fitness articles', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: -0.7)),
                SizedBox(height: 7),
                Text('Practical information to help you understand your health, nutrition and fitness goals.', style: TextStyle(color: muted, height: 1.45)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...appArticles.map((article) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ArticleCard(article: article),
          )),
          ],
        ),
      ),
    );
  }
}

class ArticleCard extends StatelessWidget {
  final Article article;
  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleDetailPage(article: article))),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: line),
          boxShadow: const [BoxShadow(color: Color(0x0B0F172A), blurRadius: 16, offset: Offset(0, 5))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: SizedBox(
                width: 78,
                height: 78,
                child: Image.network(
                  article.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE8F8EF),
                    child: Icon(article.icon, color: green, size: 28),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(article.category.toUpperCase(), style: const TextStyle(color: green, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                const SizedBox(height: 5),
                Text(article.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, height: 1.2)),
                const SizedBox(height: 6),
                Text(article.summary, style: const TextStyle(color: muted, fontSize: 13, height: 1.4)),
                const SizedBox(height: 9),
                const Text('Read article →', style: TextStyle(color: green, fontWeight: FontWeight.w900, fontSize: 13)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  final Article article;
  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(article.category)),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 35),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: SizedBox(
            width: double.infinity,
            height: 210,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  article.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE8F8EF),
                    child: Icon(article.icon, color: green, size: 72),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(.45)],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      article.category,
                      style: const TextStyle(color: green, fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(article.category.toUpperCase(), style: const TextStyle(color: green, fontWeight: FontWeight.w900, letterSpacing: 1.3, fontSize: 12)),
        const SizedBox(height: 7),
        Text(article.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -1)),
        const SizedBox(height: 13),
        Text(article.summary, style: const TextStyle(color: muted, fontSize: 16, height: 1.5)),
        const SizedBox(height: 24),
        ...article.body.split('\\n\\n').map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(p, style: const TextStyle(fontSize: 16, height: 1.65)),
        )),
        const SizedBox(height: 8),
        const Text('For informational purposes only. This article does not provide medical advice.', style: TextStyle(color: muted, fontSize: 12.5, height: 1.45)),
      ],
    ),
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

  double log10(double x) => math.log(x) / math.ln10;

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
  ]));
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
