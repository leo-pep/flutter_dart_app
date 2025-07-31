import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_page.dart';

void main() {
  runApp(DartScoreboardApp());
}

class DartScoreboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dart Scoreboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.light),
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.green.shade900,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.montserrat(
            color: Colors.green.shade900,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          color: Colors.white.withOpacity(0.7),
          shadowColor: Colors.black12,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(ThemeData(brightness: Brightness.dark).textTheme),
        scaffoldBackgroundColor: const Color(0xFF181A20),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          color: const Color(0xFF23272F).withOpacity(0.85),
          shadowColor: Colors.black54,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          fillColor: const Color(0xFF23272F),
          filled: true,
          labelStyle: TextStyle(color: Colors.white70),
          hintStyle: TextStyle(color: Colors.white38),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            fillColor: const Color(0xFF23272F),
            filled: true,
            labelStyle: TextStyle(color: Colors.white70),
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: HomePage(),
    );
  }
}

