import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../providers/recipe_details_provider.dart";

class RecipeDetailsPage extends ConsumerWidget {
  final String recipeId;

  const RecipeDetailsPage({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeDetails = ref.watch(recipeDetailsProvider(recipeId));
    // ! TODO: implement provider for getting user details: username, avatar;
    return recipeDetails.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(body: Center(child: Text("Error: $error"))),
      data: (recipe) {
        return Scaffold(
          appBar: AppBar(title: Text(recipe.title)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Header
                // Row(
                //   children: [
                //     CircleAvatar(
                //       backgroundImage: recipe.author.avatarUrl != null ? NetworkImage(recipe.author.avatarUrl!) : null,
                //       child: recipe.author.avatarUrl == null
                //           ? Text(recipe.author.username.substring(0, 1).toUpperCase())
                //           : null,
                //     ),
                //     const SizedBox(width: 10),
                //     Text(recipe.author.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                //   ],
                // ),
                const SizedBox(height: 16),
                // Recipe Image
                if (recipe.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      recipe.imageUrl!,
                      width: double.infinity,
                      height: 350,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 350,
                          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.image_not_supported, size: 64),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
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
