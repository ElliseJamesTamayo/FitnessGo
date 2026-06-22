class WellnessExercise {
  final int id;
  final int exerciseId;
  final int userExerciseId;
  final String name;
  final String title;
  final String description;
  final String meaning;
  final String benefits;
  final String steps;
  final String category;
  final String difficulty;
  final String level;
  final String programName;
  final String duration;
  final String time;
  final String reps;
  final int sets;
  final int restSeconds;
  final String imageUrl;
  final String image;
  final String goal;

  const WellnessExercise({
    required this.id,
    required this.exerciseId,
    required this.userExerciseId,
    required this.name,
    required this.title,
    required this.description,
    required this.meaning,
    required this.benefits,
    required this.steps,
    required this.category,
    required this.difficulty,
    required this.level,
    required this.programName,
    required this.duration,
    required this.time,
    required this.reps,
    required this.sets,
    required this.restSeconds,
    required this.imageUrl,
    required this.image,
    required this.goal,
  });

  factory WellnessExercise.fromJson(Map<String, dynamic> json) {
    final parsedUserExerciseId = _asInt(
      json['UserExerciseId'] ??
          json['userExerciseId'] ??
          json['user_exercise_id'],
    );

    final parsedExerciseId = _asInt(
      json['ExerciseId'] ??
          json['exerciseId'] ??
          json['exercise_id'] ??
          json['id'] ??
          json['Id'] ??
          parsedUserExerciseId,
    );

    final parsedId = parsedUserExerciseId > 0
        ? parsedUserExerciseId
        : parsedExerciseId;

    final parsedName = _asString(
      json['Name'] ??
          json['name'] ??
          json['ExerciseName'] ??
          json['exerciseName'] ??
          json['exercise_name'] ??
          json['Title'] ??
          json['title'] ??
          json['WorkoutName'] ??
          json['workoutName'] ??
          json['workout_name'],
    );

    final parsedSteps = _asString(
      json['Steps'] ??
          json['steps'] ??
          json['Instructions'] ??
          json['instructions'] ??
          json['Description'] ??
          json['description'] ??
          json['Details'] ??
          json['details'] ??
          json['Content'] ??
          json['content'],
    );

    final parsedDifficulty = _asString(
      json['Difficulty'] ??
          json['difficulty'] ??
          json['Level'] ??
          json['level'] ??
          json['Category'] ??
          json['category'],
    );

    final parsedImage = _asString(
      json['ImageUrl'] ??
          json['imageUrl'] ??
          json['image_url'] ??
          json['Image'] ??
          json['image'] ??
          json['Photo'] ??
          json['photo'] ??
          json['Thumbnail'] ??
          json['thumbnail'],
    );

    return WellnessExercise(
      id: parsedId,
      exerciseId: parsedExerciseId,
      userExerciseId: parsedUserExerciseId,
      name: parsedName,
      title: parsedName,
      description: parsedSteps,
      meaning: _asString(json['Meaning'] ?? json['meaning']),
      benefits: _asString(json['Benefits'] ?? json['benefits']),
      steps: parsedSteps,
      category: _asString(json['Category'] ?? json['category']),
      difficulty: parsedDifficulty,
      level: parsedDifficulty,
      programName: _asString(
        json['ProgramName'] ??
            json['programName'] ??
            json['program_name'] ??
            json['Mode'] ??
            json['mode'],
      ),
      duration: _asString(
        json['Duration'] ?? json['duration'] ?? json['Time'] ?? json['time'],
      ),
      time: _asString(
        json['Time'] ?? json['time'] ?? json['Duration'] ?? json['duration'],
      ),
      reps: _asString(json['Reps'] ?? json['reps']),
      sets: _asInt(json['Sets'] ?? json['sets']),
      restSeconds: _asInt(
        json['RestSeconds'] ?? json['restSeconds'] ?? json['rest_seconds'],
      ),
      imageUrl: parsedImage,
      image: parsedImage,
      goal: _asString(json['Goal'] ?? json['goal']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ExerciseId': exerciseId,
      'UserExerciseId': userExerciseId,
      'Name': name,
      'Title': title,
      'Description': description,
      'Meaning': meaning,
      'Benefits': benefits,
      'Steps': steps,
      'Category': category,
      'Difficulty': difficulty,
      'Level': level,
      'ProgramName': programName,
      'Duration': duration,
      'Time': time,
      'Reps': reps,
      'Sets': sets,
      'RestSeconds': restSeconds,
      'ImageUrl': imageUrl,
      'Image': image,
      'Goal': goal,
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.round() ?? 0;
    }
    return 0;
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}
