import 'package:dinners_app/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'providers/meal_provider.dart';
import 'providers/weekly_list_provider.dart'; // <-- à importer
import 'package:intl/date_symbol_data_local.dart';
import 'screens/weekly_list_screen.dart';
import 'screens/history_list_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await Firebase.initializeApp();

  final mealProvider = MealProvider();
  await mealProvider.loadMealsFromFirebase(); // 🔄 On charge les repas dès le lancement

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => mealProvider),
        ChangeNotifierProvider(create: (_) => WeeklyListProvider()),
      ],
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
          Theme.of(context).textTheme
        ),
      ),
      home: const MainScreen(),
      routes: {
        '/week': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as DateTime;
          return WeeklyListScreen(weekStart: args);
        },
        '/history': (context) => const HistoryListScreen(),
      },
    );
  }
}
