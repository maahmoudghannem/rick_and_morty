// ============================================================
// main.dart
// Application entry point. Configures the top-level MaterialApp
// with a unified dark theme and launches the characters list.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  // Ensure Flutter engine is ready before calling platform channels
  WidgetsFlutterBinding.ensureInitialized();

  // Make the status bar transparent so our dark background shows through
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // White icons on dark bg
      systemNavigationBarColor: Color(0xFF0A0A14),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const RickAndMortyApp());
}

/// The root widget of the application.
/// Configures [MaterialApp] with a shared dark theme used by all screens.
class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rick & Morty',

      // Hide the debug banner from the top-right corner
      debugShowCheckedModeBanner: false,

      // ── Global Theme ─────────────────────────────────────────────────
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        // Deep space black as the universal scaffold background
        scaffoldBackgroundColor: const Color(0xFF0A0A14),

        // Colour scheme: cyan primary, green secondary, on a dark surface
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C8E8),
          brightness: Brightness.dark,
          primary: const Color(0xFF00C8E8),
          secondary: const Color(0xFF9ADE07),
          surface: const Color(0xFF141428),
        ),

        // Default AppBar appearance (individual screens may override parts)
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0A14),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),

        // Smooth page transitions throughout the app
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),

      // The first screen shown when the app launches
      home: const CharacterListScreen(),
    );
  }
}