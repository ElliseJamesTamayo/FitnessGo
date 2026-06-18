import 'package:flutter/material.dart';

import '../core/storage/api_session_store.dart';
import '../data/local_calorie_store.dart';
import '../features/caloriecounter/caloriecount.dart';
import 'dashboard_screen.dart';

class CalorieCounterScreen extends StatefulWidget {
  static const routeName = '/calorie-counter';

  const CalorieCounterScreen({super.key});

  @override
  State<CalorieCounterScreen> createState() => _CalorieCounterScreenState();
}

class _CalorieCounterScreenState extends State<CalorieCounterScreen> {
  final foodController = TextEditingController();
  final quantityController = TextEditingController();

  String selectedMeal = 'Breakfast';
  int calculatedCalories = 0;

  bool isLoadingLog = false;
  bool isCalculating = false;
  bool isSaving = false;

  int calorieIntake = 0;
  List<dynamic> foodLogs = [];

  @override
  void initState() {
    super.initState();
    loadFoodLogFromBackend();
  }

  @override
  void dispose() {
    foodController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  String todayDate() {
    return DateTime.now().toIso8601String().split('T').first;
  }

  int get calorieRemaining {
    return LocalCalorieStore.dailyGoal - calorieIntake;
  }

  int getIntValue(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.round() ?? 0;
    }
    return 0;
  }

  double getDoubleValue(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  String getStringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  String get foodName {
    return foodController.text.trim();
  }

  double get foodQuantity {
    return double.tryParse(quantityController.text.trim()) ?? 0;
  }

  List<dynamic> extractFoodList(Map<String, dynamic> result) {
    final possibleLists = [
      result['foods'],
      result['food'],
      result['entries'],
      result['items'],
      result['results'],
      result['data'],
    ];

    for (final item in possibleLists) {
      if (item is List) return item;

      if (item is Map) {
        final nestedLists = [
          item['foods'],
          item['food'],
          item['entries'],
          item['items'],
          item['results'],
          item['data'],
        ];

        for (final nestedItem in nestedLists) {
          if (nestedItem is List) return nestedItem;
        }
      }
    }

    return [];
  }

  int calculateTotalCaloriesFromLogs(List<dynamic> logs) {
    int total = 0;

    for (final entry in logs) {
      if (entry is Map) {
        total += getIntValue(entry['Calories'] ?? entry['calories']);
      }
    }

    return total;
  }

  void syncLocalCalorieStoreForDashboard(List<dynamic> logs) {
    // This is only a cache for dashboard compatibility.
    // The calories are loaded from backend food logs, not from a local food database.
    LocalCalorieStore.clear();

    for (final entry in logs) {
      if (entry is! Map) continue;

      final savedFoodName = getStringValue(
        entry['FoodName'] ??
            entry['foodName'] ??
            entry['food_name'] ??
            entry['food'],
      );

      final meal = getStringValue(
        entry['MealCategory'] ??
            entry['mealCategory'] ??
            entry['meal_category'],
      );

      final calories = getIntValue(entry['Calories'] ?? entry['calories']);

      if (savedFoodName.isEmpty || calories <= 0) continue;

      LocalCalorieStore.addEntry(
        food: meal.isEmpty ? savedFoodName : '$savedFoodName • $meal',
        calories: calories,
      );
    }
  }

  Future<void> loadFoodLogFromBackend() async {
    setState(() {
      isLoadingLog = true;
    });

    try {
      final userId = await ApiSessionStore.getUserId();

      if (userId == null || userId <= 0) {
        if (!mounted) return;

        setState(() {
          isLoadingLog = false;
          calorieIntake = 0;
          foodLogs = [];
        });
        return;
      }

      final result = await CalorieCounterApi.getFoodsByUserAndDate(
        userId: userId,
        logDate: todayDate(),
      );

      if (!mounted) return;

      if (result['success'] == false) {
        final message = CalorieCounterApi.asString(
          result['message'],
        ).toLowerCase();

        final statusCode = CalorieCounterApi.asInt(
          result['statusCode'] ?? result['status_code'],
        );

        setState(() {
          isLoadingLog = false;
          calorieIntake = 0;
          foodLogs = [];
        });

        // No food saved today should not show red "Not Found".
        if (statusCode == 404 || message.contains('not found')) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message.isEmpty ? 'Failed to load food log.' : message,
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final logs = extractFoodList(result);
      final total = calculateTotalCaloriesFromLogs(logs);

      syncLocalCalorieStoreForDashboard(logs);

      setState(() {
        foodLogs = logs;
        calorieIntake = total;
        isLoadingLog = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoadingLog = false;
        calorieIntake = 0;
        foodLogs = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading food log: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<int> getCaloriesFromBackend({
    bool showSuccessMessage = true,
  }) async {
    if (foodName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a food name first.'),
          backgroundColor: Colors.red,
        ),
      );
      return 0;
    }

    if (foodQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid food quantity in grams.'),
          backgroundColor: Colors.red,
        ),
      );
      return 0;
    }

    setState(() {
      isCalculating = true;
    });

    try {
      final result = await CalorieCounterApi.calculateCalories(
        foodName: foodName,
        foodQuantity: foodQuantity,
      );

      if (!mounted) return 0;

      if (result['success'] == false) {
        setState(() {
          isCalculating = false;
          calculatedCalories = 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              CalorieCounterApi.asString(result['message']).isEmpty
                  ? 'Failed to calculate calories.'
                  : CalorieCounterApi.asString(result['message']),
            ),
            backgroundColor: Colors.red,
          ),
        );

        return 0;
      }

      final calories = CalorieCounterApi.extractCalories(result);

      setState(() {
        calculatedCalories = calories;
        isCalculating = false;
      });

      if (calories <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No calories returned. Please check the food name.'),
            backgroundColor: Colors.red,
          ),
        );
        return 0;
      }

      if (showSuccessMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Calories calculated from backend.'),
            backgroundColor: Color(0xFF008000),
          ),
        );
      }

      return calories;
    } catch (error) {
      if (!mounted) return 0;

      setState(() {
        isCalculating = false;
        calculatedCalories = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error calculating calories: $error'),
          backgroundColor: Colors.red,
        ),
      );

      return 0;
    }
  }

  Future<void> saveCalories() async {
    if (foodName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a food name first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (foodQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid food quantity in grams.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int calories = calculatedCalories;

    if (calories <= 0) {
      calories = await getCaloriesFromBackend(showSuccessMessage: false);
    }

    if (calories <= 0) return;

    setState(() {
      isSaving = true;
    });

    try {
      final userId = await ApiSessionStore.getUserId();

      if (userId == null || userId <= 0) {
        if (!mounted) return;

        setState(() {
          isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final savedFoodName = foodName;
      final savedQuantity = foodQuantity;

      final result = await CalorieCounterApi.createFood(
        userId: userId,
        foodName: savedFoodName,
        foodQuantity: savedQuantity,
        mealCategory: selectedMeal,
        calories: calories.toDouble(),
      );

      if (!mounted) return;

      if (result['success'] == false) {
        setState(() {
          isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              CalorieCounterApi.asString(result['message']).isEmpty
                  ? 'Failed to save calories.'
                  : CalorieCounterApi.asString(result['message']),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        foodController.clear();
        quantityController.clear();
        calculatedCalories = 0;
        isSaving = false;
      });

      await loadFoodLogFromBackend();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calories saved to backend.'),
          backgroundColor: Color(0xFF008000),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving calories: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String foodLogTitle(dynamic entry) {
    if (entry is! Map) return '';

    final savedFoodName = getStringValue(
      entry['FoodName'] ??
          entry['foodName'] ??
          entry['food_name'] ??
          entry['food'],
    );

    final meal = getStringValue(
      entry['MealCategory'] ??
          entry['mealCategory'] ??
          entry['meal_category'],
    );

    final quantity = getDoubleValue(
      entry['FoodQuantity'] ??
          entry['foodQuantity'] ??
          entry['food_quantity'],
    );

    final buffer = StringBuffer();

    if (savedFoodName.isNotEmpty) {
      buffer.write(savedFoodName);
    }

    if (quantity > 0) {
      buffer.write(' • ${quantity.toStringAsFixed(quantity % 1 == 0 ? 0 : 1)}g');
    }

    if (meal.isNotEmpty) {
      buffer.write(' • $meal');
    }

    return buffer.toString().isEmpty ? 'Food item' : buffer.toString();
  }

  int foodLogCalories(dynamic entry) {
    if (entry is! Map) return 0;
    return getIntValue(entry['Calories'] ?? entry['calories']);
  }

  @override
  Widget build(BuildContext context) {
    final intake = calorieIntake;
    final left = calorieRemaining;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBF8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadFoodLogFromBackend,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
            children: [
              buildTopBar(),
              const SizedBox(height: 12),
              buildSubtitle(),
              const SizedBox(height: 16),
              buildSummaryRow(intake, left),
              const SizedBox(height: 18),
              buildInputCard(),
              const SizedBox(height: 16),
              buildRecentLog(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTopBar() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF008000),
            size: 29,
          ),
        ),
        Container(
          height: 52,
          width: 52,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.local_fire_department_rounded,
            color: Color(0xFF008000),
            size: 31,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Calorie Counter',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7EA),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFC7EBCB),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.flag_rounded,
                  color: Color(0xFF168A2A),
                  size: 17,
                ),
                const SizedBox(width: 6),
                Text(
                  'Daily Goal • ${LocalCalorieStore.dailyGoal} kcal',
                  style: const TextStyle(
                    color: Color(0xFF2B5F35),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isLoadingLog)
            const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget buildSummaryRow(int intake, int left) {
    return Row(
      children: [
        Expanded(
          child: buildSummaryBox(
            title: 'Calorie Intake',
            value: '$intake',
            icon: Icons.restaurant_menu_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: buildSummaryBox(
            title: left < 0 ? 'Over Goal' : 'Calorie Remaining',
            value: '${left.abs()}',
            icon: left < 0 ? Icons.warning_rounded : Icons.flag_rounded,
          ),
        ),
      ],
    );
  }

  Widget buildSummaryBox({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B8F2E),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.88),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE1E8DE)),
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
          buildLabel('Food Type'),
          buildFoodField(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildLabel('Quantity (g)'),
                    buildQuantityField(),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildLabel('Select Meal'),
                    buildMealDropdown(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          buildLabel('Food Calorie'),
          buildCalorieResult(),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: buildActionButton(
                  text: isCalculating ? 'Getting...' : 'Get Calories',
                  icon: Icons.calculate_rounded,
                  light: true,
                  onTap: isCalculating || isSaving
                      ? null
                      : () {
                          getCaloriesFromBackend();
                        },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildActionButton(
                  text: isSaving ? 'Saving...' : 'Save Calories',
                  icon: Icons.save_rounded,
                  light: false,
                  onTap: isSaving || isCalculating
                      ? null
                      : () {
                          saveCalories();
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget buildFoodField() {
    return TextField(
      controller: foodController,
      textInputAction: TextInputAction.next,
      onChanged: (_) {
        setState(() {
          calculatedCalories = 0;
        });
      },
      decoration: inputDecoration(
        hint: 'Search food',
        icon: Icons.fastfood_rounded,
      ),
    );
  }

  Widget buildQuantityField() {
    return TextField(
      controller: quantityController,
      keyboardType: TextInputType.number,
      onChanged: (_) {
        setState(() {
          calculatedCalories = 0;
        });
      },
      decoration: inputDecoration(
        hint: 'grams',
        icon: Icons.scale_rounded,
      ),
    );
  }

  Widget buildMealDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedMeal,
      isExpanded: true,
      decoration: inputDecoration(
        hint: 'Meal',
        icon: Icons.arrow_drop_down_circle_rounded,
      ),
      items: const [
        DropdownMenuItem(value: 'Breakfast', child: Text('Breakfast')),
        DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
        DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
        DropdownMenuItem(value: 'Snack', child: Text('Snack')),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          selectedMeal = value;
        });
      },
    );
  }

  Widget buildCalorieResult() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E8DE)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: isCalculating
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                calculatedCalories <= 0 ? '0 kcal' : '$calculatedCalories kcal',
                style: const TextStyle(
                  color: Color(0xFF008000),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }

  Widget buildActionButton({
    required String text,
    required IconData icon,
    required bool light,
    required VoidCallback? onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: light ? Colors.white : const Color(0xFF1B8F2E),
        foregroundColor: light ? const Color(0xFF1B8F2E) : Colors.white,
        elevation: light ? 0 : 2,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        side: const BorderSide(
          color: Color(0xFF168A2A),
          width: 1.3,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF008000)),
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.black38,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAF6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE1E8DE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE1E8DE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF008000), width: 1.4),
      ),
    );
  }

  Widget buildRecentLog() {
    final entries = foodLogs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Food Log',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        if (isLoadingLog && entries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE1E8DE)),
            ),
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (entries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE1E8DE)),
            ),
            child: const Text(
              'No saved food yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          ...entries.map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE1E8DE)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.restaurant_rounded,
                    color: Color(0xFF008000),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      foodLogTitle(entry),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Text(
                    '${foodLogCalories(entry)} kcal',
                    style: const TextStyle(
                      color: Color(0xFF008000),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
