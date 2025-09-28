import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../../l10n/app_localizations.dart";
import "../../../collection_details/presentation/providers/collection_details_provider.dart";
import "../providers/collections_provider.dart";

class CollectionCreatePage extends ConsumerStatefulWidget {
  final String? existingCollectionId;
  const CollectionCreatePage({super.key, this.existingCollectionId});

  @override
  ConsumerState<CollectionCreatePage> createState() => _CollectionCreatePageState();
}

class _CollectionCreatePageState extends ConsumerState<CollectionCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final Set<String> _selectedRecipeIds = {};
  var _submitting = false;
  bool get isEditing => widget.existingCollectionId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoritesState = ref.watch(favoritesProvider);
    final collection = isEditing ? ref.watch(collectionDetailsProvider(widget.existingCollectionId!)).value : null;

    // If we're editing and the collection has loaded, populate controllers once
    if (isEditing && collection != null) {
      if (_nameController.text.isEmpty) _nameController.text = collection.name;
      if (_descriptionController.text.isEmpty && collection.description != null) {
        _descriptionController.text = collection.description!;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? AppLocalizations.of(context).editCollection : AppLocalizations.of(context).createCollection,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context).collectionName),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? AppLocalizations.of(context).enterCollectionName : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context).collectionDescription),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEditing ? AppLocalizations.of(context).addedRecipes : AppLocalizations.of(context).addFromFavorites,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (isEditing && collection != null)
              SizedBox(
                height: 500,
                child: ListView.builder(
                  itemCount: collection.recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = collection.recipes[index];
                    final selected = _selectedRecipeIds.contains(recipe.id);
                    return ListTile(
                      contentPadding: const EdgeInsets.all(8),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: recipe.imageUrl!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                placeholder: (c, u) => const SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (c, u, e) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.restaurant, size: 40, color: Colors.grey),
                                ),
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: const Icon(Icons.restaurant, size: 40, color: Colors.grey),
                              ),
                      ),
                      title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: recipe.description != null
                          ? Text(recipe.description!, maxLines: 2, overflow: TextOverflow.ellipsis)
                          : null,
                      trailing: IconButton(
                        icon: Icon(
                          !selected ? Icons.check_circle : Icons.add_circle_outline,
                          color: !selected ? Theme.of(context).colorScheme.primary : null,
                        ),
                        onPressed: () => setState(() {
                          if (selected) {
                            _selectedRecipeIds.remove(recipe.id);
                          } else {
                            _selectedRecipeIds.add(recipe.id);
                          }
                        }),
                      ),
                    );
                  },
                ),
              )
            else
              SizedBox(
                height: 500,
                child: favoritesState.when(
                  data: (favorites) {
                    if (favorites.isEmpty) {
                      return Center(child: Text(AppLocalizations.of(context).noFavoritesYet));
                    }

                    return ListView.builder(
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final recipe = favorites[index];
                        final selected = _selectedRecipeIds.contains(recipe.id);
                        return ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: recipe.imageUrl!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    placeholder: (c, u) => const SizedBox(
                                      width: 80,
                                      height: 80,
                                      child: Center(child: CircularProgressIndicator()),
                                    ),
                                    errorWidget: (c, u, e) => Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.restaurant, size: 40, color: Colors.grey),
                                    ),
                                  )
                                : Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.restaurant, size: 40, color: Colors.grey),
                                  ),
                          ),
                          title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: recipe.description != null
                              ? Text(recipe.description!, maxLines: 2, overflow: TextOverflow.ellipsis)
                              : null,
                          trailing: IconButton(
                            icon: Icon(
                              selected ? Icons.check_circle : Icons.add_circle_outline,
                              color: selected ? Theme.of(context).colorScheme.primary : null,
                            ),
                            onPressed: () => setState(() {
                              if (selected) {
                                _selectedRecipeIds.remove(recipe.id);
                              } else {
                                _selectedRecipeIds.add(recipe.id);
                              }
                            }),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(e.toString())),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _onSubmit,
                    child: _submitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : isEditing
                        ? Text(AppLocalizations.of(context).editCollection)
                        : Text(AppLocalizations.of(context).createCollection),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final repository = ref.read(collectionsRepositoryProvider);
      if (isEditing) {
        await repository.updateCollection(
          id: widget.existingCollectionId!,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          recipeIds: _selectedRecipeIds.isEmpty ? null : _selectedRecipeIds.toList(), // recipes to delete
        );
      } else {
        await repository.createCollection(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          recipeIds: _selectedRecipeIds.isEmpty ? null : _selectedRecipeIds.toList(), // recipes to add
        );
      }

      await ref.read(collectionsProvider.notifier).refresh();
      ref.invalidate(collectionDetailsProvider(widget.existingCollectionId ?? ""));

      if (mounted) {
        context.pop();
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
