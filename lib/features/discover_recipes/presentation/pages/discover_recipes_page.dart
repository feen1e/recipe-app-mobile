import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class DiscoverRecipesPage extends ConsumerWidget {
  const DiscoverRecipesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Discover Recipes")),
      body: const Center(child: Text("Discover Recipes Page")),
    );
  }
}
