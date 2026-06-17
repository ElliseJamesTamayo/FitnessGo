import 'package:flutter/material.dart';

import '../data/local_post_store.dart';
import 'create_post_screen.dart';
import 'dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String getTodayText() {
    final now = DateTime.now();

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  Future<void> openCreatePost() async {
    final result = await Navigator.pushNamed(
      context,
      CreatePostScreen.routeName,
    );

    if (result is! Map) {
      return;
    }

    LocalPostStore.add(result);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final posts = LocalPostStore.profilePosts;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            buildHeader(),
            const SizedBox(height: 16),
            buildComposer(),
            const SizedBox(height: 18),
            buildSectionTitle(posts.length),
            const SizedBox(height: 10),
            if (posts.isEmpty)
              buildEmptyState()
            else
              ...posts.map(buildPostCard),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 12, 22, 0),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF008000),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    DashboardScreen.routeName,
                  );
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const Expanded(
                child: Text(
                  'My Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 32,
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(
                Icons.person_rounded,
                color: Color(0xFF008000),
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'User',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            getTodayText(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.88),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              buildMiniStat('Posts', '${LocalPostStore.profilePostCount}'),
              buildMiniDivider(),
              buildMiniStat('Goal', 'Fit'),
              buildMiniDivider(),
              buildMiniStat('Status', 'Active'),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMiniStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMiniDivider() {
    return Container(
      height: 28,
      width: 1,
      color: Colors.white.withOpacity(0.25),
    );
  }

  Widget buildComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFE8F5E9),
            child: Icon(
              Icons.person_rounded,
              color: Color(0xFF008000),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: openCreatePost,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 17),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7F1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFDCE8D8),
                  ),
                ),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "What's on your mind?",
                    style: TextStyle(
                      color: Color(0xFF386B38),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.edit_rounded,
            color: Color(0xFF008000),
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'My Posts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count total',
              style: const TextStyle(
                color: Color(0xFF008000),
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE1E8DE),
        ),
      ),
      child: Column(
        children: const [
          Icon(
            Icons.post_add_rounded,
            color: Color(0xFF008000),
            size: 42,
          ),
          SizedBox(height: 10),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Share your first fitness update.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPostCard(Map<String, String> post) {
    final content = post['content'] ?? '';
    final audience = post['audience'] ?? 'Public';
    final isOnlyMe = audience == 'Only Me';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE1E8DE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildPostHeader(isOnlyMe, audience, post),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 17,
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

  Widget buildPostHeader(
    bool isOnlyMe,
    String audience,
    Map<String, String> post,
  ) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 27,
          backgroundColor: Color(0xFFE8F5E9),
          child: Icon(
            Icons.person_rounded,
            color: Color(0xFF008000),
            size: 34,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'User',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    isOnlyMe ? Icons.lock_rounded : Icons.public_rounded,
                    color: const Color(0xFF008000),
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    post['time'] ?? 'Just now',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.more_vert_rounded,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }
}





