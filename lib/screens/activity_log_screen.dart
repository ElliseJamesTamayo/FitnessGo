import 'package:flutter/material.dart';

import '../data/local_calorie_store.dart';
import 'dashboard_screen.dart';

class ActivityLogScreen extends StatefulWidget {
  static const routeName = '/activity-log';

  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  int selectedTab = 0;
  DateTime selectedDate = DateTime.now();

  final List<Map<String, String>> workoutLogs = [
    {
      'name': 'Mountain Climbers',
      'details': '20 Reps × 3 Sets • Rest: 60s',
    },
    {
      'name': 'Jumping Jacks',
      'details': '12 Reps × 5 Sets • Rest: 60s',
    },
    {
      'name': 'Punches',
      'details': '30 Reps × 3 Sets • Rest: 60s',
    },
    {
      'name': 'Side Step Touch',
      'details': '20 Reps × 3 Sets • Rest: 60s',
    },
    {
      'name': 'Skater Step',
      'details': '15 Reps × 3 Sets • Rest: 60s',
    },
  ];

  final List<Map<String, String>> articleLogs = [
    {
      'title': 'Healthy Eating for All Life Stages',
      'source': 'NIDDK / U.S. Department of Health and Human Services',
    },
    {
      'title': 'Healthy Eating Tips: Your Nutrition',
      'source': 'CDC / U.S. Department of Health and Human Services',
    },
    {
      'title': 'Staying Active Safely and Confidently',
      'source': 'NIDDK / U.S. Department of Health and Human Services',
    },
    {
      'title': 'Choosing a Safe Weight-Loss Program',
      'source': 'NIDDK / U.S. Department of Health and Human Services',
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
            buildOverviewCard(),
            buildTabs(),
            Expanded(
              child: selectedTab == 0
                  ? buildWorkoutTab()
                  : selectedTab == 1
                      ? buildArticlesTab()
                      : buildFoodTab(),
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
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF7EA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_rounded,
              color: Color(0xFF168A2A),
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activity Log',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Review your saved activity history',
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

  Widget buildOverviewCard() {
    final selectedFoodCount = LocalCalorieStore.entriesForDate(selectedDate).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 4, 18, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF168A2A),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF168A2A).withOpacity(0.16),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          buildOverviewItem(
            icon: Icons.fitness_center_rounded,
            label: 'Workouts',
            value: '${workoutLogs.length}',
          ),
          buildDivider(),
          buildOverviewItem(
            icon: Icons.article_rounded,
            label: 'Articles',
            value: '${articleLogs.length}',
          ),
          buildDivider(),
          buildOverviewItem(
            icon: Icons.restaurant_rounded,
            label: 'Food',
            value: '$selectedFoodCount',
          ),
        ],
      ),
    );
  }

  Widget buildOverviewItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDivider() {
    return Container(
      height: 42,
      width: 1,
      color: Colors.white.withOpacity(0.22),
    );
  }

  Widget buildTabs() {
    final tabs = [
      ['Workouts', Icons.fitness_center_rounded],
      ['Articles', Icons.article_rounded],
      ['Food', Icons.restaurant_rounded],
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
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    selectedTab = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 48,
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF168A2A) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active
                          ? const Color(0xFF168A2A)
                          : const Color(0xFFE1E8DE),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(active ? 0.08 : 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: active ? Colors.white : const Color(0xFF168A2A),
                        size: 17,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: active ? Colors.white : Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
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

  Widget buildWorkoutTab() {
    if (workoutLogs.isEmpty) {
      return buildEmptyState(
        icon: Icons.fitness_center_rounded,
        title: 'No saved workouts',
        subtitle: 'Saved workouts will appear here.',
      );
    }

    return Column(
      children: [
        buildSectionLabel('Saved Workouts'),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
            itemCount: workoutLogs.length,
            itemBuilder: (context, index) {
              final item = workoutLogs[index];

              return buildModernLogCard(
                icon: workoutIcon(index),
                title: item['name'] ?? '',
                subtitle: item['details'] ?? '',
                onDelete: () {
                  setState(() {
                    workoutLogs.removeAt(index);
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildArticlesTab() {
    if (articleLogs.isEmpty) {
      return buildEmptyState(
        icon: Icons.article_rounded,
        title: 'No saved articles',
        subtitle: 'Saved articles will appear here.',
      );
    }

    return Column(
      children: [
        buildSectionLabel('Saved Articles'),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
            itemCount: articleLogs.length,
            itemBuilder: (context, index) {
              final item = articleLogs[index];

              return buildModernLogCard(
                icon: Icons.article_rounded,
                title: item['title'] ?? '',
                subtitle: item['source'] ?? '',
                onDelete: () {
                  setState(() {
                    articleLogs.removeAt(index);
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildFoodTab() {
    final entries = LocalCalorieStore.entriesForDate(selectedDate);

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
      children: [
        buildFoodHeader(),
        const SizedBox(height: 14),
        if (entries.isEmpty)
          buildEmptyState(
            icon: Icons.restaurant_rounded,
            title: 'No food logged',
            subtitle: 'No food entries were saved for this date.',
          )
        else
          ...List.generate(entries.length, (index) {
            final item = entries[index];

            return buildModernLogCard(
              icon: Icons.restaurant_menu_rounded,
              title: item['food'] ?? 'Food entry',
              subtitle: '${item['calories'] ?? '0'} kcal',
              onDelete: () {
                setState(() {
                  LocalCalorieStore.removeEntry(item);
                });
              },
            );
          }),
      ],
    );
  }

  Widget buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFoodHeader() {
    final total = LocalCalorieStore.totalForDate(selectedDate);

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: pickDate,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B6E1F),
              Color(0xFF168A2A),
              Color(0xFF35B653),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF168A2A).withOpacity(0.20),
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
                Icons.calendar_month_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Tap to open calendar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    'Calorie Intake Log',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${formattedDate(selectedDate)} • $total kcal',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.88),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.expand_more_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> pickDate() async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ActivityCalendarSheet(
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
      },
    );

    if (picked == null) return;

    setState(() {
      selectedDate = picked;
    });
  }
  Widget buildModernLogCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF7EA),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF168A2A),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13.5,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onDelete,
            child: Container(
              height: 38,
              width: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1F1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFD71919),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: Column(
        children: [
          Container(
            height: 76,
            width: 76,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF7EA),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF168A2A),
              size: 37,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  IconData workoutIcon(int index) {
    final icons = [
      Icons.directions_run_rounded,
      Icons.self_improvement_rounded,
      Icons.sports_mma_rounded,
      Icons.accessibility_new_rounded,
      Icons.directions_walk_rounded,
    ];

    return icons[index % icons.length];
  }

  String formattedDate(DateTime date) {
    const weekdays = [
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

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _ActivityCalendarSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _ActivityCalendarSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_ActivityCalendarSheet> createState() => _ActivityCalendarSheetState();
}

class _ActivityCalendarSheetState extends State<_ActivityCalendarSheet> {
  late DateTime visibleMonth;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    visibleMonth = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
    );
    selectedDate = DateUtils.dateOnly(widget.initialDate);
  }

  bool get canGoPrevious {
    final firstMonth = DateTime(widget.firstDate.year, widget.firstDate.month);
    return visibleMonth.isAfter(firstMonth);
  }

  bool get canGoNext {
    final lastMonth = DateTime(widget.lastDate.year, widget.lastDate.month);
    return visibleMonth.isBefore(lastMonth);
  }

  void goPreviousMonth() {
    if (!canGoPrevious) return;

    setState(() {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month - 1);
    });
  }

  void goNextMonth() {
    if (!canGoNext) return;

    setState(() {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFBF8),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
          bottom: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF7EA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFF168A2A),
                    size: 27,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Food Log Calendar',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Choose a date to view history',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            buildMonthSwitcher(),
            const SizedBox(height: 12),
            buildWeekdays(),
            const SizedBox(height: 6),
            buildCalendarGrid(),
            const SizedBox(height: 16),
            buildActions(),
          ],
        ),
      ),
    );
  }

  Widget buildMonthSwitcher() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE1E8DE),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: canGoPrevious ? goPreviousMonth : null,
            icon: Icon(
              Icons.chevron_left_rounded,
              color: canGoPrevious ? const Color(0xFF168A2A) : Colors.black26,
              size: 30,
            ),
          ),
          Expanded(
            child: Text(
              monthYearLabel(visibleMonth),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            onPressed: canGoNext ? goNextMonth : null,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: canGoNext ? const Color(0xFF168A2A) : Colors.black26,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWeekdays() {
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Row(
      children: days.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: const TextStyle(
                color: Colors.black45,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildCalendarGrid() {
    final firstDay = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final daysInMonth = DateTime(
      visibleMonth.year,
      visibleMonth.month + 1,
      0,
    ).day;

    final leadingBlankDays = firstDay.weekday % 7;
    final totalCells = ((leadingBlankDays + daysInMonth + 6) ~/ 7) * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 7,
        crossAxisSpacing: 7,
      ),
      itemBuilder: (context, index) {
        final dayNumber = index - leadingBlankDays + 1;

        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final day = DateTime(
          visibleMonth.year,
          visibleMonth.month,
          dayNumber,
        );

        final disabled = DateUtils.dateOnly(day).isBefore(
              DateUtils.dateOnly(widget.firstDate),
            ) ||
            DateUtils.dateOnly(day).isAfter(
              DateUtils.dateOnly(widget.lastDate),
            );

        final selected = DateUtils.isSameDay(day, selectedDate);
        final today = DateUtils.isSameDay(day, DateTime.now());

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: disabled
              ? null
              : () {
                  setState(() {
                    selectedDate = DateUtils.dateOnly(day);
                  });
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF168A2A)
                  : today
                      ? const Color(0xFFEAF7EA)
                      : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? const Color(0xFF168A2A)
                    : today
                        ? const Color(0xFFBFE7C3)
                        : const Color(0xFFE1E8DE),
              ),
            ),
            child: Center(
              child: Text(
                '$dayNumber',
                style: TextStyle(
                  color: disabled
                      ? Colors.black26
                      : selected
                          ? Colors.white
                          : const Color(0xFF1F261F),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF168A2A),
              side: const BorderSide(
                color: Color(0xFFBFE7C3),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context, selectedDate);
            },
            icon: const Icon(Icons.visibility_rounded),
            label: const Text(
              'View Log',
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF168A2A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String monthYearLabel(DateTime date) {
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

    return '${months[date.month - 1]} ${date.year}';
  }
}


