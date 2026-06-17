import 'package:flutter/material.dart';

import '../../widgets/app_logo.dart';

class DashboardHeader extends StatelessWidget {
  final VoidCallback onLogout;

  const DashboardHeader({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          const AppLogo(size: 46),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FitnessGo',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Home Dashboard',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onLogout,
            icon: const Icon(
              Icons.logout,
              color: Color(0xFF008000),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardHeroSummary extends StatelessWidget {
  const DashboardHeroSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF008000),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, User!',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Stay active and keep your progress going.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.35,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardCalorieBoxes extends StatelessWidget {
  final int intake;
  final int remaining;

  const DashboardCalorieBoxes({
    super.key,
    required this.intake,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final isOverGoal = remaining < 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Expanded(
            child: _DashboardCalorieBox(
              title: 'Calorie Intake',
              value: '$intake kcal',
              icon: Icons.restaurant_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DashboardCalorieBox(
              title: isOverGoal ? 'Over Goal' : 'Calorie Remaining',
              value: '${remaining.abs()} kcal',
              icon: isOverGoal
                  ? Icons.warning_rounded
                  : Icons.flag_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCalorieBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DashboardCalorieBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE1E8DE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF7EA),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF168A2A),
              size: 21,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF168A2A),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
class FitnessWallSection extends StatelessWidget {
  final List<Map<String, String>> userPosts;
  final VoidCallback? onCreatePost;
  final VoidCallback? onPostPhoto;

  const FitnessWallSection({
    super.key,
    required this.userPosts,
    this.onCreatePost,
    this.onPostPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final starterPosts = [
      {
        'name': 'FitnessGo Team',
        'time': 'Today',
        'content': 'Welcome to FitnessGo! Share your progress and stay consistent.',
      },
      {
        'name': 'System Reminder',
        'time': 'Today',
        'content': 'Track your meals, log your activities, and keep moving toward your goal.',
      },
    ];

    final posts = [
      ...userPosts,
      ...starterPosts,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fitness Wall',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          buildComposer(),
          const SizedBox(height: 14),
          ...posts.map((post) {
            return buildPostCard(post);
          }),
        ],
      ),
    );
  }

  Widget buildComposer() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE1E8DE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onCreatePost,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAF6),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE1E8DE),
                ),
              ),
              child: const Text(
                "What's on your mind?",
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCreatePost,
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Create Post'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF168A2A),
                    side: const BorderSide(
                      color: Color(0xFFBFE7C3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPostPhoto,
                  icon: const Icon(Icons.photo_rounded),
                  label: const Text('Photo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF168A2A),
                    side: const BorderSide(
                      color: Color(0xFFBFE7C3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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

  Widget buildPostCard(Map<String, String> post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE1E8DE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF7EA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF168A2A),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['name'] ?? 'User',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  post['time'] ?? 'Just now',
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  post['content'] ?? '',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class PostComposer extends StatelessWidget {
  final VoidCallback onCreatePost;
  final VoidCallback onPostPhoto;

  const PostComposer({
    super.key,
    required this.onCreatePost,
    required this.onPostPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFE8F5E9),
            child: Icon(
              Icons.person,
              color: Color(0xFF008000),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onCreatePost,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 17),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FFF7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFB7E4B7),
                    width: 1.2,
                  ),
                ),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "What's on your mind?",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onPostPhoto,
            child: const Icon(
              Icons.image,
              color: Color(0xFF008000),
              size: 27,
            ),
          ),
        ],
      ),
    );
  }
}

class FitnessWallPost extends StatelessWidget {
  final String name;
  final String time;
  final String content;
  final IconData icon;

  const FitnessWallPost({
    super.key,
    required this.name,
    required this.time,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 13),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE8F5E9),
                child: Icon(
                  icon,
                  color: const Color(0xFF008000),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.more_horiz,
                color: Colors.black38,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardBottomNavigation extends StatelessWidget {
  final VoidCallback onFitnessBuddy;
  final VoidCallback onCalorieCounter;
  final VoidCallback onHome;
  final VoidCallback onActivityLog;
  final VoidCallback onWellnessHub;

  const DashboardBottomNavigation({
    super.key,
    required this.onFitnessBuddy,
    required this.onCalorieCounter,
    required this.onHome,
    required this.onActivityLog,
    required this.onWellnessHub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      color: const Color(0xFFE6E6E6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _BottomNavItem(
              icon: Icons.smart_toy,
              label: 'Fitness\nBuddy',
              onTap: onFitnessBuddy,
            ),
            _BottomNavItem(
              icon: Icons.fastfood,
              label: 'Calorie\nCounter',
              onTap: onCalorieCounter,
            ),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: onHome,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      color: Color(0xFF008000),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 31,
                    ),
                  ),
                ),
              ),
            ),
            _BottomNavItem(
              icon: Icons.assignment,
              label: 'Activity\nLog',
              onTap: onActivityLog,
            ),
            _BottomNavItem(
              icon: Icons.spa,
              label: 'Wellness\nHub',
              onTap: onWellnessHub,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFF008000),
              size: 25,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 10,
                height: 1.05,
                color: Color(0xFF008000),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}










