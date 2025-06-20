// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sistema_ensalamento/pages/auth/login_page.dart';
import 'package:sistema_ensalamento/pages/auth/register_page.dart';
import 'package:sistema_ensalamento/pages/home_page.dart';
import 'package:sistema_ensalamento/pages/admin/admin_dashboard_page.dart';
import 'package:sistema_ensalamento/pages/professor/professor_dashboard_page.dart';
import 'package:sistema_ensalamento/pages/aluno/aluno_dashboard_page.dart';

// Import for localization
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rglajurvovpntdmwggra.supabase.co', // Cole sua Project URL aqui
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJnbGFqdXJ2b3ZwbnRkbXdnZ3JhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAzNjkyNzIsImV4cCI6MjA2NTk0NTI3Mn0.SowMvOYh6kVjdcrdYldAscmP5SM6KauzRca1cKAPjvo', // Cole sua anon public key aqui
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn && mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          Navigator.of(context).pushNamed('/home');
        }
      } else if (event == AuthChangeEvent.signedOut && mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green.shade700;
    final Color accentOrange = Colors.orange.shade700;
    const Color whiteColor = Colors.white;
    const Color lightGrey = Color(0xFFF5F5F5);

    return MaterialApp(
      title: 'Sistema de Ensalamento',
      // ADICIONADO: Remove a faixa "DEBUG"
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('pt', 'BR'), // Portuguese (Brazil)
      ],
      locale: const Locale('pt', 'BR'), // Set the default locale to Portuguese (Brazil)

      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: primaryGreen,
          secondary: accentOrange,
          onPrimary: whiteColor,
          onSecondary: whiteColor,
          surface: whiteColor,
          onSurface: Colors.black87,
          background: lightGrey,
          onBackground: Colors.black87,
          error: Colors.red.shade700,
          onError: whiteColor,
        ),
        scaffoldBackgroundColor: lightGrey,

        appBarTheme: AppBarTheme(
          backgroundColor: primaryGreen,
          foregroundColor: whiteColor,
          elevation: 4,
          titleTextStyle: const TextStyle(
            color: whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: whiteColor),
        ),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: accentOrange,
          foregroundColor: whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: whiteColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            elevation: 0,
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: accentOrange,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: whiteColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: primaryGreen, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade700),
          hintStyle: TextStyle(color: Colors.grey.shade500),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),

        cardTheme: CardThemeData(
          color: whiteColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        dialogTheme: DialogThemeData(
          backgroundColor: whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.red,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 6,
        ),

        listTileTheme: ListTileThemeData(
          selectedColor: primaryGreen,
          selectedTileColor: primaryGreen.withOpacity(0.1),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/admin_dashboard': (context) => const AdminDashboardPage(),
        '/professor_dashboard': (context) => const ProfessorDashboardPage(),
        '/aluno_dashboard': (context) => const AlunoDashboardPage(),
      },
    );
  }
}