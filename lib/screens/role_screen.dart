import 'package:flutter/material.dart';

import '../features/admin/screens/admin_login_screen.dart';
import '../features/auth/screens/login/login_screen.dart';

class RoleScreen extends StatefulWidget {
  static const routeName = '/role';

  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  // Student is selected by default so the screen matches the target design
  // and Continue works immediately.
  String selectedRole = 'student';

  static const Color _green = Color(0xFF078A05);
  static const Color _background = Color(0xFFE7E7E7);

  void _selectRole(String role) {
    setState(() {
      selectedRole = role;
    });
  }

  void _continueToSelectedRole() {
    if (selectedRole == 'admin') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const AdminLoginScreen(),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentSelected = selectedRole == 'student';
    final adminSelected = selectedRole == 'admin';

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 390),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBrand(),
                        const SizedBox(height: 26),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Choose Your Role',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF242424),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 7),
                              const Text(
                                'Select how you will use the app.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 22),
                              _buildRoleCard(
                                role: 'student',
                                title: 'Student',
                                subtitle:
                                    'Track your fitness and\npersonal wellness goals.',
                                icon: Icons.school_rounded,
                                selected: studentSelected,
                              ),
                              const SizedBox(height: 12),
                              _buildRoleCard(
                                role: 'admin',
                                title: 'Admin',
                                subtitle:
                                    'Manage active accounts and\nuser violations.',
                                icon: Icons.admin_panel_settings_rounded,
                                selected: adminSelected,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _continueToSelectedRole,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _green,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: const Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: 92,
          height: 92,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: Color(0xFF32C63C),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: Colors.white,
                size: 45,
              ),
            );
          },
        ),
        const SizedBox(height: 9),
        const Text(
          'Fitness Go',
          style: TextStyle(
            color: Color(0xFF242424),
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
  }) {
    final cardColor = selected ? _green : const Color(0xFFF9F9F9);
    final titleColor = selected ? Colors.white : const Color(0xFF242424);
    final subtitleColor = selected ? Colors.white70 : Colors.black54;
    final borderColor = selected ? _green : const Color(0xFF168B2B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectRole(role),
        borderRadius: BorderRadius.circular(23),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 98),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withOpacity(0.96)
                      : const Color(0xFFEAF7EA),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: _green,
                  size: 28,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 11.5,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? Colors.white : _green,
                size: 23,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
