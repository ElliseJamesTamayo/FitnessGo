import 'package:flutter/material.dart';

import '../../../widgets/app_button.dart';
import '../../../widgets/app_logo.dart';

class ProfilePhotoStep extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const ProfilePhotoStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<ProfilePhotoStep> createState() => _ProfilePhotoStepState();
}

class _ProfilePhotoStepState extends State<ProfilePhotoStep> {
  bool photoSelected = false;

  void choosePhoto() {
    setState(() {
      photoSelected = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo picker will be connected later.'),
        backgroundColor: Color(0xFF008000),
      ),
    );
  }

  Widget compactHeader() {
    return Row(
      children: [
        AppLogo(size: 46),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Fitness Go',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Step 6/6',
            style: TextStyle(
              color: Color(0xFF008000),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget photoPreview() {
    return GestureDetector(
      onTap: choosePhoto,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 170,
        height: 170,
        decoration: BoxDecoration(
          color: photoSelected
              ? const Color(0xFFE8F5E9)
              : const Color(0xFFF9FFF9),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF008000),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Icon(
          photoSelected ? Icons.check_circle : Icons.add_a_photo,
          size: 64,
          color: const Color(0xFF008000),
        ),
      ),
    );
  }

  Widget infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FFF9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFB7E4B7),
          width: 1.2,
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFF008000),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Adding a photo is optional. You may skip this step and upload one later.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          compactHeader(),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: screenHeight * 0.76,
            ),
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Add Profile Photo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Make your FitnessGo account more personal.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 26),

                photoPreview(),

                const SizedBox(height: 18),

                Text(
                  photoSelected
                      ? 'Profile photo selected'
                      : 'Tap the circle to add a photo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: photoSelected
                        ? const Color(0xFF008000)
                        : Colors.black54,
                  ),
                ),

                const SizedBox(height: 22),

                infoCard(),

                const SizedBox(height: 26),

                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: photoSelected ? 'Change Photo' : 'Choose Photo',
                    onPressed: choosePhoto,
                  ),
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: widget.onNext,
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(
                      color: Color(0xFF008000),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Back',
                        outlined: true,
                        onPressed: widget.onBack,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: 'Continue',
                        onPressed: widget.onNext,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

