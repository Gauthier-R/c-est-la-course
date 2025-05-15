import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'providers/meal_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/weekly_list_screen.dart';
import 'screens/history_overview_screen.dart';
import 'screens/main_screen.dart';
import 'screens/current_week_list_screen.dart';
import 'screens/next_week_list_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dinners_app/utils/date_format.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await Firebase.initializeApp();

  
  final weekKey = getWeekKey(DateTime.now());
  print("✅ Correct weekKey: $weekKey");


  final mealProvider = MealProvider();
  await mealProvider.preloadAllMeals();
  mealProvider.startLiveSync(); // ✅ Synchronisation en temps réel


  runApp(
    ChangeNotifierProvider.value(
      value: mealProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dinners App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryOrange),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const MainScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/week' && settings.arguments is DateTime) {
          return MaterialPageRoute(
            builder: (_) => WeeklyListScreen(weekStart: settings.arguments as DateTime),
          );
        }
        if (settings.name == '/history') {
          return MaterialPageRoute(
            builder: (_) => const HistoryOverviewScreen(),
          );
        }
        if (settings.name == '/current_week') {
          return MaterialPageRoute(
            builder: (_) => const CurrentWeekListScreen(),
          );
        }
        if (settings.name == '/next_week') {
          return MaterialPageRoute(
            builder: (_) => const NextWeekListScreen(),
          );
        }
        return null;
      },
    );
  }
}
