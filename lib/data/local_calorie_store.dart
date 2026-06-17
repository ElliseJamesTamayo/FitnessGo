class LocalCalorieStore {
  static int dailyGoal = 0;
  static int _totalIntake = 0;

  static final List<Map<String, String>> _entries = [];

  static String dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return "$year-$month-$day";
  }

  static String get todayKey => dateKey(DateTime.now());

  static void addEntry({
    required String food,
    required int calories,
  }) {
    _entries.insert(0, {
      'food': food,
      'calories': calories.toString(),
      'time': 'Today',
      'date': todayKey,
      'createdAt': DateTime.now().toIso8601String(),
    });

    _totalIntake += calories;
  }

  static List<Map<String, String>> get entries =>
      List.unmodifiable(_entries);

  static List<Map<String, String>> entriesForDate(DateTime date) {
    final key = dateKey(date);

    return List.unmodifiable(
      _entries.where((e) => (e['date'] ?? todayKey) == key).toList(),
    );
  }

  static int totalForDate(DateTime date) {
    return entriesForDate(date).fold(
      0,
      (sum, e) => sum + (int.tryParse(e['calories'] ?? '0') ?? 0),
    );
  }

  static int get totalIntake => _totalIntake;

  static int get remainingCalories => dailyGoal - totalIntake;

  static void setDailyGoal(int value) {
    dailyGoal = value;
  }

  static void removeEntry(Map<String, String> entry) {
    _entries.remove(entry);
  }

  static void clear() {
    _entries.clear();
    _totalIntake = 0;
  }
}
