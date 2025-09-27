import "dart:developer";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../../core/constants/routes.dart";
import "../../../../core/theme/local_theme_repository.dart";
import "../../../../core/theme/theme_notifier.dart";
import "../../../../l10n/app_localizations.dart";
import "../../../auth/presentation/providers/auth_provider.dart";
import "../../data/models/profile.dart";
import "../providers/profile_provider.dart";

class ProfilePage extends ConsumerWidget {
  final String? username;
  const ProfilePage({super.key, this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String currentUsername = ref
        .watch(currentUsernameProvider)
        .maybeWhen(data: (currentUsername) => currentUsername ?? "", orElse: () => "");

    log("Building ProfilePage for username: $username");

    final completeProfileAsync = ref.watch(completeProfileProvider(username ?? currentUsername));

    return Scaffold(
      appBar: _buildAppBar(context, ref, username),
      body: completeProfileAsync.when(
        data: (completeProfile) => RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(completeProfileProvider(username ?? currentUsername).notifier)
                .refresh(username ?? currentUsername);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                _buildProfileHeader(
                  context,
                  completeProfile.profile,
                  completeProfile.recipes.length,
                  completeProfile.ratings.length,
                ),
                const SizedBox(height: 24),

                // User's Recipes Section
                _buildRecipesSection(context, completeProfile.recipes),
                const SizedBox(height: 24),

                // User's Ratings Section
                _buildRatingsSection(context, completeProfile.ratings),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text("Error: $error"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(completeProfileProvider(username ?? currentUsername));
                },
                child: Text(AppLocalizations.of(context).retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref, String? username) {
    if (username == null || username.isEmpty) {
      final theme = ref.watch(themeNotifierProvider).value;
      return AppBar(
        title: Text(AppLocalizations.of(context).profile),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == "logout") {
                final authNotifier = ref.read(authNotifierProvider.notifier);
                await authNotifier.logout();
              }
              if (value == "theme") {
                final themeNotifier = ref.read(themeNotifierProvider.notifier);
                await themeNotifier.toggleTheme();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: "logout",
                child: Row(
                  children: [
                    const Icon(Icons.logout),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context).logout),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: "theme",
                child: Row(
                  children: [
                    Icon(theme == AppThemeMode.light ? Icons.dark_mode : Icons.light_mode),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context).switchTheme),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.settings),
          ),
        ],
      );
    } else {
      return AppBar();
    }
  }

  Widget _buildProfileHeader(BuildContext context, Profile profile, int actualRecipesCount, int actualRatingsCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 85,
              backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
              child: profile.avatarUrl == null
                  ? Text(
                      profile.username.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // User Info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(profile.username, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem(AppLocalizations.of(context).recipes, actualRecipesCount),
                      const SizedBox(width: 50),
                      _buildStatItem(AppLocalizations.of(context).ratings, actualRatingsCount),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (profile.bio != null) ...[
          const SizedBox(height: 16),
          Text(profile.bio!, style: const TextStyle(fontSize: 16)),
        ],
      ],
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(count.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRecipesSection(BuildContext context, List<Recipe> recipes) {
    final gridRows = recipes.length == 1
        ? 1
        : recipes.length == 2
        ? 2
        : 3;
    final gridHeight = gridRows * 120.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).myRecipes, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        if (recipes.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.restaurant, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context).noRecipesYet, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: gridHeight,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridRows,
                childAspectRatio: 0.35,
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
              ),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return _buildRecipeCard(recipe, context);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRecipeCard(Recipe recipe, BuildContext context) {
    return InkWell(
      onTap: () async {
        await context.push("${Routes.recipeDetails}/${recipe.id}");
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // Recipe Image
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: recipe.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: recipe.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.restaurant, size: 32),
                        )
                      : const Icon(Icons.restaurant, size: 32),
                ),
              ),
              const SizedBox(width: 10),
              // Recipe Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (recipe.description != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        recipe.description!,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingsSection(BuildContext context, List<Rating> ratings) {
    final gridRows = ratings.length == 1
        ? 1
        : ratings.length == 2
        ? 2
        : 3;
    final gridHeight = gridRows * 120.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).myRatings, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        if (ratings.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.star_border, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context).noRatingsYet, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: gridHeight,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridRows,
                childAspectRatio: 0.35,
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
              ),
              itemCount: ratings.length,
              itemBuilder: (context, index) {
                final rating = ratings[index];
                return _buildRatingCard(rating);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRatingCard(Rating rating) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stars
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating.stars ? Icons.star : Icons.star_border,
                      color: index < rating.stars ? Colors.amber : Colors.grey,
                      size: 18,
                    );
                  }),
                ),
                const SizedBox(height: 3),
                Text("${rating.stars}/5", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(width: 10),
            // Rating Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    rating.recipeName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (rating.review != null && rating.review!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      rating.review!,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
