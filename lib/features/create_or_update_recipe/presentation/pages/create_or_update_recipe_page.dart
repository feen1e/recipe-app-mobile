import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_form_builder/flutter_form_builder.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:form_builder_image_picker/form_builder_image_picker.dart";
import "package:go_router/go_router.dart";

import "../../../../l10n/app_localizations.dart";
import "../../../recipe_details/data/models/recipe.dart";
import "../../data/models/create_recipe.dart";
import "../providers/create_or_update_recipe_provider.dart";

class CreateOrUpdateRecipePage extends ConsumerStatefulWidget {
  final RecipeDetailsDto? recipe;

  const CreateOrUpdateRecipePage({super.key, this.recipe});

  @override
  ConsumerState<CreateOrUpdateRecipePage> createState() => _CreateOrUpdateRecipePageState();
}

class _CreateOrUpdateRecipePageState extends ConsumerState<CreateOrUpdateRecipePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<String> _ingredients = [];
  final List<String> _steps = [];
  List<XFile>? _initialImages;
  var _isImageLoading = false;

  bool get isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _ingredients.addAll(widget.recipe!.ingredients);
      _steps.addAll(widget.recipe!.steps);

      _isImageLoading = true;
      unawaited(_loadInitialImage());
    }
  }

  Future<void> _loadInitialImage() async {
    if (widget.recipe?.imageUrl != null && widget.recipe!.imageUrl!.isNotEmpty) {
      try {
        final repository = ref.read(repositoryProvider);
        final image = await repository.getPhotoFromUrl(widget.recipe!.imageUrl!);
        if (image != null && mounted) {
          setState(() {
            _initialImages = [image];
            _isImageLoading = false;
          });
        } else if (mounted) {
          setState(() {
            _isImageLoading = false;
          });
        }
      } on Exception {
        if (mounted) {
          setState(() {
            _isImageLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isImageLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? AppLocalizations.of(context).createRecipePageTitleEdit
              : AppLocalizations.of(context).createRecipePageTitleCreate,
        ),
        actions: [
          TextButton(
            onPressed: _saveRecipe,
            child: Text(AppLocalizations.of(context).save, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _isImageLoading
          ? const Center(child: CircularProgressIndicator())
          : FormBuilder(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Picker
                    _buildImagePicker(),
                    const SizedBox(height: 24),

                    // Title Field
                    _buildTitleField(),
                    const SizedBox(height: 16),

                    // Description Field
                    _buildDescriptionField(),
                    const SizedBox(height: 24),

                    // Ingredients Section
                    _buildIngredientsSection(),
                    const SizedBox(height: 24),

                    // Steps Section
                    _buildStepsSection(),
                    const SizedBox(height: 32),

                    // Submit Button
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormBuilderImagePicker(
          name: "image",
          initialValue: _initialImages,
          displayCustomType: (obj) => obj is XFile ? Image.file(File(obj.path)) : obj,
          maxImages: 1,
          bottomSheetPadding: const EdgeInsets.all(20),
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).selectRecipeImage,
            border: const OutlineInputBorder(),
          ),
          placeholderWidget: const SizedBox.expand(child: Icon(Icons.camera_alt)),
          transformImageWidget: (context, displayImage) {
            return SizedBox.expand(child: ClipRRect(child: displayImage));
          },
          fit: BoxFit.fitHeight,
          previewHeight: 250,
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return FormBuilderTextField(
      name: "title",
      initialValue: isEditing ? widget.recipe!.title : null,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).recipeTitle,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.restaurant_menu),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).pleaseEnterRecipeTitle;
        }
        if (value.length < 3) {
          return AppLocalizations.of(context).titleMinLength(3);
        }
        if (value.length > 100) {
          return AppLocalizations.of(context).titleMaxLength(100);
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return FormBuilderTextField(
      name: "description",
      initialValue: isEditing ? widget.recipe!.description : null,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).description,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.description),
      ),
      minLines: 1,
      maxLines: 5,
      validator: (value) {
        if (value != null && value.length > 500) {
          return AppLocalizations.of(context).descriptionMaxLength(500);
        }
        return null;
      },
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context).ingredients, style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              onPressed: _addIngredient,
              icon: const Icon(Icons.add_circle),
              tooltip: AppLocalizations.of(context).addIngredient,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_ingredients.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              AppLocalizations.of(context).noIngredientsYetContent,
              style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...List.generate(_ingredients.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: "ingredient_$index",
                      initialValue: _ingredients[index],
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).ingredient(index + 1),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.restaurant),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context).pleaseEnterIngredient;
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value != null) {
                          _ingredients[index] = value;
                        }
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeIngredient(index),
                    icon: const Icon(Icons.remove_circle),
                    color: Colors.red,
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context).cookingSteps, style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              onPressed: _addStep,
              icon: const Icon(Icons.add_circle),
              tooltip: AppLocalizations.of(context).addStep,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_steps.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              AppLocalizations.of(context).noStepsYetContent,
              style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...List.generate(_steps.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: "step_$index",
                      initialValue: _steps[index],
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).step(index + 1),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.format_list_numbered),
                      ),
                      minLines: 1,
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context).pleaseEnterStep;
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value != null) {
                          _steps[index] = value;
                        }
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeStep(index),
                    icon: const Icon(Icons.remove_circle),
                    color: Colors.red,
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveRecipe,
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        child: Text(
          isEditing ? AppLocalizations.of(context).updateRecipe : AppLocalizations.of(context).createRecipe,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add("");
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _addStep() {
    setState(() {
      _steps.add("");
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
    });
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      // Validate that we have at least one ingredient and one step
      if (_ingredients.isEmpty || _ingredients.every((ingredient) => ingredient.trim().isEmpty)) {
        _showErrorSnackBar(AppLocalizations.of(context).pleaseAddAtLeastOneIngredient);
        return;
      }

      if (_steps.isEmpty || _steps.every((step) => step.trim().isEmpty)) {
        _showErrorSnackBar(AppLocalizations.of(context).pleaseAddAtLeastOneStep);
        return;
      }

      final formValues = _formKey.currentState!.value;

      // Filter out empty ingredients and steps
      final filteredIngredients = _ingredients.where((ingredient) => ingredient.trim().isNotEmpty).toList();
      final filteredSteps = _steps.where((step) => step.trim().isNotEmpty).toList();

      // Get form values with proper type casting
      final title = formValues["title"] as String?;
      final description = formValues["description"] as String?;
      final selectedImagesRaw = formValues["image"] as List<dynamic>?;
      final selectedImages = selectedImagesRaw?.cast<XFile>();

      try {
        // Show loading indicator
        unawaited(_showLoadingDialog());

        final repository = ref.read(repositoryProvider);
        String? imageUrl;

        // Handle image upload if an image was selected
        if (selectedImages != null && selectedImages.isNotEmpty) {
          final imageFile = selectedImages.first;
          imageUrl = await repository.addPhoto(imageFile, "recipes");
        }

        if (isEditing) {
          // Create UpdateRecipeRequest
          final updateRequest = UpdateRecipeRequest(
            title: title,
            description: (description ?? "").isNotEmpty ? description : null,
            ingredients: filteredIngredients,
            steps: filteredSteps,
            imageUrl: imageUrl,
          );

          // Call repository update method
          final updatedRecipe = await repository.updateRecipe(widget.recipe!.id, updateRequest);

          // Hide loading and show success
          _hideLoadingDialog();
          if (mounted) {
            _showSuccessSnackBar(AppLocalizations.of(context).recipeUpdatedSuccess);
          }

          // Navigate back with result
          if (mounted) {
            context.pop(updatedRecipe);
          }
        } else {
          // Create CreateRecipeRequest
          final createRequest = CreateRecipeRequest(
            title: title ?? "",
            description: (description ?? "").isNotEmpty ? description : null,
            ingredients: filteredIngredients,
            steps: filteredSteps,
            imageUrl: imageUrl,
          );

          // Call repository create method
          final newRecipe = await repository.createRecipe(createRequest);

          // Hide loading and show success
          _hideLoadingDialog();
          if (mounted) {
            _showSuccessSnackBar(AppLocalizations.of(context).recipeCreatedSuccess);
          }

          // Navigate back with result
          if (mounted) {
            context.pop(newRecipe);
          }
        }
      } on Exception catch (e) {
        // Hide loading and show error
        _hideLoadingDialog();
        if (mounted) {
          _showErrorSnackBar(AppLocalizations.of(context).failedToSaveRecipe(e.toString()));
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  Future<void> _showLoadingDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(AppLocalizations.of(context).savingRecipe),
          ],
        ),
      ),
    );
  }

  void _hideLoadingDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
