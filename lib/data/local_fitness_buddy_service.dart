class LocalFitnessBuddyService {
  static String? _currentFlow;
  static String? _goal;
  static String? _level;
  static String? _condition;

  static List<String> _suggestions = [
    'BMI',
    'Calories',
    'Workout',
    'Motivation',
    'Articles',
    'Tips',
  ];

  static List<String> get suggestions => List.unmodifiable(_suggestions);

  static String reply(String message) {
    final msg = message.toLowerCase().trim();

    if (msg.isEmpty) {
      return 'Type a message so I can help you.';
    }

    if (_hasAny(msg, ['cancel', 'reset', 'start over', 'stop'])) {
      _reset();
      return 'No worries. We can start fresh.\n\nWhat would you like to do next?';
    }

    if (_currentFlow == 'workout') {
      return _continueWorkoutFlow(msg);
    }

    if (_hasAny(msg, ['hi', 'hello', 'hey', 'kamusta'])) {
      _suggestions = ['BMI', 'Calories', 'Workout', 'Motivation'];
      return 'Hi! I am your FitnessGo Assistant.\n\nI can guide you with BMI, calories, workout planning, motivation, and wellness tips.';
    }

    if (_hasAny(msg, [
      'tired',
      'exhausted',
      'burnt out',
      'sad',
      'stressed',
      'anxious',
      'unmotivated',
      'discouraged',
      'giving up'
    ])) {
      _suggestions = ['Motivation', 'Tips', 'Workout', 'Cancel'];
      return 'I hear you. It is okay to feel that way.\n\nFor today, keep it simple: drink water, eat something balanced, stretch lightly, and avoid forcing an intense workout if your body needs rest.';
    }

    if (_hasAny(msg, ['motivate', 'motivation', 'quote', 'inspire', 'encourage'])) {
      _suggestions = ['Workout', 'Tips', 'Calories'];
      return 'Small progress still counts.\n\nYou do not need to do everything today. Just choose one good next step and follow through.';
    }

    if (_hasAny(msg, ['bmi', 'height', 'weight', 'kg', 'cm'])) {
      _suggestions = ['170 cm and 65 kg', 'Workout', 'Calories'];
      return _bmiReply(msg);
    }

    if (_hasAny(msg, ['calorie', 'calories', 'food', 'meal', 'diet', 'nutrition'])) {
      _suggestions = ['Calorie Counter', 'Workout', 'Tips'];
      return 'For calorie tracking, use the Calorie Counter.\n\nYou can search food, enter grams, choose the meal type, and save the calories to your food log.';
    }

    if (_hasAny(msg, ['workout', 'exercise', 'training', 'routine', 'build muscle', 'lose weight'])) {
      return _startWorkoutFlow(msg);
    }

    if (_hasAny(msg, ['article', 'articles', 'tips', 'advice', 'wellness', 'health tips', 'fitness tips'])) {
      _suggestions = ['Workout', 'Calories', 'Motivation'];
      return 'Here is a simple fitness tip:\n\nConsistency matters more than intensity. A short workout done regularly is better than a hard workout you cannot sustain.';
    }

    _suggestions = ['BMI', 'Calories', 'Workout', 'Motivation'];
    return 'I can help with:\n\n• BMI\n• Calories\n• Workout planning\n• Motivation\n• Wellness tips\n\nTry asking: “calculate my BMI”, “I need motivation”, or “suggest a workout”.';
  }

  static String _startWorkoutFlow(String msg) {
    _currentFlow = 'workout';

    final foundGoal = _extractGoal(msg);
    final foundLevel = _extractLevel(msg);
    final foundCondition = _extractCondition(msg);

    if (foundGoal != null) _goal = foundGoal;
    if (foundLevel != null) _level = foundLevel;
    if (foundCondition != null) _condition = foundCondition;

    return _continueWorkoutFlow('');
  }

  static String _continueWorkoutFlow(String msg) {
    if (_goal == null) {
      final foundGoal = _extractGoal(msg);

      if (foundGoal == null) {
        _suggestions = [
          'Lose weight',
          'Gain weight',
          'Gain muscles',
          'Keep fit',
          'Cancel',
        ];

        return 'Sure. Let us create a starter workout plan.\n\nFirst, what is your fitness goal?\n\n• Lose weight\n• Gain weight\n• Gain muscles\n• Keep fit';
      }

      _goal = foundGoal;
    }

    if (_level == null) {
      final foundLevel = _extractLevel(msg);

      if (foundLevel == null) {
        _suggestions = [
          'Beginner',
          'Intermediate',
          'Advanced',
          'Cancel',
        ];

        return 'Goal recorded: ${_formatGoal(_goal!)}\n\nWhat is your current fitness level?\n\n• Beginner\n• Intermediate\n• Advanced';
      }

      _level = foundLevel;
    }

    if (_condition == null) {
      final foundCondition = _extractCondition(msg);

      if (foundCondition == null) {
        _suggestions = [
          'No health condition',
          'I have a health condition',
          'Cancel',
        ];

        return 'Level recorded: ${_formatLevel(_level!)}\n\nDo you have any health condition or injury that may affect exercise?\n\n• No health condition\n• I have a health condition';
      }

      _condition = foundCondition;
    }

    return _finishWorkoutPlan();
  }

  static String _finishWorkoutPlan() {
    final goal = _goal ?? 'keep_fit';
    final level = _level ?? 'beginner';
    final hasCondition = _condition == 'health_condition';

    final exercises = _workoutNames(goal, level);
    final prescription = _setsRepsRest(level, hasCondition);

    final buffer = StringBuffer();

    buffer.writeln('Workout plan ready.');
    buffer.writeln('');
    buffer.writeln('Goal: ${_formatGoal(goal)}');
    buffer.writeln('Level: ${_formatLevel(level)}');
    buffer.writeln('Condition: ${hasCondition ? 'With health consideration' : 'No health condition'}');
    buffer.writeln('');
    buffer.writeln('Starter Workout Plan:');

    for (var i = 0; i < exercises.length; i++) {
      buffer.writeln('${i + 1}. ${exercises[i]}');
      buffer.writeln('   ${prescription['sets']} sets • ${prescription['reps']} reps • ${prescription['rest']} sec rest');
    }

    buffer.writeln('');
    buffer.writeln('Tips:');
    buffer.writeln('• Warm up for 5 minutes');
    buffer.writeln('• Focus on proper form');
    buffer.writeln('• Stop if you feel pain or dizziness');
    buffer.writeln('• Cool down after the workout');

    if (hasCondition) {
      buffer.writeln('');
      buffer.writeln('Note: Since you mentioned a health condition, keep the workout low-impact and consult a healthcare professional before doing intense exercises.');
    }

    _reset();

    return buffer.toString().trim();
  }

  static Map<String, int> _setsRepsRest(String level, bool hasCondition) {
    int sets;
    int reps;
    int rest;

    if (level == 'beginner') {
      sets = 3;
      reps = 12;
      rest = 40;
    } else if (level == 'intermediate') {
      sets = 4;
      reps = 12;
      rest = 45;
    } else {
      sets = 5;
      reps = 10;
      rest = 60;
    }

    if (hasCondition) {
      sets = sets > 2 ? sets - 1 : sets;
      reps = reps > 8 ? reps - 3 : reps;
      rest += 20;
    }

    return {
      'sets': sets,
      'reps': reps,
      'rest': rest,
    };
  }

  static List<String> _workoutNames(String goal, String level) {
    final plans = {
      'lose_weight': {
        'beginner': [
          'March in Place',
          'Step Touch',
          'Bodyweight Squat',
          'Standing Knee Raises',
          'Wall Push-Up',
        ],
        'intermediate': [
          'Jumping Jacks',
          'Mountain Climbers',
          'Squat to Reach',
          'Reverse Lunges',
          'Plank Shoulder Taps',
        ],
        'advanced': [
          'Burpees',
          'Jump Squats',
          'High Knees',
          'Push-Up to Plank',
          'Alternating Jump Lunges',
        ],
      },
      'gain_weight': {
        'beginner': [
          'Bodyweight Squat',
          'Glute Bridge',
          'Incline Push-Up',
          'Standing Calf Raise',
          'Dead Bug',
        ],
        'intermediate': [
          'Goblet Squat',
          'Dumbbell Row',
          'Dumbbell Press',
          'Romanian Deadlift',
          'Walking Lunges',
        ],
        'advanced': [
          'Barbell Squat',
          'Bench Press',
          'Deadlift',
          'Overhead Press',
          'Weighted Lunges',
        ],
      },
      'gain_muscles': {
        'beginner': [
          'Knee Push-Up',
          'Bodyweight Squat',
          'Glute Bridge',
          'Plank',
          'Superman Hold',
        ],
        'intermediate': [
          'Push-Up',
          'Dumbbell Shoulder Press',
          'Dumbbell Row',
          'Split Squat',
          'Plank Row',
        ],
        'advanced': [
          'Pull-Up',
          'Barbell Row',
          'Weighted Squat',
          'Dumbbell Bench Press',
          'Romanian Deadlift',
        ],
      },
      'keep_fit': {
        'beginner': [
          'Brisk Walking',
          'Wall Push-Up',
          'Bodyweight Squat',
          'Standing Side Leg Raise',
          'Light Stretching',
        ],
        'intermediate': [
          'Jogging in Place',
          'Push-Up',
          'Reverse Lunge',
          'Plank',
          'Bicycle Crunch',
        ],
        'advanced': [
          'Burpees',
          'Push-Up Variations',
          'Jump Lunges',
          'Plank Jack',
          'Squat Thrust',
        ],
      },
    };

    return plans[goal]?[level] ?? plans['keep_fit']!['beginner']!;
  }

  static String? _extractGoal(String text) {
    if (_hasAny(text, ['lose weight', 'weight loss', 'fat loss', 'slim', 'burn fat', 'lose'])) {
      return 'lose_weight';
    }

    if (_hasAny(text, ['gain weight', 'bulk', 'weight gain'])) {
      return 'gain_weight';
    }

    if (_hasAny(text, ['gain muscles', 'gain muscle', 'build muscle', 'build muscles', 'muscle'])) {
      return 'gain_muscles';
    }

    if (_hasAny(text, ['keep fit', 'stay fit', 'maintain', 'maintenance', 'healthy'])) {
      return 'keep_fit';
    }

    return null;
  }

  static String? _extractLevel(String text) {
    if (_hasAny(text, ['beginner', 'newbie', 'starter', 'new'])) {
      return 'beginner';
    }

    if (_hasAny(text, ['intermediate', 'medium', 'moderate'])) {
      return 'intermediate';
    }

    if (_hasAny(text, ['advanced', 'expert', 'pro', 'experienced'])) {
      return 'advanced';
    }

    return null;
  }

  static String? _extractCondition(String text) {
    if (_hasAny(text, [
      'no health condition',
      'no condition',
      'no injury',
      'none',
      'healthy',
      'no'
    ])) {
      return 'normal';
    }

    if (_hasAny(text, [
      'i have',
      'yes',
      'health condition',
      'condition',
      'injury',
      'asthma',
      'heart',
      'pain'
    ])) {
      return 'health_condition';
    }

    return null;
  }

  static String _bmiReply(String msg) {
    final heightMatch = RegExp(r'(\d+(\.\d+)?)\s*cm').firstMatch(msg);
    final weightMatch = RegExp(r'(\d+(\.\d+)?)\s*kg').firstMatch(msg);

    if (heightMatch == null || weightMatch == null) {
      return 'I can calculate BMI.\n\nSend your height and weight like this:\n170 cm and 65 kg';
    }

    final heightCm = double.tryParse(heightMatch.group(1) ?? '');
    final weightKg = double.tryParse(weightMatch.group(1) ?? '');

    if (heightCm == null || weightKg == null || heightCm <= 0 || weightKg <= 0) {
      return 'Please send valid height and weight.\n\nExample: 170 cm and 65 kg';
    }

    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);

    String status;
    if (bmi < 18.5) {
      status = 'Underweight';
    } else if (bmi < 25) {
      status = 'Normal weight';
    } else if (bmi < 30) {
      status = 'Overweight';
    } else {
      status = 'Obese';
    }

    return 'Your BMI is ${bmi.toStringAsFixed(1)}.\n\nStatus: $status\n\nUse this as a guide only. For health concerns, consult a healthcare professional.';
  }

  static String _formatGoal(String goal) {
    return goal.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  static String _formatLevel(String level) {
    if (level.isEmpty) return level;
    return level[0].toUpperCase() + level.substring(1);
  }

  static bool _hasAny(String text, List<String> words) {
    return words.any((word) => text.contains(word));
  }

  static void _reset() {
    _currentFlow = null;
    _goal = null;
    _level = null;
    _condition = null;

    _suggestions = [
      'BMI',
      'Calories',
      'Workout',
      'Motivation',
      'Articles',
      'Tips',
    ];
  }
}
