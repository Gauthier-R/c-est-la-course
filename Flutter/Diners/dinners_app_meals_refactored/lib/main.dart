import 'package:flutter/material.dart'; // 📱 Base pour toute application Flutter
import 'package:google_fonts/google_fonts.dart'; // 🔤 Utilisation de polices Google personnalisées
import 'utils/app_colors.dart'; // 🎨 Fichier perso pour les couleurs de l'app
import 'package:provider/provider.dart'; // 📦 Gestion des états via Provider
import 'providers/meal_provider.dart'; // 🍽️ Logique métier liée aux repas
import 'package:intl/date_symbol_data_local.dart'; // 📅 Données locales pour le formatage de dates
import 'screens/weekly_list_screen.dart'; // 📋 Écran de la liste hebdo
import 'screens/history_overview_screen.dart'; // 📚 Historique des repas
import 'screens/main_screen.dart'; // 🏠 Écran principal
import 'screens/current_week_list_screen.dart'; // 📅 Liste des repas de la semaine actuelle
import 'screens/next_week_list_screen.dart'; // 🔮 Liste des repas de la semaine suivante
import 'package:firebase_core/firebase_core.dart'; // 🔥 Nécessaire pour utiliser Firebase
import 'package:firebase_app_check/firebase_app_check.dart'; // 🛡️ Sécurisation via App Check
import 'package:dinners_app/utils/date_format.dart'; // 🕒 Formatage personnalisé des dates

void main() async {
  // 🔧 Préparation des widgets Flutter avant toute opération asynchrone
  WidgetsFlutterBinding.ensureInitialized();
  // 🌍 Chargement des données locales pour le formatage français
  await initializeDateFormatting('fr_FR', null);

  // 🔥 Initialisation de Firebase pour activer tous les services (Firestore, Auth, etc.)
  await Firebase.initializeApp();

  // 🛡️ Activation de App Check en mode Debug (utile pour éviter les blocages en dev)
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // ✅ On utilise le fournisseur debug car l'app n'est pas publiée
    isTokenAutoRefreshEnabled: true, // 🔄 Firebase régénère automatiquement le jeton toutes les 30 min
  );

  // 🗓️ Génération de la clé de semaine en cours (utile pour l'organisation des repas)
  final weekKey = getWeekKey(DateTime.now());
  print("✅ Correct weekKey: $weekKey"); // 🖨️ Affichage dans la console pour vérification

  // 🍽️ Instanciation du provider pour la gestion des repas
  final mealProvider = MealProvider();

  // 🚀 Préchargement des repas (optimise les performances et évite les chargements lents)
  await mealProvider.preloadAllMeals();

  // 🔄 Synchronisation des données avec Firestore en temps réel
  mealProvider.startLiveSync();

  // 🧠 Intégration du provider à toute l'application Flutter
  runApp(
    ChangeNotifierProvider.value(
      value: mealProvider,
      child: const MyApp(), // 🏁 Lancement de l'application
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
