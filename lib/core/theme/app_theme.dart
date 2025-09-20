import "package:flutter/material.dart";

abstract interface class AppThemeData {
  ThemeData get light => ThemeData.light();
  ThemeData get dark => ThemeData.dark();
}

class AppTheme implements AppThemeData {
  @override
  ThemeData get light => ThemeData(
    colorScheme: const ColorScheme.light(primary: ColorConsts.primary, surface: ColorConsts.surface),
    scaffoldBackgroundColor: ColorConsts.background,
    appBarTheme: _appBarTheme,
    textTheme: _textTheme,
    useMaterial3: true,
  );

  @override
  ThemeData get dark => ThemeData(
    colorScheme: ColorScheme.dark(
      primary: ColorConsts.primary,
      surface: Colors.grey[850]!,
      onPrimary: ColorConsts.onPrimary,
    ),
    scaffoldBackgroundColor: Colors.grey[900],
    textTheme: _textTheme.apply(bodyColor: Colors.white),
    appBarTheme: _appBarTheme.copyWith(backgroundColor: Colors.grey[850]),
    useMaterial3: true,
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

const _appBarTheme = AppBarTheme(backgroundColor: ColorConsts.primary, foregroundColor: ColorConsts.onPrimary);

class ColorConsts {
  static const primary = Color.fromARGB(255, 200, 40, 40);
  static const surface = Color(0xFFFDF3F3);
  static const background = Color(0xFFFFFFFF);
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const brightRed = Color.fromARGB(255, 220, 53, 69);
  static const mutedRed = Color.fromARGB(255, 178, 60, 65);
  static const crimson = Color.fromARGB(255, 153, 27, 30);
}
