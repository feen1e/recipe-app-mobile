import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../../core/constants/routes.dart";
import "../../../../l10n/app_localizations.dart";
import "../../data/models/auth_state.dart";
import "../providers/auth_provider.dart";

class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final usernameController = TextEditingController();

    final authNotifier = ref.watch(authNotifierProvider.notifier);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.maybeWhen(
        authenticated: () {
          context.go(Routes.home);
        },
        error: (message) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).registerError(message))));
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
              Text(AppLocalizations.of(context).registerTitle, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 64),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).username,
                  hintText: AppLocalizations.of(context).username,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).email,
                  hintText: AppLocalizations.of(context).enterEmail,
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
              const SizedBox(height: 24),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).confirmPassword,
                  hintText: AppLocalizations.of(context).confirmPasswordHint,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  final username = usernameController.text.trim();
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();
                  final confirmPassword = confirmPasswordController.text.trim();

                  if (username.isNotEmpty && email.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty) {
                    if (password == confirmPassword) {
                      await authNotifier.register(username, email, password);
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).passwordsDoNotMatch)));
                    }
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).fillAllFields)));
                  }
                },
                child: Text(AppLocalizations.of(context).register),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.go(Routes.login);
                },
                child: Text(
                  AppLocalizations.of(context).alreadyHaveAccount,
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
