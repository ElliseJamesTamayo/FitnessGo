import 'package:flutter/material.dart';

import 'dashboard_screen.dart';

class WellnessHubScreen extends StatefulWidget {
  static const routeName = '/wellness-hub';

  const WellnessHubScreen({super.key});

  @override
  State<WellnessHubScreen> createState() => _WellnessHubScreenState();
}

class _WellnessHubScreenState extends State<WellnessHubScreen> {
  int selectedTab = 0;

  final List<Map<String, String>> allArticles = [
    {
      'category': 'HEALTH',
      'title': 'Move More, Stress Less: A Healthier Mind and Body',
      'meta': 'NIDDK • 2019',
      'tag': 'Featured',
    },
    {
      'category': 'FITNESS',
      'title': 'Choosing a Safe Weight-Loss Program',
      'meta': '2024',
    },
    {
      'category': 'NUTRITION',
      'title': 'Healthy Eating for Better Energy',
      'meta': '2023',
    },
    {
      'category': 'LIFESTYLE',
      'title': 'Building Better Daily Habits',
      'meta': '2022',
    },
  ];

  final List<Map<String, String>> exercisePrograms = [
    {
      'quote': 'Consistency beats perfection every time.',
      'level': 'Beginner',
      'count': '10 Workouts',
    },
    {
      'quote': 'Train with purpose! Grow with discipline!',
      'level': 'Intermediate',
      'count': '10 Workouts',
    },
    {
      'quote': 'Push harder. Recover smarter. Stay focused.',
      'level': 'Advanced',
      'count': '10 Workouts',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBF8),
      body: SafeArea(
        child: Column(
          children: [
            buildHeader(),
            buildHeroCard(),
            buildTabs(),
            Expanded(
              child: selectedTab == 0
                  ? buildArticlesTab()
                  : buildExercisesTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 18, 8),
      child: Row(
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
              color: Color(0xFF168A2A),
              size: 29,
            ),
          ),
          Container(
            height: 50,
            width: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF7EA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.spa_rounded,
              color: Color(0xFF168A2A),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wellness Hub',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Explore helpful wellness content',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeroCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 4, 18, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F7C23),
            Color(0xFF1E9F36),
            Color(0xFF5ACD70),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF168A2A).withOpacity(0.14),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wellness for you',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Articles and exercise content in one clean, feel-good space.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTabs() {
    final tabs = [
      ['Articles', Icons.article_rounded],
      ['Exercises', Icons.fitness_center_rounded],
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final active = selectedTab == index;
          final label = tabs[index][0] as String;
          final icon = tabs[index][1] as IconData;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 5,
                right: index == tabs.length - 1 ? 0 : 5,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () {
                  setState(() {
                    selectedTab = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 50,
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF168A2A) : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: active
                          ? const Color(0xFF168A2A)
                          : const Color(0xFFE3EADF),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(active ? 0.07 : 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: active ? Colors.white : const Color(0xFF168A2A),
                        size: 18,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        label,
                        style: TextStyle(
                          color: active ? Colors.white : Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget buildArticlesTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
      children: [
        const Text(
          'Posts for you',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        buildFeaturedArticleCard(),
        const SizedBox(height: 18),
        const Text(
          'All Articles',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        ...allArticles.skip(1).map((item) {
          return buildArticleListCard(
            category: item['category'] ?? '',
            title: item['title'] ?? '',
            meta: item['meta'] ?? '',
          );
        }),
      ],
    );
  }

  Widget buildExercisesTab() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
      itemCount: exercisePrograms.length,
      itemBuilder: (context, index) {
        final item = exercisePrograms[index];

        return buildExerciseCard(
          index: index,
          quote: item['quote'] ?? '',
          level: item['level'] ?? '',
          count: item['count'] ?? '',
        );
      },
    );
  }

  Widget buildFeaturedArticleCard() {
    final item = allArticles.first;

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Featured article details can be added next.'),
          ),
        );
      },
      child: Container(
        decoration: cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D6E8E),
                    Color(0xFF0A5672),
                    Color(0xFF1B3B4F),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 24,
                    right: 22,
                    child: Container(
                      height: 78,
                      width: 78,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 58,
                    left: 24,
                    child: Container(
                      height: 118,
                      width: 118,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 18,
                    left: 18,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        item['tag'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 22,
                    right: 22,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['category'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['title'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            height: 1.07,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item['meta'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildArticleListCard({
    required String category,
    required String title,
    required String meta,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(),
      child: Row(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE7F5E6),
                  Color(0xFFCEE9CC),
                ],
              ),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFF168A2A),
              size: 34,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildMiniLabel(category),
                const SizedBox(height: 7),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    height: 1.12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  meta,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF168A2A),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget buildExerciseCard({
    required int index,
    required String quote,
    required String level,
    required String count,
  }) {
    final icon = index == 0
        ? Icons.directions_run_rounded
        : index == 1
            ? Icons.fitness_center_rounded
            : Icons.local_fire_department_rounded;

    final List<Color> topColors = index == 0
        ? [const Color(0xFF2F9E44), const Color(0xFF74C882)]
        : index == 1
            ? [const Color(0xFF2D6A4F), const Color(0xFF74A98B)]
            : [const Color(0xFF0B6E1F), const Color(0xFF35B653)];

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$level workout details can be added next.'),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: topColors,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 18,
                    top: 18,
                    child: Container(
                      height: 72,
                      width: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 18,
                    child: Container(
                      height: 58,
                      width: 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 18,
                    bottom: 18,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        level,
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quote,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      height: 1.17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$level | $count',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMiniLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF2E7D32),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: const Color(0xFFE4EBE1),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.035),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}



