import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_form_builder/flutter_form_builder.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:form_builder_image_picker/form_builder_image_picker.dart";
import "package:go_router/go_router.dart";
import "package:logging/logging.dart";

import "../../../../l10n/app_localizations.dart";
import "../../../auth/presentation/providers/auth_provider.dart";
import "../../../create_or_update_recipe/presentation/providers/create_or_update_recipe_provider.dart";
import "../providers/profile_provider.dart";

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final logger = Logger("ProfileEditPage");
  final _formKey = GlobalKey<FormBuilderState>();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  var _saving = false;
  List<XFile>? _initialImage;
  var _loadingInitialImage = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String username = ref
        .watch(currentUsernameProvider)
        .maybeWhen(data: (current) => current ?? "", orElse: () => "");

    final completeProfileAsync = ref.watch(completeProfileProvider(username));

    return completeProfileAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (completeProfile) {
        if (_usernameController.text.isEmpty) {
          _usernameController.text = completeProfile.profile.username;
        }
        if (_bioController.text.isEmpty && completeProfile.profile.bio != null) {
          _bioController.text = completeProfile.profile.bio!;
        }

        if (_initialImage == null && !_loadingInitialImage) {
          final avatarUrl = completeProfile.profile.avatarUrl;
          if (avatarUrl != null && avatarUrl.isNotEmpty) {
            _loadingInitialImage = true;
            unawaited(
              ref
                  .read(repositoryProvider)
                  .getPhotoFromUrl(avatarUrl)
                  .then((xfile) {
                    if (!mounted) return;
                    setState(() {
                      _initialImage = xfile != null ? [xfile] : <XFile>[];
                      _loadingInitialImage = false;
                    });
                  })
                  .catchError((_) {
                    if (!mounted) return;
                    setState(() {
                      _initialImage = <XFile>[];
                      _loadingInitialImage = false;
                    });
                  }),
            );
          } else {
            _initialImage = <XFile>[];
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).editProfile),
            actions: [
              TextButton(
                onPressed: _saving ? null : _onSave,
                child: Text(AppLocalizations.of(context).save, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: FormBuilder(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: completeProfile.profile.username,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context).username),
                    ),
                    const SizedBox(height: 12),
                    if (_loadingInitialImage)
                      const Center(child: CircularProgressIndicator())
                    else
                      FormBuilderImagePicker(
                        name: "avatar",
                        initialValue: _initialImage ?? <XFile>[],
                        maxImages: 1,
                        bottomSheetPadding: const EdgeInsets.all(20),

                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).profileAvatar,
                          border: const OutlineInputBorder(),
                        ),
                        placeholderWidget: const SizedBox.expand(child: Icon(Icons.camera_alt)),
                        transformImageWidget: (context, displayImage) {
                          return SizedBox.expand(child: ClipRRect(child: displayImage));
                        },
                        fit: BoxFit.fitHeight,
                        previewHeight: 250,
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _bioController,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context).profileBio),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _onSave,
                        child: _saving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(AppLocalizations.of(context).save),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSave() async {
    logger.warning("Saving profile");
    final username = ref.watch(currentUsernameProvider).value ?? "";
    if (username.isEmpty) return;

    setState(() => _saving = true);
    try {
      final repository = ref.read(profileRepositoryProvider);

      String? avatarUrl;
      final fbState = _formKey.currentState;
      if (fbState != null) {
        fbState.save();
        final images = fbState.fields["avatar"]?.value as List<dynamic>?;
        if (images != null && images.isNotEmpty) {
          final uploadRepo = ref.read(repositoryProvider);
          try {
            logger.warning("Uploading avatar image");
            avatarUrl = await uploadRepo.addPhoto(images.first as XFile, "avatars");
            logger.warning("Uploaded avatar image, url: $avatarUrl");
          } on Exception catch (e) {
            logger.warning("Failed to upload avatar image: $e");
            logger.warning("Failed to upload avatar image: $e");
            avatarUrl = null;
          }
        }
      }

      logger.warning("Updating profile");
      logger.warning(
        "Username: $username, Bio: ${_bioController.text.trim().isEmpty ? null : _bioController.text.trim()}, AvatarUrl: $avatarUrl",
      );
      await repository.updateProfile(
        username: username,
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        avatarUrl: avatarUrl,
      );
      logger.warning("Profile updated");

      await ref.read(completeProfileProvider(username).notifier).refresh(username);

      if (mounted) context.pop();
    } on Exception catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
