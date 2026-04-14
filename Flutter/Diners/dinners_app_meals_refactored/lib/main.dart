import 'package:flutter/material.dart'; // 📱 Base pour toute application Flutter
import 'package:google_fonts/google_fonts.dart'; // 🔤 Utilisation de polices Google personnalisées
import 'utils/app_colors.dart'; // 🎨 Fichier perso pour les couleurs de l'app
import 'package:provider/provider.dart'; // 📦 Gestion des états via Provider
import 'providers/meal_provider.dart'; // 🍽️ Logique métier liée aux repas
import 'providers/recipe_provider.dart'; // 📖 Logique métier liée aux recettes
import 'package:intl/date_symbol_data_local.dart'; // 📅 Données locales pour le formatage de dates
import 'screens/weekly_list_screen.dart'; // 📋 Écran de la liste hebdo
import 'screens/history_overview_screen.dart'; // 📚 Historique des repas
import 'screens/sandbox_main_screen.dart'; // 🏠 Nouvel écran principal (design premium)
import 'screens/current_week_list_screen.dart'; // 📅 Liste des repas de la semaine actuelle
import 'screens/next_week_list_screen.dart'; // 🔮 Liste des repas de la semaine suivante
import 'package:firebase_core/firebase_core.dart'; // 🔥 Nécessaire pour utiliser Firebase
import 'package:firebase_app_check/firebase_app_check.dart'; // 🛡️ Sécurisation via App Check
import 'package:dinners_app/utils/date_format.dart'; // 🕒 Formatage personnalisé des dates

import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/email_verification_screen.dart';

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
  );

  // 🗓️ Génération de la clé de semaine en cours (utile pour l'organisation des repas)
  final weekKey = getWeekKey(DateTime.now());
  debugPrint("✅ Correct weekKey: $weekKey");

  // 🧠 Intégration des providers à toute l'application Flutter
  // NOTE: Preload et liveSync sont délégués aux providers lorsque updateGroupId est appelé par AuthProvider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, MealProvider>(
          create: (_) => MealProvider(),
          update: (_, auth, meal) => meal!..updateGroupId(auth.currentGroupId),
        ),
        ChangeNotifierProxyProvider<AuthProvider, RecipeProvider>(
          create: (_) => RecipeProvider(),
          update: (_, auth, recipe) => recipe!..updateGroupId(auth.currentGroupId),
        ),
      ],
      child: const MyApp(), // 🏁 Lancement de l'application
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Transition slide propre (style iOS) — élimine l'effet "rétrécissement"
    // du predictive back de Material 3 sur Android
    const pageTransition = PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    );

    return MaterialApp(
      title: "C'est la course",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryOrange),
        scaffoldBackgroundColor: AppColors.background,
        pageTransitionsTheme: pageTransition,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const AuthWrapper(),
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


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (auth.authUser == null) {
          return const AuthScreen();
        }
        // ✅ Les comptes Google sont toujours vérifiés côté provider,
        // pas besoin de vérifier l'email pour eux.
        final isGoogleUser = auth.authUser!.providerData
            .any((p) => p.providerId == 'google.com');
        if (!auth.authUser!.emailVerified && !isGoogleUser) {
          return const EmailVerificationScreen();
        }
        return const SandboxMainScreen();
      },
    );
  }
}
