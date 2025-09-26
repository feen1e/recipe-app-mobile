import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../../l10n/app_localizations.dart";

class DiscoverRecipesPage extends ConsumerWidget {
  const DiscoverRecipesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).discoverRecipesPage)),
      body: Center(child: Text(AppLocalizations.of(context).discoverRecipesPage)),
    );
  }
}
