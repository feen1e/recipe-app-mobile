import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:logging/logging.dart";
import "core/router/app_router.dart";
import "core/theme/app_theme.dart";
import "core/theme/local_theme_repository.dart";
import "core/theme/theme_notifier.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print("${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}");
    }
  });

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeNotifierProvider);
    final themeMode = themeAsync.valueOrNull ?? AppThemeMode.light;
    final appTheme = switch (themeMode) {
      AppThemeMode.light => AppTheme().light,
      AppThemeMode.dark => AppTheme().dark,
    };

    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(title: "Recipe App", theme: appTheme, routerConfig: router);
  }
}
