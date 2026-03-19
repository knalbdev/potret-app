import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../flavor/app_flavor.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../provider/add_story_provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/story_provider.dart';

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({super.key});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddStoryProvider>().reset();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      context.read<AddStoryProvider>().setImage(File(picked.path));
    }
  }

  Future<void> _pickLocation() async {
    final current = context.read<AddStoryProvider>().selectedLocation;
    final result = await context.push<LatLng?>(
      '/stories/add/location-picker',
      extra: current,
    );
    if (result != null && mounted) {
      context.read<AddStoryProvider>().setLocation(result);
    }
  }

  Future<void> _onUpload() async {
    final l10n = AppLocalizations.of(context);
    final addStoryProvider = context.read<AddStoryProvider>();

    if (addStoryProvider.selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.imageRequired),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final token = context.read<AuthProvider>().token ?? '';
    final storyProvider = context.read<StoryProvider>();
    final location = addStoryProvider.selectedLocation;

    final success = await storyProvider.addStory(
      token: token,
      description: _descriptionController.text.trim(),
      photo: addStoryProvider.selectedImage!,
      lat: location?.latitude,
      lon: location?.longitude,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.uploadSuccess),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      context.go('/stories');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(storyProvider.errorMessage ?? l10n.uploadFailed),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showImageSourceSheet() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.creamLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warmGoldLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.warmGold,
                  ),
                ),
                title: Text(l10n.camera),
                onTap: () {
                  ctx.pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warmGoldLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.warmGold,
                  ),
                ),
                title: Text(l10n.gallery),
                onTap: () {
                  ctx.pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isUploading = context.select<StoryProvider, bool>(
      (p) => p.isUploading,
    );
    final selectedImage = context.select<AddStoryProvider, File?>(
      (p) => p.selectedImage,
    );
    final selectedLocation = context.select<AddStoryProvider, LatLng?>(
      (p) => p.selectedLocation,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newStory)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image picker area
                GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selectedImage != null
                            ? AppColors.warmGold
                            : AppColors.divider,
                        width: selectedImage != null ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: selectedImage != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(selectedImage, fit: BoxFit.cover),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: GestureDetector(
                                  onTap: () => context
                                      .read<AddStoryProvider>()
                                      .setImage(null),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: AppColors.warmGoldLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 36,
                                  color: AppColors.warmGold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.selectImage,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isUploading
                            ? null
                            : () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        label: Text(l10n.camera),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isUploading
                            ? null
                            : () => _pickImage(ImageSource.gallery),
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          size: 18,
                        ),
                        label: Text(l10n.gallery),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: l10n.description,
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.descriptionRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _LocationPickerTile(
                  selectedLocation: selectedLocation,
                  onPick: isUploading ? null : _pickLocation,
                  onRemove: () =>
                      context.read<AddStoryProvider>().setLocation(null),
                  l10n: l10n,
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: isUploading ? null : _onUpload,
                  child: isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.upload),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationPickerTile extends StatelessWidget {
  const _LocationPickerTile({
    required this.selectedLocation,
    required this.onPick,
    required this.onRemove,
    required this.l10n,
  });

  final LatLng? selectedLocation;
  final VoidCallback? onPick;
  final VoidCallback onRemove;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (!FlavorConfig.isPaid) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.warmGoldLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.lock_outline,
              size: 18,
              color: AppColors.warmGold,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.freePlanNoLocation,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color:
            selectedLocation != null ? AppColors.warmGoldLight : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedLocation != null
              ? AppColors.warmGold
              : AppColors.divider,
          width: selectedLocation != null ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.warmGoldLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.location_on_outlined,
            color: AppColors.warmGold,
            size: 20,
          ),
        ),
        title: Text(
          selectedLocation != null
              ? '${selectedLocation!.latitude.toStringAsFixed(5)}, '
                  '${selectedLocation!.longitude.toStringAsFixed(5)}'
              : l10n.pickLocation,
          style: TextStyle(
            fontSize: 14,
            color: selectedLocation != null
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
        subtitle: selectedLocation != null
            ? Text(
                l10n.locationAdded,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.warmGold,
                ),
              )
            : null,
        trailing: selectedLocation != null
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.textSecondary,
                onPressed: onRemove,
              )
            : const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
        onTap: onPick,
      ),
    );
  }
}
