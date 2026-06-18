import 'package:flutter/material.dart';

import '../core/storage/api_session_store.dart';
import '../features/wellnesshub/wellnesshub.dart';
import 'dashboard_screen.dart';

class WellnessHubScreen extends StatefulWidget {
  static const routeName = '/wellness-hub';

  const WellnessHubScreen({super.key});

  @override
  State<WellnessHubScreen> createState() => _WellnessHubScreenState();
}

class _WellnessHubScreenState extends State<WellnessHubScreen> {
  int selectedTab = 0;

  bool isLoading = false;
  bool isSavingExercise = false;
  String? errorMessage;

  String userGoal = '';
  String? selectedDifficulty;

  List<dynamic> articles = [];
  List<dynamic> exercises = [];

  @override
  void initState() {
    super.initState();
    loadWellnessHubData();
  }

  String getStringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  int getIntValue(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.round() ?? 0;
    }
    return 0;
  }

  List<dynamic> extractList(
    Map<String, dynamic> result, {
    required List<String> preferredKeys,
  }) {
    for (final key in preferredKeys) {
      final value = result[key];

      if (value is List) return value;

      if (value is Map) {
        for (final nestedKey in preferredKeys) {
          final nestedValue = value[nestedKey];
          if (nestedValue is List) return nestedValue;
        }
      }
    }

    final data = result['data'];

    if (data is List) return data;

    if (data is Map) {
      for (final key in preferredKeys) {
        final value = data[key];
        if (value is List) return value;
      }
    }

    return [];
  }

  String normalizeGoal(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    if (normalized.contains('gain')) return 'gain_weight';
    if (normalized.contains('lose') || normalized.contains('loss')) {
      return 'lose_weight';
    }
    if (normalized.contains('maintain')) return 'maintain_weight';

    return normalized;
  }

  String displayGoal(String value) {
    final goal = normalizeGoal(value);

    if (goal == 'gain_weight') return 'Gain Weight';
    if (goal == 'lose_weight') return 'Lose Weight';
    if (goal == 'maintain_weight') return 'Maintain Weight';

    return value.isEmpty ? 'Your Goal' : value;
  }

  String exerciseGoal(dynamic exercise) {
    if (exercise is! Map) return '';

    return getStringValue(
      exercise['Goal'] ??
          exercise['goal'] ??
          exercise['FitnessGoal'] ??
          exercise['fitnessGoal'] ??
          exercise['fitness_goal'],
    );
  }

  bool matchesUserGoal(dynamic exercise) {
    final selectedGoal = normalizeGoal(userGoal);

    // If profile goal cannot be loaded, show all exercises instead of hiding everything.
    if (selectedGoal.isEmpty) return true;

    final currentExerciseGoal = normalizeGoal(exerciseGoal(exercise));

    return currentExerciseGoal == selectedGoal;
  }

  List<dynamic> get goalFilteredExercises {
    return exercises.where(matchesUserGoal).toList();
  }

  List<dynamic> exercisesByDifficulty(String difficulty) {
    return goalFilteredExercises.where((item) {
      return normalizedDifficulty(item) == difficulty;
    }).take(10).toList();
  }

  String articleTitle(dynamic article) {
    if (article is! Map) return 'Untitled Article';

    final title = getStringValue(
      article['Title'] ??
          article['title'] ??
          article['ArticleTitle'] ??
          article['articleTitle'] ??
          article['article_title'] ??
          article['ArticleName'] ??
          article['articleName'] ??
          article['article_name'],
    );

    return title.isEmpty ? 'Untitled Article' : title;
  }

  String articleContent(dynamic article) {
    if (article is! Map) return '';

    return getStringValue(
      article['Content'] ??
          article['content'] ??
          article['ArticleContent'] ??
          article['articleContent'] ??
          article['article_content'] ??
          article['Description'] ??
          article['description'] ??
          article['Body'] ??
          article['body'],
    );
  }

  String articleCategory(dynamic article) {
    if (article is! Map) return 'ARTICLE';

    final category = getStringValue(
      article['Category'] ??
          article['category'] ??
          article['ArticleCategory'] ??
          article['articleCategory'] ??
          article['article_category'] ??
          article['Type'] ??
          article['type'],
    );

    return category.isEmpty ? 'ARTICLE' : category.toUpperCase();
  }

  String articleMeta(dynamic article) {
    if (article is! Map) return '';

    final source = getStringValue(
      article['Source'] ??
          article['source'] ??
          article['Author'] ??
          article['author'],
    );

    final date = getStringValue(
      article['Created_at'] ??
          article['CreatedAt'] ??
          article['created_at'] ??
          article['createdAt'] ??
          article['Updated_at'] ??
          article['UpdatedAt'] ??
          article['updated_at'] ??
          article['updatedAt'] ??
          article['PublishedAt'] ??
          article['published_at'] ??
          article['Date'] ??
          article['date'],
    );

    if (source.isNotEmpty && date.isNotEmpty) return '$source • $date';
    if (source.isNotEmpty) return source;
    if (date.isNotEmpty) return date;

    return '';
  }

  int exerciseId(dynamic exercise) {
    if (exercise is! Map) return 0;

    return getIntValue(
      exercise['UserExerciseId'] ??
          exercise['userExerciseId'] ??
          exercise['user_exercise_id'] ??
          exercise['ExerciseId'] ??
          exercise['exerciseId'] ??
          exercise['exercise_id'] ??
          exercise['id'] ??
          exercise['Id'],
    );
  }

  String exerciseName(dynamic exercise) {
    if (exercise is! Map) return 'Unnamed Exercise';

    final name = getStringValue(
      exercise['Name'] ??
          exercise['name'] ??
          exercise['ExerciseName'] ??
          exercise['exerciseName'] ??
          exercise['exercise_name'] ??
          exercise['Title'] ??
          exercise['title'] ??
          exercise['WorkoutName'] ??
          exercise['workoutName'] ??
          exercise['workout_name'],
    );

    return name.isEmpty ? 'Unnamed Exercise' : name;
  }

  String exerciseDescription(dynamic exercise) {
    if (exercise is! Map) return '';

    final meaning = getStringValue(exercise['Meaning'] ?? exercise['meaning']);
    final benefits = getStringValue(exercise['Benefits'] ?? exercise['benefits']);
    final steps = getStringValue(
      exercise['Steps'] ??
          exercise['steps'] ??
          exercise['Instructions'] ??
          exercise['instructions'] ??
          exercise['Description'] ??
          exercise['description'] ??
          exercise['Details'] ??
          exercise['details'] ??
          exercise['Content'] ??
          exercise['content'],
    );

    if (steps.isNotEmpty) return steps;
    if (meaning.isNotEmpty && benefits.isNotEmpty) {
      return '$meaning\n\nBenefits: $benefits';
    }
    if (meaning.isNotEmpty) return meaning;
    if (benefits.isNotEmpty) return benefits;

    return '';
  }

  String rawExerciseDifficulty(dynamic exercise) {
    if (exercise is! Map) return '';

    return getStringValue(
      exercise['Difficulty'] ??
          exercise['difficulty'] ??
          exercise['Level'] ??
          exercise['level'] ??
          exercise['Category'] ??
          exercise['category'],
    );
  }

  String normalizedDifficulty(dynamic exercise) {
    final raw = rawExerciseDifficulty(exercise).toLowerCase();

    if (raw.contains('beginner')) return 'Beginner';
    if (raw.contains('intermediate')) return 'Intermediate';
    if (raw.contains('advanced')) return 'Advanced';

    return 'Other';
  }

  String exerciseProgramName(dynamic exercise) {
    if (exercise is! Map) return '';

    return getStringValue(
      exercise['ProgramName'] ??
          exercise['programName'] ??
          exercise['program_name'] ??
          exercise['Mode'] ??
          exercise['mode'],
    );
  }

  String exerciseMeta(dynamic exercise) {
    if (exercise is! Map) return '';

    final program = exerciseProgramName(exercise);
    final sets = getIntValue(exercise['Sets'] ?? exercise['sets']);
    final reps = getStringValue(exercise['Reps'] ?? exercise['reps']);
    final rest = getIntValue(
      exercise['RestSeconds'] ??
          exercise['restSeconds'] ??
          exercise['rest_seconds'],
    );
    final difficulty = normalizedDifficulty(exercise);

    final parts = <String>[];

    if (program.isNotEmpty && program.toLowerCase() != 'null') {
      parts.add(program);
    }

    if (sets > 0) {
      parts.add('$sets sets');
    }

    if (reps.isNotEmpty && reps.toLowerCase() != 'null') {
      parts.add('$reps reps');
    }

    if (rest > 0) {
      parts.add('${rest}s rest');
    }

    if (parts.isEmpty) return difficulty;

    return '$difficulty • ${parts.join(' • ')}';
  }

  Future<void> loadWellnessHubData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final articleResult = await WellnessHubApi.getArticles();

      String loadedGoal = '';
      final userId = await ApiSessionStore.getUserId();

      if (userId != null && userId > 0) {
        final profileResult = await WellnessHubApi.getProfile(userId: userId);

        loadedGoal = getStringValue(
          profileResult['Goal'] ??
              profileResult['goal'] ??
              profileResult['data']?['Goal'] ??
              profileResult['data']?['goal'],
        );
      }

      // This uses /exercise/user/0 because your shared exercise library uses UserId = 0.
      final exerciseResult = await WellnessHubApi.getPublicExercises();

      if (!mounted) return;

      setState(() {
        userGoal = loadedGoal;

        articles = extractList(
          articleResult,
          preferredKeys: const [
            'articles',
            'article',
            'data',
            'items',
            'results',
          ],
        );

        exercises = extractList(
          exerciseResult,
          preferredKeys: const [
            'exercises',
            'exercise',
            'user_exercises',
            'userExercises',
            'workouts',
            'data',
            'items',
            'results',
          ],
        );

        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load wellness data: $error';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> saveExerciseToActivity(dynamic exercise) async {
    final id = exerciseId(exercise);

    if (id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exercise ID is missing. Cannot save workout.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSavingExercise = true;
    });

    try {
      final userId = await ApiSessionStore.getUserId();

      if (userId == null || userId <= 0) {
        if (!mounted) return;

        setState(() {
          isSavingExercise = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final result = await WellnessHubApi.saveExercise(
        userId: userId,
        exerciseId: id,
      );

      if (!mounted) return;

      setState(() {
        isSavingExercise = false;
      });

      if (result['success'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              WellnessHubApi.asString(result['message']).isEmpty
                  ? 'Failed to save exercise.'
                  : WellnessHubApi.asString(result['message']),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${exerciseName(exercise)} saved to Activity Log.'),
          backgroundColor: const Color(0xFF168A2A),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isSavingExercise = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving exercise: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
              child: RefreshIndicator(
                onRefresh: loadWellnessHubData,
                child: selectedTab == 0
                    ? buildArticlesTab()
                    : buildExercisesTab(),
              ),
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
              if (selectedTab == 1 && selectedDifficulty != null) {
                setState(() {
                  selectedDifficulty = null;
                });
                return;
              }

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wellness for you',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Exercises are filtered for ${displayGoal(userGoal)}.',
                  style: const TextStyle(
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
                    selectedDifficulty = null;
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
    if (isLoading) return buildLoadingList();

    if (errorMessage != null && articles.isEmpty) {
      return buildMessageList(errorMessage!);
    }

    if (articles.isEmpty) {
      return buildMessageList('No articles found in the database.');
    }

    final featuredArticle = articles.first;
    final remainingArticles = articles.length > 1 ? articles.skip(1).toList() : [];

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
        buildFeaturedArticleCard(featuredArticle),
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
        if (remainingArticles.isEmpty)
          buildSmallMessageCard('No more articles available.')
        else
          ...remainingArticles.map(buildArticleListCard),
      ],
    );
  }

  Widget buildExercisesTab() {
    if (isLoading) return buildLoadingList();

    if (errorMessage != null && exercises.isEmpty) {
      return buildMessageList(errorMessage!);
    }

    if (goalFilteredExercises.isEmpty) {
      return buildMessageList(
        'No exercises found for ${displayGoal(userGoal)}.\n\nCheck the Goal column in user_exercises.',
      );
    }

    if (selectedDifficulty == null) {
      return buildDifficultySelection();
    }

    return buildDifficultyExerciseList(selectedDifficulty!);
  }

  Widget buildDifficultySelection() {
    final beginnerExercises = exercisesByDifficulty('Beginner');
    final intermediateExercises = exercisesByDifficulty('Intermediate');
    final advancedExercises = exercisesByDifficulty('Advanced');

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
      children: [
        Text(
          '${displayGoal(userGoal)} Program',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Choose your difficulty level. Each level shows up to 10 exercises.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        buildDifficultyCard(
          difficulty: 'Beginner',
          subtitle: 'Start simple and build consistency.',
          count: beginnerExercises.length,
          icon: Icons.directions_run_rounded,
        ),
        buildDifficultyCard(
          difficulty: 'Intermediate',
          subtitle: 'Train with more control and intensity.',
          count: intermediateExercises.length,
          icon: Icons.fitness_center_rounded,
        ),
        buildDifficultyCard(
          difficulty: 'Advanced',
          subtitle: 'Challenge your endurance and discipline.',
          count: advancedExercises.length,
          icon: Icons.local_fire_department_rounded,
        ),
      ],
    );
  }

  Widget buildDifficultyCard({
    required String difficulty,
    required String subtitle,
    required int count,
    required IconData icon,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: count == 0
          ? null
          : () {
              setState(() {
                selectedDifficulty = difficulty;
              });
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: count == 0 ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(26),
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
              height: 58,
              width: 58,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF7EA),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF168A2A),
                size: 29,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    difficulty,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '$count / 10 exercises',
                    style: const TextStyle(
                      color: Color(0xFF168A2A),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF168A2A),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDifficultyExerciseList(String difficulty) {
    final items = exercisesByDifficulty(difficulty);

    if (items.isEmpty) {
      return buildMessageList('No $difficulty exercises available.');
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  selectedDifficulty = null;
                });
              },
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF168A2A),
              ),
            ),
            Expanded(
              child: Text(
                '$difficulty Exercises',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            buildMiniLabel('${items.length}/10'),
          ],
        ),
        const SizedBox(height: 8),
        ...items.asMap().entries.map((entry) {
          return buildExerciseCard(
            index: entry.key,
            exercise: entry.value,
          );
        }),
      ],
    );
  }

  Widget buildLoadingList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 40, 18, 22),
      children: const [
        Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }

  Widget buildMessageList(String message) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
      children: [
        buildSmallMessageCard(message),
      ],
    );
  }

  Widget buildSmallMessageCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget buildFeaturedArticleCard(dynamic article) {
    final category = articleCategory(article);
    final title = articleTitle(article);
    final meta = articleMeta(article);
    final content = articleContent(article);

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () {
        showArticleDetails(article);
      },
      child: Container(
        decoration: cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 220),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildFeaturedTag(category),
                    const SizedBox(height: 52),
                    Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        height: 1.07,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (content.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        meta,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFeaturedTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget buildArticleListCard(dynamic article) {
    final category = articleCategory(article);
    final title = articleTitle(article);
    final meta = articleMeta(article);
    final content = articleContent(article);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        showArticleDetails(article);
      },
      child: Container(
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
                  if (content.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (meta.isNotEmpty) ...[
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
      ),
    );
  }

  Widget buildExerciseCard({
    required int index,
    required dynamic exercise,
  }) {
    final name = exerciseName(exercise);
    final description = exerciseDescription(exercise);
    final level = normalizedDifficulty(exercise);
    final meta = exerciseMeta(exercise);

    final icon = level == 'Beginner'
        ? Icons.directions_run_rounded
        : level == 'Intermediate'
            ? Icons.fitness_center_rounded
            : Icons.local_fire_department_rounded;

    final List<Color> topColors = level == 'Beginner'
        ? [const Color(0xFF2F9E44), const Color(0xFF74C882)]
        : level == 'Intermediate'
            ? [const Color(0xFF2D6A4F), const Color(0xFF74A98B)]
            : [const Color(0xFF0B6E1F), const Color(0xFF35B653)];

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () {
        showExerciseDetails(exercise);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 128,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        level,
                        style: const TextStyle(
                          color: Colors.white,
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
                    name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      height: 1.17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    meta,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isSavingExercise
                          ? null
                          : () {
                              saveExerciseToActivity(exercise);
                            },
                      icon: const Icon(Icons.bookmark_add_rounded),
                      label: Text(
                        isSavingExercise ? 'Saving...' : 'Save to Activity',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF168A2A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
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

  void showArticleDetails(dynamic article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return buildDetailsSheet(
          title: articleTitle(article),
          subtitle: articleMeta(article).isEmpty
              ? articleCategory(article)
              : '${articleCategory(article)} • ${articleMeta(article)}',
          body: articleContent(article).isEmpty
              ? 'No article content available.'
              : articleContent(article),
          icon: Icons.article_rounded,
          actionText: null,
          onAction: null,
        );
      },
    );
  }

  void showExerciseDetails(dynamic exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return buildDetailsSheet(
          title: exerciseName(exercise),
          subtitle: exerciseMeta(exercise),
          body: exerciseDescription(exercise).isEmpty
              ? 'No exercise details available.'
              : exerciseDescription(exercise),
          icon: Icons.fitness_center_rounded,
          actionText: 'Save to Activity',
          onAction: () {
            Navigator.pop(context);
            saveExerciseToActivity(exercise);
          },
        );
      },
    );
  }

  Widget buildDetailsSheet({
    required String title,
    required String subtitle,
    required String body,
    required IconData icon,
    required String? actionText,
    required VoidCallback? onAction,
  }) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
          decoration: const BoxDecoration(
            color: Color(0xFFFAFBF8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                height: 54,
                width: 54,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF7EA),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF168A2A),
                  size: 29,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF168A2A),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                body,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (actionText != null && onAction != null) ...[
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.bookmark_add_rounded),
                  label: Text(
                    actionText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF168A2A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
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
