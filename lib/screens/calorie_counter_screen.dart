import 'package:flutter/material.dart';

import '../data/filipino_food_database.dart';
import '../data/local_calorie_store.dart';
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
  FoodItem? selectedFood;

  @override
  void dispose() {
    foodController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  void recalculateCalories() {
    final foodName = foodController.text.trim();
    final quantity = double.tryParse(quantityController.text.trim()) ?? 0;
    final food = FilipinoFoodDatabase.findByName(foodName);

    setState(() {
      selectedFood = food;

      if (food == null || quantity <= 0) {
        calculatedCalories = 0;
        return;
      }

      calculatedCalories =
          ((food.calories / food.servingSizeG) * quantity).round();
    });
  }
  void getCalories() {
    final foodName = foodController.text.trim();
    final quantity = double.tryParse(quantityController.text.trim()) ?? 0;

    final food = FilipinoFoodDatabase.findByName(foodName);

    if (food == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food not found. Choose a food from the suggestions.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid food quantity in grams.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      selectedFood = food;
      calculatedCalories = ((food.calories / food.servingSizeG) * quantity).round();
    });
  }

  void saveCalories() {
    if (calculatedCalories <= 0 || selectedFood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tap Get Calories first before saving.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    LocalCalorieStore.addEntry(
      food: '${selectedFood!.name} • $selectedMeal',
      calories: calculatedCalories,
    );

    setState(() {
      foodController.clear();
      quantityController.clear();
      selectedFood = null;
      calculatedCalories = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calories saved.'),
        backgroundColor: Color(0xFF008000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final intake = LocalCalorieStore.totalIntake;
    final left = LocalCalorieStore.remainingCalories;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBF8),
      body: SafeArea(
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
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
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
          buildFoodAutocomplete(),
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
          SizedBox(
            width: double.infinity,
            child: buildActionButton(
              text: 'Save Calories',
              icon: Icons.save_rounded,
              light: false,
              onTap: saveCalories,
            ),
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

  Widget buildFoodAutocomplete() {
    return Autocomplete<FoodItem>(
      displayStringForOption: (item) => item.name,
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.toLowerCase();

        if (query.isEmpty) {
          return FilipinoFoodDatabase.items.take(8);
        }

        return FilipinoFoodDatabase.items.where(
          (item) => item.name.toLowerCase().contains(query),
        );
      },
      onSelected: (item) {
        foodController.text = item.name;
        selectedFood = item;
        recalculateCalories();
      },
      fieldViewBuilder: (
        context,
        controller,
        focusNode,
        onFieldSubmitted,
      ) {
        foodController.text = controller.text;

        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (value) {
            foodController.text = value;
            recalculateCalories();
          },
          decoration: inputDecoration(
            hint: 'Search Filipino food',
            icon: Icons.fastfood_rounded,
          ),
        );
      },
    );
  }

  Widget buildQuantityField() {
    return TextField(
      controller: quantityController,
      keyboardType: TextInputType.number,
      onChanged: (_) {
        recalculateCalories();
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
        child: Text(
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
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: light ? Colors.white : const Color(0xFF1B8F2E),
        foregroundColor: light ? const Color(0xFF1B8F2E) : Colors.white,
        elevation: light ? 0 : 2,
        padding: const EdgeInsets.symmetric(vertical: 14),
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
    final entries = LocalCalorieStore.entries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Food Log',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        if (entries.isEmpty)
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
                      entry['food'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${entry['calories']} kcal',
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












