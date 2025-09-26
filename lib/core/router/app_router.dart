import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../features/auth/data/models/auth_state.dart";
import "../../features/auth/presentation/pages/login_page.dart";
import "../../features/auth/presentation/pages/register_page.dart";
import "../../features/auth/presentation/providers/auth_provider.dart";
import "../../features/collections/presentation/pages/collections_page.dart";
import "../../features/create_or_update_recipe/presentation/pages/create_or_update_recipe_page.dart";
import "../../features/discover_recipes/presentation/pages/discover_recipes_page.dart";
import "../../features/home/presentation/pages/home_page.dart";
import "../../features/navigation/presentation/pages/main_navigation_page.dart";
import "../../features/profile/presentation/pages/profile_page.dart";
import "../../features/recipe_details/data/models/recipe.dart";
import "../../features/recipe_details/presentation/pages/recipe_details_page.dart";
import "../constants/routes.dart";

part "app_router.g.dart";

class AuthRouterListener extends ChangeNotifier {
  AuthRouterListener(this.ref) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      notifyListeners();
    });
  }

  final Ref ref;
}

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: AuthRouterListener(ref),
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isGoingToLogin = state.uri.path == Routes.login;
      final isGoingToRegister = state.uri.path == Routes.register;

      return authState.maybeWhen(
        unauthenticated: () => (isGoingToLogin || isGoingToRegister) ? null : Routes.login,
        authenticated: () => (isGoingToLogin || isGoingToRegister) ? Routes.home : null,
        orElse: () => null,
      );
    },
    routes: [
      GoRoute(path: Routes.login, builder: (context, state) => const LoginPage()),
      GoRoute(path: Routes.register, builder: (context, state) => const RegisterPage()),
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
      GoRoute(
        path: Routes.createOrUpdateRecipe,
        builder: (context, state) {
          final recipe = state.extra as RecipeDetailsDto?;
          return CreateOrUpdateRecipePage(recipe: recipe);
        },
      ),
      GoRoute(
        path: "${Routes.recipeDetails}/:id",
        builder: (context, state) => RecipeDetailsPage(recipeId: state.pathParameters["id"]!),
      ),
    ],
  );
}
