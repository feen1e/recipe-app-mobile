import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../../l10n/app_localizations.dart";
import "../../../collection_details/presentation/providers/collection_details_provider.dart";
import "../../data/models/collection.dart";
import "../providers/collections_provider.dart";

class AddToCollectionPage extends ConsumerStatefulWidget {
  final String recipeId;

  const AddToCollectionPage({super.key, required this.recipeId});

  @override
  ConsumerState<AddToCollectionPage> createState() => _AddToCollectionPageState();
}

class _AddToCollectionPageState extends ConsumerState<AddToCollectionPage> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final collectionsState = ref.watch(collectionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).addToCollection)),
      body: collectionsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorState(context, error.toString()),
        data: (collections) => _buildCollectionsList(context, collections),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).failedToLoadCollections,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(collectionsProvider.notifier).refresh(),
                child: Text(AppLocalizations.of(context).retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionsList(BuildContext context, List<CollectionDto> collections) {
    if (collections.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.collections_bookmark_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).noCollectionsYet,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).createFirstCollection,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final collection = collections[index];
        return _buildCollectionCard(context, collection);
      },
    );
  }

  Widget _buildCollectionCard(BuildContext context, CollectionDto collection) {
    final collectionDetailsState = ref.watch(collectionDetailsProvider(collection.id));

    return collectionDetailsState.when(
      loading: () => Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(collection.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (collection.description != null && collection.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        collection.description!,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
        ),
      ),
      error: (error, stackTrace) => Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(collection.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Text("Error loading collection details", style: TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.error_outline, color: Colors.red),
            ],
          ),
        ),
      ),
      data: (collectionDetails) {
        final recipeInCollection = collectionDetails.recipes.any((recipe) => recipe.id == widget.recipeId);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _isLoading ? null : () => _toggleRecipeInCollection(collection, recipeInCollection),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(collection.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        if (collection.description != null && collection.description!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            collection.description!,
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          collectionDetails.recipes.length == 1
                              ? "1 ${AppLocalizations.of(context).recipes.toLowerCase().substring(0, AppLocalizations.of(context).recipes.length - 1)}"
                              : "${collectionDetails.recipes.length} ${AppLocalizations.of(context).recipes.toLowerCase()}",
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  else if (recipeInCollection)
                    Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                  else
                    const Icon(Icons.add_circle_outline, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleRecipeInCollection(CollectionDto collection, bool recipeInCollection) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(collectionsRepositoryProvider);

      if (recipeInCollection) {
        await repository.removeRecipeFromCollection(collection.id, widget.recipeId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).recipeRemovedFromCollection(collection.name)),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        await repository.addRecipeToCollection(collection.id, widget.recipeId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).recipeAddedToCollection(collection.name)),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      ref.invalidate(collectionDetailsProvider(collection.id));
    } on Exception catch (e) {
      if (mounted) {
        final errorMessage = recipeInCollection
            ? AppLocalizations.of(context).failedToRemoveRecipeFromCollection
            : AppLocalizations.of(context).failedToAddRecipeToCollection;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$errorMessage: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
