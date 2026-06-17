import 'dart:math';

import 'package:flutter/material.dart';

import '../data/local_auth_store.dart';
import '../data/local_calorie_store.dart';

class WeeklyProgressScreen extends StatefulWidget {
  const WeeklyProgressScreen({super.key});

  @override
  State<WeeklyProgressScreen> createState() => _WeeklyProgressScreenState();
}

class _WeeklyProgressScreenState extends State<WeeklyProgressScreen> {
  static const int caloriesPerKgFat = 7700;

  DateTime selectedWeekStart = _mondayOf(DateTime.now());

  String goal = '';
  String activityLevel = '';
  String gender = '';

  int age = 0;
  int dailyGoal = 0;

  double heightCm = 0;
  double weightKg = 0;

  List<_DayCalories> weeklyCalories = [];

  int averageIntake = 0;
  int recordedTotal = 0;
  int loggedDays = 0;
  int daysOnTrack = 0;
  double adherence = 0;
  int targetDifference = 0;
  int maintenanceCalories = 0;
  double estimatedChange = 0;

  static DateTime _mondayOf(DateTime date) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    return cleanDate.subtract(Duration(days: cleanDate.weekday - 1));
  }

  DateTime get currentWeekStart => _mondayOf(DateTime.now());

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final savedGoal = await LocalAuthStore.getGoal();
    final savedDailyGoal = await LocalAuthStore.getDailyGoal();
    final savedAge = await LocalAuthStore.getAge();
    final savedGender = await LocalAuthStore.getGender();
    final savedHeight = await LocalAuthStore.getHeight();
    final savedWeight = await LocalAuthStore.getWeight();
    final savedActivity = await LocalAuthStore.getActivityLevel();

    final days = List.generate(7, (index) {
      final date = selectedWeekStart.add(Duration(days: index));
      return _DayCalories(
        date: date,
        calories: LocalCalorieStore.totalForDate(date),
      );
    });

    final target = savedDailyGoal > 0 ? savedDailyGoal : LocalCalorieStore.dailyGoal;

    final validDays = days.where((day) => day.calories > 0).toList();
    final total = validDays.fold<int>(0, (sum, day) => sum + day.calories);
    final logged = validDays.length;
    final average = logged > 0 ? (total / logged).round() : 0;

    int onTrack = 0;

    if (target > 0) {
      final lower = target * 0.95;
      final upper = target * 1.05;

      for (final day in validDays) {
        if (day.calories >= lower && day.calories <= upper) {
          onTrack++;
        }
      }
    }

    final adherenceValue = logged > 0 ? (onTrack / logged) * 100 : 0.0;
    final targetDiff = total - (target * logged);

    final maintenance = calculateMaintenanceCalories(
      weight: savedWeight,
      height: savedHeight,
      ageValue: savedAge,
      genderValue: savedGender,
      activityValue: savedActivity,
    );

    double change = 0;

    if (logged > 0 && maintenance > 0) {
      final projectedWeeklyIntake = average * 7;
      final projectedWeeklyMaintenance = maintenance * 7;
      final balance = projectedWeeklyIntake - projectedWeeklyMaintenance;
      change = double.parse((balance / caloriesPerKgFat).toStringAsFixed(2));
    }

    if (!mounted) return;

    setState(() {
      goal = savedGoal;
      dailyGoal = target;
      age = savedAge;
      gender = savedGender;
      heightCm = savedHeight;
      weightKg = savedWeight;
      activityLevel = savedActivity;

      weeklyCalories = days;
      recordedTotal = total;
      loggedDays = logged;
      averageIntake = average;
      daysOnTrack = onTrack;
      adherence = adherenceValue;
      targetDifference = targetDiff;
      maintenanceCalories = maintenance;
      estimatedChange = change;
    });
  }

  int calculateMaintenanceCalories({
    required double weight,
    required double height,
    required int ageValue,
    required String genderValue,
    required String activityValue,
  }) {
    if (weight <= 0 || height <= 0 || ageValue <= 0) return 0;

    final cleanedGender = genderValue.trim().toLowerCase();

    double bmr;

    if (cleanedGender == 'male' || cleanedGender == 'm') {
      bmr = (10 * weight) + (6.25 * height) - (5 * ageValue) + 5;
    } else if (cleanedGender == 'female' || cleanedGender == 'f') {
      bmr = (10 * weight) + (6.25 * height) - (5 * ageValue) - 161;
    } else {
      return 0;
    }

    final cleanedActivity = activityValue.trim().toLowerCase();

    final factors = {
      'not very active': 1.2,
      'lightly active': 1.375,
      'active': 1.55,
      'very active': 1.725,
    };

    final factor = factors[cleanedActivity] ?? 1.2;

    return (bmr * factor).round();
  }

  String normalizeGoal(String value) {
    final cleaned = value.trim().toLowerCase().replaceAll(' ', '_');

    const goals = {
      'gain_muscles': 'gain_muscle',
      'gain_muscle': 'gain_muscle',
      'lose_weight': 'lose_weight',
      'gain_weight': 'gain_weight',
      'keep_fit': 'keep_fit',
    };

    return goals[cleaned] ?? cleaned;
  }

  String titleCase(String value) {
    if (value.trim().isEmpty) return 'N/A';

    return value
        .replaceAll('_', ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  String weekRangeText() {
    final end = selectedWeekStart.add(const Duration(days: 6));

    if (selectedWeekStart.month == end.month) {
      return '${monthName(selectedWeekStart.month)} ${selectedWeekStart.day} – ${end.day}, ${end.year}';
    }

    return '${monthName(selectedWeekStart.month)} ${selectedWeekStart.day} – ${monthName(end.month)} ${end.day}, ${end.year}';
  }

  bool get isCurrentWeek {
    return !selectedWeekStart.isBefore(currentWeekStart);
  }

  void previousWeek() {
    setState(() {
      selectedWeekStart = selectedWeekStart.subtract(const Duration(days: 7));
    });
    loadProgress();
  }

  void nextWeek() {
    final proposed = selectedWeekStart.add(const Duration(days: 7));

    if (proposed.isAfter(currentWeekStart)) return;

    setState(() {
      selectedWeekStart = proposed;
    });
    loadProgress();
  }

  Future<void> pickWeek() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedWeekStart,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF008000),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    var weekStart = _mondayOf(picked);

    if (weekStart.isAfter(currentWeekStart)) {
      weekStart = currentWeekStart;
    }

    setState(() {
      selectedWeekStart = weekStart;
    });

    loadProgress();
  }

  Color barColor(int calories) {
    if (calories <= 0) return const Color(0xFFD7DED3);

    final lower = dailyGoal * 0.95;
    final upper = dailyGoal * 1.05;

    if (dailyGoal <= 0) return const Color(0xFF18A918);
    if (calories >= lower && calories <= upper) return const Color(0xFF18A918);
    if (calories < lower) return const Color(0xFFFFA726);

    return const Color(0xFFD64242);
  }

  double chartMax() {
    final values = weeklyCalories.map((day) => day.calories.toDouble()).toList();

    if (dailyGoal > 0) values.add(dailyGoal.toDouble());

    if (values.isEmpty || values.every((value) => value <= 0)) return 2500;

    final biggest = values.reduce(max);
    return max(500, (biggest * 1.2 / 500).ceil() * 500).toDouble();
  }

  String targetDifferenceText() {
    if (loggedDays == 0) return 'No food records available';

    if (targetDifference > 0) {
      return '${targetDifference.abs()} cal above target across logged days';
    }

    if (targetDifference < 0) {
      return '${targetDifference.abs()} cal below target across logged days';
    }

    return 'Recorded intake matches the logged-day target';
  }

  String projectionText() {
    if (loggedDays == 0 || maintenanceCalories <= 0) {
      return 'Projection unavailable';
    }

    if (estimatedChange < -0.01) {
      return 'Rough projection: ${estimatedChange.abs().toStringAsFixed(2)} kg loss';
    }

    if (estimatedChange > 0.01) {
      return 'Rough projection: ${estimatedChange.toStringAsFixed(2)} kg gain';
    }

    return 'Rough projection: near maintenance';
  }

  String insightTitle() {
    if (loggedDays == 0) return 'No Records Yet';
    if (maintenanceCalories <= 0) return 'Target Progress';
    if (estimatedChange < -0.01) return 'Projected Weight Loss';
    if (estimatedChange > 0.01) return 'Projected Weight Gain';
    return 'Near Maintenance';
  }

  String insightMessage() {
    if (loggedDays == 0) {
      return 'Log your food intake to view your weekly progress.';
    }

    if (maintenanceCalories <= 0) {
      return 'You were within your calorie target on $daysOnTrack of $loggedDays logged days. A weight projection is unavailable because maintenance calories could not be calculated.';
    }

    if (estimatedChange < -0.01) {
      return 'Based on your average recorded intake, your rough weekly projection is about ${estimatedChange.abs().toStringAsFixed(2)} kg loss. Target adherence: ${adherence.toStringAsFixed(0)}%.';
    }

    if (estimatedChange > 0.01) {
      return 'Based on your average recorded intake, your rough weekly projection is about ${estimatedChange.toStringAsFixed(2)} kg gain. Target adherence: ${adherence.toStringAsFixed(0)}%.';
    }

    return 'Your average recorded intake is close to estimated maintenance.';
  }

  Widget header() {
    return Row(
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
            'Weekly Progress',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        IconButton(
          onPressed: pickWeek,
          icon: const Icon(
            Icons.calendar_month_rounded,
            color: Color(0xFF008000),
            size: 27,
          ),
        ),
      ],
    );
  }

  Widget card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE4ECE0),
        ),
      ),
      child: child,
    );
  }

  Widget weekSelector() {
    return card(
      child: Row(
        children: [
          IconButton(
            onPressed: previousWeek,
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFF008000),
              size: 30,
            ),
          ),
          Expanded(
            child: Text(
              weekRangeText(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            onPressed: isCurrentWeek ? null : nextWeek,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: isCurrentWeek
                  ? const Color(0xFFB8C4B5)
                  : const Color(0xFF008000),
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget metricTile(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAF4),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF008000), size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black45,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryCard() {
    final goalDisplay = titleCase(normalizeGoal(goal));
    final targetText = dailyGoal > 0 ? '$dailyGoal cal/day' : '--';

    return card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goal: $goalDisplay | Target: $targetText',
            style: const TextStyle(
              color: Color(0xFF008000),
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              metricTile(
                'AVERAGE INTAKE',
                '$averageIntake cal/day',
                Icons.restaurant_rounded,
              ),
              const SizedBox(width: 10),
              metricTile(
                'RECORDED TOTAL',
                '$recordedTotal cal\n$loggedDays logged days',
                Icons.summarize_rounded,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Days within target range: ${adherence.toStringAsFixed(0)}% ($daysOnTrack/$loggedDays days)\n${targetDifferenceText()}\n${projectionText()}',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget chartBar(_DayCalories day, double maxValue) {
    const chartHeight = 135.0;
    final ratio = maxValue <= 0 ? 0.0 : min(day.calories / maxValue, 1.0);
    final barHeight = day.calories > 0 ? max(8.0, ratio * chartHeight) : 4.0;

    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayLabel = dayNames[day.date.weekday - 1];

    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: chartHeight,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 24,
                height: barHeight,
                decoration: BoxDecoration(
                  color: barColor(day.calories),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            dayLabel,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            day.calories.toString(),
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget chartCard() {
    final maxValue = chartMax();

    return card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Daily Calories',
                  style: TextStyle(
                    color: Color(0xFF008000),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                dailyGoal > 0 ? 'Target: $dailyGoal cal' : 'Target: --',
                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 205,
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklyCalories.map((day) => chartBar(day, maxValue)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget insightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EA),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFDDE7D8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.insights_rounded,
            color: Color(0xFF008000),
            size: 28,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insightTitle(),
                  style: const TextStyle(
                    color: Color(0xFF008000),
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  insightMessage(),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.35,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF4),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          children: [
            header(),
            const SizedBox(height: 14),
            weekSelector(),
            const SizedBox(height: 16),
            summaryCard(),
            const SizedBox(height: 14),
            chartCard(),
            const SizedBox(height: 14),
            insightCard(),
          ],
        ),
      ),
    );
  }
}

class _DayCalories {
  final DateTime date;
  final int calories;

  const _DayCalories({
    required this.date,
    required this.calories,
  });
}


