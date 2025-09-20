import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../features/collections/presentation/pages/collections_page.dart";
import "../../features/discover_recipes/presentation/pages/discover_recipes_page.dart";
import "../../features/home/presentation/pages/home_page.dart";
import "../../features/navigation/presentation/pages/main_navigation_page.dart";
import "../../features/profile/presentation/pages/profile_page.dart";
import "../constants/routes.dart";

part "app_router.g.dart";

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationPage(child: child);
        },
        routes: [
          GoRoute(path: Routes.home, builder: (context, state) => const HomePage()),
          GoRoute(path: Routes.discoverRecipes, builder: (context, state) => const DiscoverRecipesPage()),
          GoRoute(path: Routes.collections, builder: (context, state) => const CollectionsPage()),
          GoRoute(path: Routes.profile, builder: (context, state) => const ProfilePage()),
        ],
      ),
    ],
  );
}
