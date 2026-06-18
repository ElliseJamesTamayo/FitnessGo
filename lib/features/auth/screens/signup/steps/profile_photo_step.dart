import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/auth_api.dart';

class ProfilePhotoStep extends StatefulWidget {
  final int? userId;
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const ProfilePhotoStep({
    super.key,
    required this.onNext,
    this.userId,
    this.onBack,
  });

  @override
  State<ProfilePhotoStep> createState() => _ProfilePhotoStepState();
}

class _ProfilePhotoStepState extends State<ProfilePhotoStep> {
  static const Color fitnessGreen = Color(0xFF009900);

  final ImagePicker picker = ImagePicker();

  File? selectedPhoto;
  bool isPicking = false;
  bool isUploading = false;

  Future<void> choosePhoto() async {
    if (isPicking || isUploading) return;

    setState(() {
      isPicking = true;
    });

    try {
      final pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (pickedImage == null) return;

      setState(() {
        selectedPhoto = File(pickedImage.path);
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not choose photo: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isPicking = false;
        });
      }
    }
  }

  Future<void> uploadAndContinue() async {
    if (isUploading) return;

    if (selectedPhoto == null) {
      widget.onNext();
      return;
    }

    final userId = widget.userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account was created, but user ID is missing. Please skip for now.',
          ),
        ),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      final response = await AuthApi.uploadProfilePhoto(
        userId: userId,
        filePath: selectedPhoto!.path,
      );

      final success = response['success'] == true;

      if (!success) {
        throw Exception(response['message'] ?? 'Photo upload failed');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo uploaded successfully.'),
        ),
      );

      widget.onNext();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not upload photo: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  void skipPhoto() {
    if (isUploading) return;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final canTap = !isPicking && !isUploading;
    final hasPhoto = selectedPhoto != null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 26),
            _buildCard(canTap: canTap, hasPhoto: hasPhoto),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF34D24D),
              width: 3,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.fitness_center,
              color: Color(0xFF34D24D),
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Fitness Go',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF202020),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE9FFE7),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Text(
            'Step 6/6',
            style: TextStyle(
              color: fitnessGreen,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required bool canTap,
    required bool hasPhoto,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Add Profile Photo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF252525),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Make your FitnessGo account more personal.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.35,
              color: Color(0xFF777777),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: canTap ? choosePhoto : null,
            child: _buildPhotoPreview(hasPhoto),
          ),
          const SizedBox(height: 16),
          Text(
            hasPhoto ? 'Profile photo selected' : 'No profile photo selected',
            style: TextStyle(
              color: hasPhoto ? fitnessGreen : Colors.grey.shade700,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 26),
          _buildInfoBox(),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: canTap ? choosePhoto : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: fitnessGreen,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: fitnessGreen.withOpacity(0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                hasPhoto ? 'Change Photo' : 'Choose Photo',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: canTap ? skipPhoto : null,
            child: const Text(
              'Skip for now',
              style: TextStyle(
                color: fitnessGreen,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: OutlinedButton(
                    onPressed: canTap ? widget.onBack : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: fitnessGreen,
                      side: const BorderSide(
                        color: fitnessGreen,
                        width: 1.6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: canTap ? uploadAndContinue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: fitnessGreen,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: fitnessGreen.withOpacity(0.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: isUploading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.3,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            hasPhoto ? 'Upload' : 'Continue',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview(bool hasPhoto) {
    return Container(
      height: 172,
      width: 172,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE9F8EA),
        border: Border.all(
          color: fitnessGreen,
          width: 3,
        ),
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasPhoto)
              Image.file(
                selectedPhoto!,
                fit: BoxFit.cover,
              )
            else
              Center(
                child: Icon(
                  Icons.person_add_alt_1,
                  size: 58,
                  color: Colors.grey.shade600,
                ),
              ),
            if (hasPhoto)
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: fitnessGreen,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFFFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF9DEAA3),
          width: 1.1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: fitnessGreen,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Adding a photo is optional. You may skip this step and upload one later.',
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
