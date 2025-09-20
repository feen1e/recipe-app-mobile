import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class CollectionsPage extends ConsumerWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Collections")),
      body: const Center(child: Text("Collections Page")),
    );
  }
}
