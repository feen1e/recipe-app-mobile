import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../auth/presentation/providers/auth_provider.dart";

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Profile Page"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final authNotifier = ref.read(authNotifierProvider.notifier);
                await authNotifier.logout();
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
