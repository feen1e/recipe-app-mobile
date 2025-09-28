import "package:flutter/material.dart";

abstract interface class AppThemeData {
  ThemeData get light => ThemeData.light();
  ThemeData get dark => ThemeData.dark();
}

class AppTheme implements AppThemeData {
  @override
  ThemeData get light => ThemeData(
    colorScheme: const ColorScheme.light(primary: ColorConsts.primary),
    scaffoldBackgroundColor: ColorConsts.background,
    appBarTheme: _appBarTheme,
    textTheme: _textTheme,
    useMaterial3: true,
    cardTheme: _cardTheme.data,
    inputDecorationTheme: _inputDecorationTheme,
    elevatedButtonTheme: elevatedButtonTheme,
    dividerTheme: DividerThemeData(color: Colors.grey[700]),
  );

  @override
  ThemeData get dark => ThemeData(
    colorScheme: const ColorScheme.dark(primary: ColorConsts.primary, onPrimary: ColorConsts.onPrimary),
    scaffoldBackgroundColor: Colors.grey[900],
    textTheme: _textTheme.apply(bodyColor: Colors.white),
    appBarTheme: _appBarTheme.copyWith(backgroundColor: Colors.grey[900], foregroundColor: Colors.white),
    useMaterial3: true,
    cardTheme: _cardTheme.copyWith(color: Colors.grey[800]).data,
    inputDecorationTheme: _inputDecorationTheme.copyWith(fillColor: Colors.grey[900]),
    elevatedButtonTheme: elevatedButtonTheme,
    dividerTheme: DividerThemeData(color: Colors.grey[700]),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colors.grey[900]),
  );
}

const _textTheme = TextTheme(
  headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
  headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
  headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  bodyLarge: TextStyle(fontSize: 16),
  bodyMedium: TextStyle(fontSize: 14),
  titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
);

const _appBarTheme = AppBarTheme(
  backgroundColor: Colors.white,
  foregroundColor: ColorConsts.onSecondary,
  elevation: 0,
  surfaceTintColor: Colors.transparent,
);

final _cardTheme = CardTheme(
  color: ColorConsts.surface,
  elevation: 2,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
);

final _inputDecorationTheme = InputDecorationTheme(
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  filled: true,
  fillColor: ColorConsts.surface,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  floatingLabelBehavior: FloatingLabelBehavior.always,
  hintStyle: const TextStyle(color: Colors.grey),
);

final elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: ColorConsts.primary,
    foregroundColor: ColorConsts.onPrimary,
    textStyle: _textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: ColorConsts.onPrimary),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
);

class ColorConsts {
  static const primary = Color.fromARGB(255, 200, 40, 40);
  static const surface = Color.fromARGB(255, 255, 255, 255);
  static const background = Color(0xFFFFFFFF);
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const brightRed = Color.fromARGB(255, 220, 53, 69);
  static const mutedRed = Color.fromARGB(255, 178, 60, 65);
  static const crimson = Color.fromARGB(255, 153, 27, 30);
}
