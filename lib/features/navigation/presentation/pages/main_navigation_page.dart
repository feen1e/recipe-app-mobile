import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../../core/constants/routes.dart";
import "../../../../l10n/app_localizations.dart";

class MainNavigationPage extends ConsumerWidget {
  final Widget child;

  const MainNavigationPage({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        selectedItemColor: t.colorScheme.primary,
        selectedIconTheme: IconThemeData(color: t.colorScheme.primary),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: AppLocalizations.of(context).navHome),
          //BottomNavigationBarItem(icon: const Icon(Icons.restaurant), label: AppLocalizations.of(context).navDiscover),
          BottomNavigationBarItem(icon: const Icon(Icons.favorite), label: AppLocalizations.of(context).collections),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: AppLocalizations.of(context).navProfile),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(Routes.home)) return 0;
    //if (location.startsWith(Routes.discoverRecipes)) return 1;
    if (location.startsWith(Routes.collections)) return 1;
    if (location.startsWith(Routes.profile)) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(Routes.home);
      //case 1:
      //  context.go(Routes.discoverRecipes);
      case 1:
        context.go(Routes.collections);
      case 2:
        context.go(Routes.profile);
    }
  }
}
