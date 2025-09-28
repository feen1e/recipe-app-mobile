import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../../core/constants/routes.dart";
import "../../../auth/presentation/providers/auth_provider.dart";
import "../providers/collection_details_provider.dart";

class CollectionDetailsPage extends ConsumerWidget {
  final String collectionId;

  const CollectionDetailsPage({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionDetailsAsync = ref.watch(collectionDetailsProvider(collectionId));
    final currentUserId = ref.watch(currentUserIdProvider);

    return collectionDetailsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text("Collection details")),
        body: Center(child: Text(err.toString())),
      ),
      data: (collectionDetails) => Scaffold(
        appBar: AppBar(
          actions: [
            if (collectionDetails.userId == currentUserId.value)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await context.push(Routes.createOrEditCollection, extra: collectionDetails.id);
                },
              ),
          ],
        ),
        body: Column(
          children: [
            Text(collectionDetails.name, style: Theme.of(context).textTheme.headlineMedium),
            if (collectionDetails.description != null)
              Padding(padding: const EdgeInsets.all(8), child: Text(collectionDetails.description!)),
            const Padding(padding: EdgeInsets.all(12)),
            Expanded(
              child: ListView.builder(
                itemCount: collectionDetails.recipes.length,
                itemBuilder: (context, index) {
                  final recipe = collectionDetails.recipes[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                    child: Column(
                      children: [
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
                                    Text(
                                      recipe.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
