import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "../providers/shared_preferences_provider.dart";
import "local_theme_repository.dart";

part "theme_notifier.g.dart";

@Riverpod(keepAlive: true)
Future<ThemeRepository> themeRepository(Ref ref) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  return LocalThemeRepository(prefs);
}

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  Future<AppThemeMode> build() async {
    final repository = await ref.read(themeRepositoryProvider.future);
    return repository.loadTheme();
  }

  Future<void> toggleTheme() async {
    final repository = await ref.read(themeRepositoryProvider.future);
    final myState = state.valueOrNull ?? AppThemeMode.light;
    final newTheme = myState == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
    state = AsyncValue.data(newTheme);
    await repository.saveTheme(newTheme);
  }
}
