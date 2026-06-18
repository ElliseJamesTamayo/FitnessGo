import 'package:flutter/material.dart';

import '../data/local_auth_store.dart';
import '../data/local_calorie_store.dart';
import '../data/local_user_store.dart';
import '../features/auth/screens/login/login_screen.dart';
import 'faqs_screen.dart';
import 'weekly_progress_screen.dart';

import '../widgets/profile_photo_avatar.dart';
import 'package:image_picker/image_picker.dart';
import '../core/storage/api_session_store.dart';
import '../features/auth/data/auth_api.dart';

class MyProfileScreen extends StatefulWidget {
  static const routeName = '/my-profile';

  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  int _profilePhotoRefreshKey = 0;
  String fullName = 'User';
  String email = '';
  String goal = '';
  String activityLevel = '';
  String healthCondition = '';
  String bmiStatus = '';
  String gender = '';

  int age = 0;
  int dailyGoal = 0;
  double desiredWeight = 0;
  double bmi = 0;
  double heightCm = 0;
  double weightKg = 0;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final savedName = await LocalAuthStore.getFullName();
    final savedEmail = await LocalAuthStore.getEmail();
    final savedGoal = await LocalAuthStore.getGoal();
    final savedDailyGoal = await LocalAuthStore.getDailyGoal();
    final savedDesiredWeight = await LocalAuthStore.getDesiredWeight();
    final savedBmi = await LocalAuthStore.getBmi();
    final savedBmiStatus = await LocalAuthStore.getBmiStatus();
    final savedActivity = await LocalAuthStore.getActivityLevel();
    final savedHealth = await LocalAuthStore.getHealthCondition();
    final savedAge = await LocalAuthStore.getAge();
    final savedGender = await LocalAuthStore.getGender();
    final savedHeight = await LocalAuthStore.getHeight();
    final savedWeight = await LocalAuthStore.getWeight();
    if (!mounted) return;

    setState(() {
      fullName = savedName.trim().isEmpty
          ? LocalUserStore.displayName
          : savedName;
      email = savedEmail;
      goal = savedGoal;
      dailyGoal = savedDailyGoal > 0
          ? savedDailyGoal
          : LocalCalorieStore.dailyGoal;
      desiredWeight = savedDesiredWeight;
      bmi = savedBmi;
      bmiStatus = savedBmiStatus;
      activityLevel = savedActivity;
      healthCondition = savedHealth;
      age = savedAge;
      gender = savedGender;
      heightCm = savedHeight;
      weightKg = savedWeight;
    });
  }

  String titleCase(String value) {
    if (value.trim().isEmpty) return 'N/A';

    return value
        .replaceAll('_', ' ')
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  double calculateBmiValue({required double weight, required double height}) {
    if (weight <= 0 || height <= 0) return 0;
    final heightM = height / 100;
    return weight / (heightM * heightM);
  }

  String getBmiStatusValue(double value) {
    if (value <= 0) return '';
    if (value < 18.5) return 'Underweight';
    if (value < 25) return 'Normal';
    if (value < 30) return 'Overweight';
    return 'Obese';
  }

  String wholeNumberText(double value, String suffix) {
    if (value <= 0) return 'N/A';
    return '${value.toStringAsFixed(0)} $suffix';
  }

  String get username {
    if (email.contains('@')) return email.split('@').first;
    return fullName.split(RegExp(r'\s+')).first.toLowerCase();
  }

  void showComingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label coming soon.'),
        backgroundColor: const Color(0xFF008000),
      ),
    );
  }

  InputDecoration fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF7FAF4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD9E5D3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD9E5D3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF008000), width: 1.8),
      ),
    );
  }

  Widget dialogLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget dialogButton({
    required String text,
    required VoidCallback onPressed,
    required bool primary,
  }) {
    return Expanded(
      child: SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: primary ? 2 : 0,
            backgroundColor: primary
                ? const Color(0xFF009600)
                : const Color(0xFFE4F1DC),
            foregroundColor: primary ? Colors.white : const Color(0xFF2F5D2F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }

  String normalizeGoalKey(String value) {
    final cleaned = value.trim().toLowerCase().replaceAll(' ', '_');

    const aliases = {
      'lose_weight': 'lose_weight',
      'lose': 'lose_weight',
      'keep_fit': 'keep_fit',
      'maintain': 'keep_fit',
      'maintain_weight': 'keep_fit',
      'gain_weight': 'gain_weight',
      'gain_muscle': 'gain_muscle',
      'gain_muscles': 'gain_muscle',
    };

    return aliases[cleaned] ?? cleaned;
  }

  int calculateDailyGoalValue({
    required String goal,
    required double desiredWeightValue,
    int? ageValue,
    String? genderValue,
    double? heightValue,
    double? weightValue,
    String? activityValue,
  }) {
    final currentAge = ageValue ?? age;
    final currentGender = (genderValue ?? gender).trim().toLowerCase();
    final currentHeight = heightValue ?? heightCm;
    final currentWeight = weightValue ?? weightKg;
    final currentActivity = (activityValue ?? activityLevel).trim();

    if (currentAge <= 0 ||
        currentHeight <= 0 ||
        currentWeight <= 0 ||
        currentGender.isEmpty) {
      return 0;
    }

    final isMale = currentGender == 'male';

    double bmr;
    if (isMale) {
      bmr = 10 * currentWeight + 6.25 * currentHeight - 5 * currentAge + 5;
    } else {
      bmr = 10 * currentWeight + 6.25 * currentHeight - 5 * currentAge - 161;
    }

    final multiplier = switch (currentActivity) {
      'Not Very Active' => 1.2,
      'Lightly Active' => 1.375,
      'Active' => 1.55,
      'Very Active' => 1.725,
      _ => 1.2,
    };

    double calories = bmr * multiplier;

    final goalKey = normalizeGoalKey(goal);

    if (goalKey == 'lose_weight') {
      calories -= 500;
    } else if (goalKey == 'gain_weight' || goalKey == 'gain_muscle') {
      calories += 500;
    }

    if (calories < 1200) calories = 1200;

    return calories.round();
  }

  String? validateDesiredWeightForGoal(String goalKey, double desired) {
    final normalizedGoal = normalizeGoalKey(goalKey);

    if (desired <= 0) {
      return 'Please enter a valid desired weight.';
    }

    if (weightKg <= 0) {
      return null;
    }

    if (normalizedGoal == 'lose_weight' && desired >= weightKg) {
      return 'For Lose Weight, your goal weight should be lower than your current weight.';
    }

    if ((normalizedGoal == 'gain_weight' || normalizedGoal == 'gain_muscle') &&
        desired <= weightKg) {
      return 'For this goal, your goal weight should be higher than your current weight.';
    }

    if (normalizedGoal == 'keep_fit' && (desired - weightKg).abs() > 0.01) {
      return 'For Keep Fit, your goal weight should match your current weight.';
    }

    return null;
  }

  void openEditGoalsDialog() {
    final goalOptions = <String, String>{
      'lose_weight': 'Lose Weight',
      'keep_fit': 'Keep Fit',
      'gain_weight': 'Gain Weight',
      'gain_muscle': 'Gain Muscles',
    };

    String selectedGoal = normalizeGoalKey(goal);
    if (!goalOptions.containsKey(selectedGoal)) {
      selectedGoal = 'keep_fit';
    }

    final desiredController = TextEditingController(
      text: desiredWeight <= 0
          ? selectedGoal == 'keep_fit' && weightKg > 0
                ? weightKg.toStringAsFixed(0)
                : ''
          : desiredWeight.toStringAsFixed(0),
    );

    final dailyController = TextEditingController();

    void refreshDailyGoalPreview() {
      final previewDesired = selectedGoal == 'keep_fit' && weightKg > 0
          ? weightKg
          : double.tryParse(desiredController.text.trim()) ?? 0;

      final previewDaily = calculateDailyGoalValue(
        goal: selectedGoal,
        desiredWeightValue: previewDesired,
      );

      dailyController.text = previewDaily <= 0
          ? 'Complete profile details first'
          : '$previewDaily kcal';
    }

    refreshDailyGoalPreview();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.42),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setModalState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 26),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.82,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 62,
                        width: 62,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEAF7EA),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flag_rounded,
                          color: Color(0xFF008000),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Edit Fitness Goals',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Your daily calorie goal updates automatically.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 24),

                      dialogLabel('Goal'),
                      DropdownButtonFormField<String>(
                        value: selectedGoal,
                        isExpanded: true,
                        decoration: fieldDecoration('Select goal'),
                        dropdownColor: const Color(0xFFF7FAF4),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF008000),
                        ),
                        items: goalOptions.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setModalState(() {
                            selectedGoal = value;

                            if (selectedGoal == 'keep_fit' && weightKg > 0) {
                              desiredController.text = weightKg.toStringAsFixed(
                                0,
                              );
                            }

                            refreshDailyGoalPreview();
                          });
                        },
                      ),

                      const SizedBox(height: 16),
                      dialogLabel('Desired Weight'),
                      TextField(
                        controller: desiredController,
                        enabled: selectedGoal != 'keep_fit',
                        keyboardType: TextInputType.number,
                        decoration: fieldDecoration('Desired weight in kg'),
                        onChanged: (_) {
                          setModalState(() {
                            refreshDailyGoalPreview();
                          });
                        },
                      ),

                      const SizedBox(height: 16),
                      dialogLabel('Daily Calorie Goal'),
                      TextField(
                        controller: dailyController,
                        readOnly: true,
                        decoration: fieldDecoration('Auto-calculated').copyWith(
                          prefixIcon: const Icon(
                            Icons.local_fire_department_rounded,
                            color: Color(0xFF008000),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFEAF7EA),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF245C24),
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAF4),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFDDE7D8)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFF008000),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This is based on your profile details such as age, gender, height, weight, activity level, goal, and goal weight.',
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.35,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 26),
                      Row(
                        children: [
                          dialogButton(
                            text: 'Cancel',
                            primary: false,
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                          const SizedBox(width: 12),
                          dialogButton(
                            text: 'Update',
                            primary: true,
                            onPressed: () async {
                              final newDesired =
                                  selectedGoal == 'keep_fit' && weightKg > 0
                                  ? weightKg
                                  : double.tryParse(
                                          desiredController.text.trim(),
                                        ) ??
                                        0;

                              final validationMessage =
                                  validateDesiredWeightForGoal(
                                    selectedGoal,
                                    newDesired,
                                  );

                              if (validationMessage != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(validationMessage),
                                    backgroundColor: const Color(0xFFE53935),
                                  ),
                                );
                                return;
                              }

                              final newDaily = calculateDailyGoalValue(
                                goal: selectedGoal,
                                desiredWeightValue: newDesired,
                              );

                              if (newDaily <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please complete your age, gender, height, weight, and activity level first.',
                                    ),
                                    backgroundColor: Color(0xFFE53935),
                                  ),
                                );
                                return;
                              }

                              final newGoalLabel =
                                  goalOptions[selectedGoal] ??
                                  titleCase(selectedGoal);

                              await LocalAuthStore.updateFitnessGoals(
                                goal: newGoalLabel,
                                desiredWeight: newDesired,
                                dailyGoal: newDaily,
                              );

                              LocalCalorieStore.setDailyGoal(newDaily);
                              if (!mounted) return;

                              setState(() {
                                goal = newGoalLabel;
                                desiredWeight = newDesired;
                                dailyGoal = newDaily;
                              });

                              Navigator.pop(dialogContext);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void openEditProfileDialog() {
    final usernameController = TextEditingController(text: username);
    final fullNameController = TextEditingController(text: fullName);
    final emailController = TextEditingController(text: email);
    final activityController = TextEditingController(text: activityLevel);
    final healthController = TextEditingController(text: healthCondition);
    final ageController = TextEditingController(
      text: age <= 0 ? '' : age.toString(),
    );
    final genderController = TextEditingController(text: gender);
    final heightController = TextEditingController(
      text: heightCm <= 0 ? '' : heightCm.toStringAsFixed(0),
    );
    final weightController = TextEditingController(
      text: weightKg <= 0 ? '' : weightKg.toStringAsFixed(0),
    );
    final bmiController = TextEditingController(
      text: bmi <= 0 ? '' : bmi.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.42),
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 30),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.82,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 54,
                    width: 54,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF7EA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.manage_accounts_rounded,
                      color: Color(0xFF008000),
                      size: 29,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Edit Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 24),
                  dialogLabel('Username'),
                  TextField(
                    controller: usernameController,
                    readOnly: true,
                    decoration: fieldDecoration('Username'),
                  ),
                  const SizedBox(height: 14),
                  dialogLabel('Full Name'),
                  TextField(
                    controller: fullNameController,
                    decoration: fieldDecoration('Full name'),
                  ),
                  const SizedBox(height: 14),
                  dialogLabel('Email'),
                  TextField(
                    controller: emailController,
                    readOnly: true,
                    keyboardType: TextInputType.emailAddress,
                    decoration: fieldDecoration('Email'),
                  ),
                  const SizedBox(height: 14),
                  dialogLabel('Age'),
                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: fieldDecoration('Age'),
                  ),
                  const SizedBox(height: 14),
                  dialogLabel('Gender'),
                  TextField(
                    controller: genderController,
                    readOnly: true,
                    decoration: fieldDecoration('Gender'),
                  ),
                  const SizedBox(height: 14),
                  dialogLabel('Height'),
                  TextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    decoration: fieldDecoration('Height in cm'),
                  ),
                  const SizedBox(height: 14),
                  dialogLabel('Weight'),
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: fieldDecoration('Weight in kg'),
                  ),
                  const SizedBox(height: 14),
                  dialogLabel('BMI'),
                  TextField(
                    controller: bmiController,
                    readOnly: true,
                    decoration: fieldDecoration('BMI'),
                  ),
                  const SizedBox(height: 14),
                  dialogLabel('Activity Level'),
                  TextField(
                    controller: activityController,
                    decoration: fieldDecoration('Activity level'),
                  ),
                  const SizedBox(height: 14),
                  dialogLabel('Health Condition'),
                  TextField(
                    controller: healthController,
                    decoration: fieldDecoration('Health condition'),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      dialogButton(
                        text: 'Cancel',
                        primary: false,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      dialogButton(
                        text: 'Update',
                        primary: true,
                        onPressed: () async {
                          final newName = fullNameController.text.trim();
                          final newEmail = emailController.text.trim();
                          final newActivity = activityController.text.trim();
                          final newHealth = healthController.text.trim();
                          final newAge =
                              int.tryParse(ageController.text.trim()) ?? age;
                          final newGender = genderController.text.trim();
                          final newHeight =
                              double.tryParse(heightController.text.trim()) ??
                              heightCm;
                          final newWeight =
                              double.tryParse(weightController.text.trim()) ??
                              weightKg;

                          final newBmi = calculateBmiValue(
                            weight: newWeight,
                            height: newHeight,
                          );
                          final newBmiStatus = getBmiStatusValue(newBmi);
                          final recalculatedDailyGoal = calculateDailyGoalValue(
                            goal: goal,
                            desiredWeightValue: desiredWeight,
                            ageValue: newAge,
                            genderValue: newGender,
                            heightValue: newHeight,
                            weightValue: newWeight,
                            activityValue: newActivity,
                          );

                          final normalizedHealth = newHealth.trim();
                          final normalizedHealthLower = normalizedHealth
                              .toLowerCase();
                          final hasHealthCondition =
                              normalizedHealth.isNotEmpty &&
                              normalizedHealthLower != 'no' &&
                              normalizedHealthLower != 'none' &&
                              normalizedHealthLower != 'n/a';
                          final savedHealthCondition = hasHealthCondition
                              ? normalizedHealth
                              : '';

                          final userId = await ApiSessionStore.getUserId();

                          if (!mounted) return;

                          if (userId <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please log in again before updating your profile.',
                                ),
                              ),
                            );
                            return;
                          }

                          await AuthApi.updateProfile(
                            userId: userId,
                            username: usernameController.text.trim(),
                            fullname: newName,
                            age: newAge,
                            gender: newGender,
                            height: newHeight,
                            weight: newWeight,
                            activityLevel: newActivity,
                            hasHealthConditions: newHealth.trim().isEmpty
                                ? 'No'
                                : 'Yes',
                            whatHealthConditions: newHealth.trim().isEmpty
                                ? null
                                : newHealth,
                          );
                          await LocalAuthStore.updateProfile(
                            fullName: newName,
                            email: newEmail,
                            activityLevel: newActivity,
                            healthCondition: savedHealthCondition,
                            age: newAge,
                            gender: newGender,
                            height: newHeight,
                            weight: newWeight,
                            bmi: newBmi,
                            bmiStatus: newBmiStatus,
                            dailyGoal: recalculatedDailyGoal > 0
                                ? recalculatedDailyGoal
                                : dailyGoal,
                          );

                          LocalUserStore.setFullName(newName);

                          if (recalculatedDailyGoal > 0) {
                            LocalCalorieStore.setDailyGoal(
                              recalculatedDailyGoal,
                            );
                          }
                          if (!mounted) return;

                          setState(() {
                            fullName = newName;
                            email = newEmail;
                            activityLevel = newActivity;
                            healthCondition = savedHealthCondition;
                            age = newAge;
                            gender = newGender;
                            heightCm = newHeight;
                            weightKg = newWeight;
                            bmi = newBmi;
                            bmiStatus = newBmiStatus;
                            if (recalculatedDailyGoal > 0) {
                              dailyGoal = recalculatedDailyGoal;
                            }
                          });

                          Navigator.pop(context);

                          if (mounted) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully.'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadProfilePhoto() async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedImage == null) {
        return;
      }

      final userId = await ApiSessionStore.getUserId();

      if (!mounted) {
        return;
      }

      if (userId <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please log in again before updating your profile picture.',
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading profile picture...')),
      );

      await AuthApi.uploadProfilePhoto(
        userId: userId,
        filePath: pickedImage.path,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _profilePhotoRefreshKey++;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile picture updated.')));
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile picture: $e')),
      );
    }
  }

  Widget avatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 104,
          width: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF12B81F), Color(0xFF008000)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF008000).withOpacity(0.20),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: ProfilePhotoAvatar(
              key: ValueKey(_profilePhotoRefreshKey),
              radius: 48,
              iconSize: 62,
              backgroundColor: Color(0xFF008000),
              iconColor: Colors.white,
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _pickAndUploadProfilePhoto,
            child: Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0EADC)),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Color(0xFF008000),
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget statItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF008000), size: 23),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF7EA),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Color(0xFF008000), size: 20),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget settingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final color = danger ? const Color(0xFFE53935) : const Color(0xFF008000);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: danger ? color : Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: danger ? color.withOpacity(0.6) : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  Widget divider() {
    return Container(height: 1, color: const Color(0xFFEAF0E5));
  }

  @override
  Widget build(BuildContext context) {
    final goalText = titleCase(goal);
    final desiredText = desiredWeight <= 0
        ? 'N/A'
        : '${desiredWeight.toStringAsFixed(0)} kg';
    final bmiText = bmi <= 0
        ? 'N/A'
        : '${bmi.toStringAsFixed(1)}${bmiStatus.isEmpty ? '' : ' $bmiStatus'}';

    final ageText = age <= 0 ? 'N/A' : age.toString();
    final genderText = gender.isEmpty ? 'N/A' : gender;
    final heightText = wholeNumberText(heightCm, 'cm');
    final weightText = wholeNumberText(weightKg, 'kg');

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF4),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF245C24),
                    size: 29,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.045),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  avatar(),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          email.isEmpty ? username : email,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 12.5,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF7EA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Account Profile',
                            style: TextStyle(
                              color: Color(0xFF008000),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.fromLTRB(17, 17, 8, 19),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFE4ECE0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'My Goals',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: Color(0xFF496548),
                        ),
                        onSelected: (value) {
                          if (value == 'edit') openEditGoalsDialog();
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit Goals'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      statItem(
                        icon: Icons.flag_rounded,
                        label: 'Goal',
                        value: goalText,
                      ),
                      Container(
                        width: 1,
                        height: 58,
                        color: const Color(0xFFEAF0E5),
                      ),
                      statItem(
                        icon: Icons.monitor_weight_rounded,
                        label: 'Goal Weight',
                        value: desiredText,
                      ),
                      Container(
                        width: 1,
                        height: 58,
                        color: const Color(0xFFEAF0E5),
                      ),
                      statItem(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Daily Goal',
                        value: '$dailyGoal kcal',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Profile Details',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFE4ECE0)),
              ),
              child: Column(
                children: [
                  detailRow(
                    icon: Icons.cake_rounded,
                    label: 'Age',
                    value: ageText,
                  ),
                  divider(),
                  detailRow(
                    icon: Icons.person_rounded,
                    label: 'Gender',
                    value: genderText,
                  ),
                  divider(),
                  detailRow(
                    icon: Icons.height_rounded,
                    label: 'Height',
                    value: heightText,
                  ),
                  divider(),
                  detailRow(
                    icon: Icons.monitor_weight_rounded,
                    label: 'Weight',
                    value: weightText,
                  ),
                  divider(),
                  detailRow(
                    icon: Icons.monitor_heart_rounded,
                    label: 'BMI',
                    value: bmiText,
                  ),
                  divider(),
                  detailRow(
                    icon: Icons.directions_run_rounded,
                    label: 'Activity Level',
                    value: activityLevel.isEmpty ? 'N/A' : activityLevel,
                  ),
                  divider(),
                  detailRow(
                    icon: Icons.health_and_safety_rounded,
                    label: 'Health Condition',
                    value: healthCondition.isEmpty ? 'None' : healthCondition,
                  ),
                  divider(),
                  settingsTile(
                    icon: Icons.bar_chart_rounded,
                    title: 'Weekly Progress',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WeeklyProgressScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'My Account',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFE4ECE0)),
              ),
              child: Column(
                children: [
                  settingsTile(
                    icon: Icons.edit_rounded,
                    title: 'Edit Profile',
                    onTap: openEditProfileDialog,
                  ),
                  divider(),
                  settingsTile(
                    icon: Icons.help_outline_rounded,
                    title: 'FAQs',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FAQsScreen(),
                        ),
                      );
                    },
                  ),
                  divider(),
                  settingsTile(
                    icon: Icons.lock_reset_rounded,
                    title: 'Change Password',
                    onTap: () => showComingSoon('Change Password'),
                  ),
                  divider(),
                  settingsTile(
                    icon: Icons.logout_rounded,
                    title: 'Log Out',
                    danger: true,
                    onTap: () {
                      LocalUserStore.setFullName('');
                      LocalCalorieStore.setDailyGoal(0);
                      LocalCalorieStore.clear();

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        LoginScreen.routeName,
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}