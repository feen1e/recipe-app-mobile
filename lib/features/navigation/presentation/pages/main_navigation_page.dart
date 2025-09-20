import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "../../../../core/constants/app_strings.dart";
import "../../../../core/constants/routes.dart";

class MainNavigationPage extends ConsumerWidget {
  final Widget child;

  const MainNavigationPage({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: AppStrings.navHome),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: AppStrings.navDiscover),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: AppStrings.navCollections),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: AppStrings.navProfile),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(Routes.home)) return 0;
    if (location.startsWith(Routes.discoverRecipes)) return 1;
    if (location.startsWith(Routes.collections)) return 2;
    if (location.startsWith(Routes.profile)) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(Routes.home);
      case 1:
        context.go(Routes.discoverRecipes);
      case 2:
        context.go(Routes.collections);
      case 3:
        context.go(Routes.profile);
    }
  }
}
