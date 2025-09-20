import "package:shared_preferences/shared_preferences.dart";
import "../constants/storage_keys.dart" show themeKey;

abstract class ThemeRepository {
  Future<AppThemeMode> loadTheme();
  Future<void> saveTheme(AppThemeMode theme);
}

class LocalThemeRepository implements ThemeRepository {
  final SharedPreferences prefs;
  LocalThemeRepository(this.prefs);

  @override
  Future<AppThemeMode> loadTheme() async {
    final themeName = prefs.getString(themeKey) ?? AppThemeMode.light.name;
    return AppThemeMode.fromString(themeName);
  }

  @override
  Future<void> saveTheme(AppThemeMode theme) async {
    await prefs.setString(themeKey, theme.name);
  }
}

enum AppThemeMode {
  light,
  dark;

  factory AppThemeMode.fromString(String value) =>
      AppThemeMode.values.firstWhere((e) => e.name == value, orElse: () => AppThemeMode.light);
}
