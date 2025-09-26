import "dart:async";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../../core/constants/routes.dart";
import "../../../auth/presentation/providers/auth_provider.dart";
import "../../../collections/presentation/providers/collections_provider.dart";
import "../providers/recipe_details_provider.dart";
import "../providers/user_info_provider.dart";

class RecipeDetailsPage extends ConsumerWidget {
  final String recipeId;

  const RecipeDetailsPage({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeDetails = ref.watch(recipeDetailsProvider(recipeId));
    return recipeDetails.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) {
        unawaited(
          Future.microtask(() {
            if (context.mounted) {
              context.pop();
            }
          }),
        );
        return const SizedBox.shrink();
      },
      data: (recipe) {
        final userInfo = ref.watch(userInfoProvider(recipe.authorId));
        final userId = ref.watch(currentUserIdProvider);
        final isFavorite = ref.watch(favoritesProvider).value?.any((fav) => fav.id == recipe.id) ?? false;

        final avatarExists = userInfo.value?.avatarUrl != null;

        return Scaffold(
          appBar: AppBar(
            title: Text(recipe.title),
            actions: [
              userId.when(
                loading: () => const SizedBox.shrink(),
                error: (error, stackTrace) => const SizedBox.shrink(),
                data: (id) => id == recipe.authorId
                    ? Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              await context.push(Routes.createOrUpdateRecipe, extra: recipe);
                              ref.invalidate(recipeDetailsProvider(recipeId));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await ref.read(recipeDetailsRepositoryProvider).deleteRecipe(recipeId).then((_) {
                                if (context.mounted) {
                                  context.pop();
                                }
                              });
                            },
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              IconButton(
                icon: isFavorite ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border),
                onPressed: () async {
                  if (isFavorite) {
                    await ref.read(collectionsRepositoryProvider).removeFavorite(recipeId);
                  } else {
                    await ref.read(collectionsRepositoryProvider).addFavorite(recipeId);
                  }
                  ref.invalidate(favoritesProvider);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //User Header
                userInfo.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stackTrace) => Text("Error loading user info: $error"),
                  data: (user) => Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: avatarExists ? CachedNetworkImageProvider(user.avatarUrl!) : null,
                        child: !avatarExists ? Text(user.username.substring(0, 1).toUpperCase()) : null,
                      ),
                      const SizedBox(width: 10),
                      Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                // Recipe Image
                if (recipe.imageUrl != null)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: recipe.imageUrl!,
                          width: double.infinity,
                          height: 350,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) {
                            return Container(
                              width: double.infinity,
                              height: 350,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.image_not_supported, size: 64),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                // Name & Description
                Text(recipe.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (recipe.description != null) Text(recipe.description!, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                // Ingredients
                const Text("Ingredients", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...recipe.ingredients.map(
                  (ingredient) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Text("• "),
                        Expanded(child: Text(ingredient)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Steps
                const Text("Steps", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...recipe.steps.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text("${entry.key + 1}. ${entry.value}"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
