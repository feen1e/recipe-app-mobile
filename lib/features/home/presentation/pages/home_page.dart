import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";

import "../../../../core/constants/routes.dart";
import "../../../../l10n/app_localizations.dart";
import "../providers/recipes_provider.dart";

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        await ref.read(latestRecipesProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(latestRecipesProvider);
    final isLoadingMore = ref.watch(loadMoreStateProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).recipeFeed)),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(latestRecipesProvider.notifier).refresh();
        },
        child: recipesAsync.when(
          data: (recipesResponse) {
            final recipes = recipesResponse.recipes;

            return ListView.builder(
              controller: _scrollController,
              itemCount: recipes.length + (recipesResponse.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == recipes.length) {
                  return isLoadingMore
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox.shrink();
                }

                final recipe = recipes[index];
                final isUpdated = recipe.updatedAt.isAfter(recipe.createdAt);
                final avatarExists = recipe.author.avatarUrl != null;
                final localTime = recipe.updatedAt.toLocal();
                final formattedTime = DateFormat("dd.MM.yyyy\nHH:mm").format(localTime);

                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Row
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: avatarExists ? CachedNetworkImageProvider(recipe.author.avatarUrl!) : null,
                            child: !avatarExists ? Text(recipe.author.username.substring(0, 1).toUpperCase()) : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            recipe.author.username,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isUpdated
                                ? AppLocalizations.of(context).updatedRecipe
                                : AppLocalizations.of(context).createdRecipe,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Expanded(
                            child: Text(
                              textAlign: TextAlign.right,
                              formattedTime,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Recipe Preview
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          await context.push("${Routes.recipeDetails}/${recipe.id}");
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: recipe.imageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: recipe.imageUrl!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) {
                                        return Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image_not_supported),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.restaurant),
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  if (recipe.description != null)
                                    Text(recipe.description!, maxLines: 3, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 24),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).errorLoadingRecipes,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(latestRecipesProvider.notifier).refresh();
                  },
                  child: Text(AppLocalizations.of(context).retry),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await context.push(Routes.createOrUpdateRecipe);
        },
      ),
    );
  }
}
