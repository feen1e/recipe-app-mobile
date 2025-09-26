import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../../core/constants/routes.dart";
import "../providers/collection_details_provider.dart";

class CollectionDetailsPage extends ConsumerWidget {
  final String collectionId;

  const CollectionDetailsPage({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionDetailsAsync = ref.watch(collectionDetailsProvider(collectionId));

    return collectionDetailsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text("Collection details")),
        body: Center(child: Text(err.toString())),
      ),
      data: (collectionDetails) => Scaffold(
        appBar: AppBar(title: Text(collectionDetails.name)),
        body: Column(
          children: [
            Text(collectionDetails.name, style: Theme.of(context).textTheme.headlineMedium),
            if (collectionDetails.description != null) Text(collectionDetails.description!),
            Expanded(
              child: ListView.builder(
                itemCount: collectionDetails.recipes.length,
                itemBuilder: (context, index) {
                  final recipe = collectionDetails.recipes[index];
                  return ListTile(
                    title: Text(recipe.title),
                    subtitle: Text(recipe.description ?? ""),
                    onTap: () async {
                      await context.push("${Routes.recipeDetails}/${recipe.id}");
                    },
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
