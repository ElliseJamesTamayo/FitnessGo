class FoodItem {
  final String name;
  final double servingSizeG;
  final double calories;
  final double proteinG;
  final double fatG;
  final double carbsG;

  const FoodItem({
    required this.name,
    required this.servingSizeG,
    required this.calories,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
  });
}

class FilipinoFoodDatabase {
  static const List<FoodItem> items = [
    FoodItem(name: 'chicken adobo', servingSizeG: 100, calories: 128, proteinG: 14, fatG: 6, carbsG: 4),
    FoodItem(name: 'pork adobo', servingSizeG: 100, calories: 180, proteinG: 13, fatG: 14, carbsG: 2),
    FoodItem(name: 'beef adobo', servingSizeG: 100, calories: 165, proteinG: 15, fatG: 10, carbsG: 3),
    FoodItem(name: 'sinigang na baboy', servingSizeG: 100, calories: 112, proteinG: 9, fatG: 8, carbsG: 3),
    FoodItem(name: 'sinigang na hipon', servingSizeG: 100, calories: 98, proteinG: 11, fatG: 2, carbsG: 4),
    FoodItem(name: 'kare kare', servingSizeG: 100, calories: 150, proteinG: 8, fatG: 12, carbsG: 6),
    FoodItem(name: 'lechon kawali', servingSizeG: 100, calories: 320, proteinG: 18, fatG: 28, carbsG: 0),
    FoodItem(name: 'sisig', servingSizeG: 100, calories: 280, proteinG: 14, fatG: 24, carbsG: 2),
    FoodItem(name: 'chicken inasal', servingSizeG: 100, calories: 165, proteinG: 18, fatG: 9, carbsG: 4),
    FoodItem(name: 'tinola', servingSizeG: 100, calories: 90, proteinG: 12, fatG: 3, carbsG: 2),
    FoodItem(name: 'pinakbet', servingSizeG: 100, calories: 75, proteinG: 3, fatG: 4, carbsG: 9),
    FoodItem(name: 'lumpiang shanghai', servingSizeG: 100, calories: 265, proteinG: 11, fatG: 18, carbsG: 18),
    FoodItem(name: 'pancit canton', servingSizeG: 100, calories: 154, proteinG: 5, fatG: 5, carbsG: 22),
    FoodItem(name: 'pancit bihon', servingSizeG: 100, calories: 136, proteinG: 4, fatG: 3, carbsG: 25),
    FoodItem(name: 'tapsilog', servingSizeG: 100, calories: 190, proteinG: 12, fatG: 9, carbsG: 15),
    FoodItem(name: 'longsilog', servingSizeG: 100, calories: 220, proteinG: 10, fatG: 15, carbsG: 12),
    FoodItem(name: 'bibingka', servingSizeG: 100, calories: 215, proteinG: 5, fatG: 7, carbsG: 32),
    FoodItem(name: 'puto', servingSizeG: 100, calories: 180, proteinG: 4, fatG: 2, carbsG: 38),
    FoodItem(name: 'halo halo', servingSizeG: 100, calories: 120, proteinG: 3, fatG: 3, carbsG: 22),
    FoodItem(name: 'sinangag', servingSizeG: 100, calories: 165, proteinG: 4, fatG: 4, carbsG: 30),
    FoodItem(name: 'garlic rice with egg', servingSizeG: 100, calories: 180, proteinG: 6, fatG: 6, carbsG: 28),
  ];

  static FoodItem? findByName(String name) {
    final cleaned = name.trim().toLowerCase();

    for (final item in items) {
      if (item.name.toLowerCase() == cleaned) {
        return item;
      }
    }

    return null;
  }
}
