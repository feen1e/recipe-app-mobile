import "dart:async";
import "dart:ui";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../constants/storage_keys.dart" show localeKey;

part "locale_provider.g.dart";

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale? build() {
    // kick off async loading, initial state is null (follow system)
    unawaited(_load());
    return null;
  }

  Future<void> _load() async {
    final start = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(localeKey);
    if (code != null && code.isNotEmpty) {
      if (code.contains("_")) {
        final parts = code.split("_");
        state = Locale(parts[0], parts.length > 1 ? parts[1] : null);
      } else {
        state = Locale(code);
      }
      final end = DateTime.now();
      // ignore: avoid_print
      print("LocaleNotifier._load took ${end.difference(start).inMilliseconds}ms");
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final start = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final stored = locale.countryCode != null && locale.countryCode!.isNotEmpty
        ? "${locale.languageCode}_${locale.countryCode}"
        : locale.languageCode;
    await prefs.setString(localeKey, stored);
    final end = DateTime.now();
    // ignore: avoid_print
    print("LocaleNotifier.setLocale took ${end.difference(start).inMilliseconds}ms");
  }

  Future<void> clearLocale() async {
    state = null;
    final start = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(localeKey);
    final end = DateTime.now();
    // ignore: avoid_print
    print("LocaleNotifier.clearLocale took ${end.difference(start).inMilliseconds}ms");
  }
}
