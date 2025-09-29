import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../../core/constants/routes.dart";
import "../../../../l10n/app_localizations.dart";
import "../../data/models/auth_state.dart";
import "../providers/auth_provider.dart";

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameOrEmailController = TextEditingController();
    final passwordController = TextEditingController();

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.maybeWhen(
        authenticated: () {
          context.go(Routes.home);
        },
        error: (message) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).loginError(message))));
        },
        orElse: () {},
      );
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context).loginTitle, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 64),
              TextField(
                controller: usernameOrEmailController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).usernameOrEmail,
                  hintText: AppLocalizations.of(context).enterUsernameOrEmail,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).password,
                  hintText: AppLocalizations.of(context).enterPassword,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  final usernameOrEmail = usernameOrEmailController.text.trim();
                  final password = passwordController.text.trim();
                  if (usernameOrEmail.isNotEmpty && password.isNotEmpty) {
                    final authNotifier = ref.read(authNotifierProvider.notifier);
                    await authNotifier.login(usernameOrEmail, password);
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).fillAllFields)));
                  }
                },
                child: Text(AppLocalizations.of(context).login),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.go(Routes.register);
                },
                child: Text(
                  AppLocalizations.of(context).dontHaveAccount,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
