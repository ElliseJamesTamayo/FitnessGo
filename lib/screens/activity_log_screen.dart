import 'package:flutter/material.dart';

import '../core/storage/api_session_store.dart';
import '../features/wellness/data/wellness_api.dart';
import 'dashboard_screen.dart';

class ActivityLogScreen extends StatefulWidget {
  static const routeName = '/activity-log';

  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  int selectedTab = 0;
  bool isLoadingWellnessLogs = true;
  String wellnessLogsError = '';

  List<Map<String, dynamic>> workoutLogs = [];
  List<Map<String, dynamic>> articleLogs = [];

  @override
  void initState() {
    super.initState();
    loadSavedWellnessLogs();
  }

  Future<void> loadSavedWellnessLogs() async {
    if (!mounted) return;

    setState(() {
      isLoadingWellnessLogs = true;
      wellnessLogsError = '';
    });

    try {
      final userId = await ApiSessionStore.getUserId();

      if (userId <= 0) {
        if (!mounted) return;

        setState(() {
          isLoadingWellnessLogs = false;
          workoutLogs = [];
          articleLogs = [];
          wellnessLogsError = 'No valid logged-in user ID was found.';
        });

        return;
      }

      final savedExercises = await WellnessApi.getSavedExercises(
        userId: userId,
      );
      final savedArticles = await WellnessApi.getSavedArticles(userId: userId);

      if (!mounted) return;

      setState(() {
        workoutLogs = savedExercises;
        articleLogs = savedArticles;
        isLoadingWellnessLogs = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoadingWellnessLogs = false;
        workoutLogs = [];
        articleLogs = [];
        wellnessLogsError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> deleteSavedExercise(int index) async {
    if (index < 0 || index >= workoutLogs.length) return;

    final item = workoutLogs[index];
    final savedId = readInt(item, [
      'SavedExerciseByUserId',
      'savedExerciseByUserId',
      'saved_exercise_by_user_id',
      'SavedExerciseId',
      'savedExerciseId',
      'saved_exercise_id',
      'id',
    ]);

    if (savedId <= 0) {
      setState(() {
        workoutLogs.removeAt(index);
      });
      showMessage('Exercise removed from Activity Log.');
      return;
    }

    try {
      await WellnessApi.deleteSavedExercise(savedExerciseId: savedId);

      if (!mounted) return;

      setState(() {
        workoutLogs.removeAt(index);
      });

      showMessage('Saved exercise deleted.');
    } catch (error) {
      if (!mounted) return;

      showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  Future<void> deleteSavedArticle(int index) async {
    if (index < 0 || index >= articleLogs.length) return;

    final item = articleLogs[index];
    final savedId = readInt(item, [
      'SavedId',
      'savedId',
      'saved_id',
      'SavedArticleId',
      'savedArticleId',
      'saved_article_id',
      'SavedArticleByUserId',
      'savedArticleByUserId',
      'saved_article_by_user_id',
      'SavedArticleByUserID',
      'id',
    ]);

    if (savedId <= 0) {
      setState(() {
        articleLogs.removeAt(index);
      });
      showMessage('Article removed from Activity Log.');
      return;
    }

    try {
      await WellnessApi.deleteSavedArticle(savedArticleId: savedId);

      if (!mounted) return;

      setState(() {
        articleLogs.removeAt(index);
      });

      showMessage('Saved article deleted.');
    } catch (error) {
      if (!mounted) return;

      showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  void showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? Colors.red.shade700
              : const Color(0xFF168A2A),
        ),
      );
  }

  static int readInt(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];

      if (value is int) return value;
      if (value is double) return value.round();
      if (value is String) {
        final parsed = int.tryParse(value) ?? double.tryParse(value)?.round();

        if (parsed != null) return parsed;
      }
    }

    return 0;
  }

  static String readString(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return '';
  }

  String savedExerciseTitle(Map<String, dynamic> item) {
    final value = readString(item, [
      'name',
      'Name',
      'ExerciseName',
      'exerciseName',
      'exercise_name',
      'title',
      'Title',
    ]);

    return value.isEmpty ? 'Saved Exercise' : value;
  }

  String savedExerciseSubtitle(Map<String, dynamic> item) {
    final difficulty = readString(item, [
      'difficulty',
      'Difficulty',
      'level',
      'Level',
    ]);

    final program = readString(item, [
      'program_name',
      'programName',
      'ProgramName',
      'program',
    ]);

    final sets = readString(item, ['sets', 'Sets']);
    final reps = readString(item, ['reps', 'Reps']);
    final rest = readString(item, [
      'rest_seconds',
      'restSeconds',
      'RestSeconds',
    ]);

    final parts = <String>[];

    if (difficulty.isNotEmpty) {
      parts.add(difficulty);
    }

    if (program.isNotEmpty) {
      parts.add(program);
    }

    final exerciseParts = <String>[];

    if (sets.isNotEmpty) {
      exerciseParts.add('$sets sets');
    }

    if (reps.isNotEmpty) {
      exerciseParts.add('$reps reps');
    }

    if (rest.isNotEmpty) {
      exerciseParts.add('${rest}s rest');
    }

    if (exerciseParts.isNotEmpty) {
      parts.add(exerciseParts.join(' • '));
    }

    return parts.isEmpty ? 'Saved workout' : parts.join(' • ');
  }

  String savedArticleTitle(Map<String, dynamic> item) {
    final value = readString(item, [
      'title',
      'Title',
      'ArticleTitle',
      'articleTitle',
      'article_title',
      'ArticleName',
      'articleName',
      'article_name',
    ]);

    return value.isEmpty ? 'Saved Article' : value;
  }

  String savedArticleSubtitle(Map<String, dynamic> item) {
    final source = readString(item, ['source', 'Source', 'author', 'Author']);
    final category = readString(item, ['category', 'Category']);
    final date = readString(item, [
      'date',
      'Date',
      'created_at',
      'Created_at',
      'CreatedAt',
    ]);

    final parts = <String>[];

    if (source.isNotEmpty) {
      parts.add(source);
    }

    if (category.isNotEmpty) {
      parts.add(category);
    }

    if (date.isNotEmpty) {
      parts.add(date);
    }

    return parts.isEmpty ? 'Saved wellness article' : parts.join(' • ');
  }


  void openSavedExerciseDetails(Map<String, dynamic> savedItem) {
    final userExerciseId = readInt(
      savedItem,
      [
        'UserExerciseId',
        'userExerciseId',
        'user_exercise_id',
        'ExerciseId',
        'exerciseId',
        'exercise_id',
      ],
    );

    final Future<Map<String, dynamic>> detailsFuture = userExerciseId > 0
        ? WellnessApi.getExerciseDetails(userExerciseId: userExerciseId)
        : Future<Map<String, dynamic>>.value(savedItem);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFAFBF8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.94,
          child: SafeArea(
            child: FutureBuilder<Map<String, dynamic>>(
              future: detailsFuture,
              builder: (context, snapshot) {
                final detail = snapshot.hasData ? snapshot.data! : savedItem;

                return Column(
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 16, 8),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Back',
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFF168A2A),
                              size: 29,
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Exercise Details',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    Expanded(
                      child: snapshot.connectionState != ConnectionState.done
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF168A2A),
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                4,
                                18,
                                28,
                              ),
                              child: buildSavedExerciseDetailContent(
                                detail: detail,
                                fallback: savedItem,
                                couldNotRefresh: snapshot.hasError,
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildSavedExerciseDetailContent({
    required Map<String, dynamic> detail,
    required Map<String, dynamic> fallback,
    required bool couldNotRefresh,
  }) {
    String value(
      List<String> keys, {
      String fallbackValue = '',
    }) {
      final fetched = readString(detail, keys);

      if (fetched.isNotEmpty) {
        return fetched;
      }

      final saved = readString(fallback, keys);
      return saved.isEmpty ? fallbackValue : saved;
    }

    final category = value(
      ['Category', 'category'],
      fallbackValue: 'EXERCISE',
    );
    final title = value(
      [
        'Name',
        'name',
        'ExerciseName',
        'exerciseName',
        'title',
        'Title',
      ],
      fallbackValue: savedExerciseTitle(fallback),
    );
    final difficulty = value(
      ['Difficulty', 'difficulty', 'Level', 'level'],
    );
    final programName = value(
      ['ProgramName', 'programName', 'program_name', 'program'],
    );
    final sets = value(['Sets', 'sets'], fallbackValue: '0');
    final reps = value(['Reps', 'reps'], fallbackValue: '12');
    final rest = value(
      ['RestSeconds', 'restSeconds', 'rest_seconds'],
      fallbackValue: '0',
    );
    final meaning = value(['Meaning', 'meaning']);
    final steps = value(['Steps', 'steps']);
    final benefits = value(['Benefits', 'benefits']);

    final subtitleParts = <String>[];

    if (difficulty.isNotEmpty) {
      subtitleParts.add(difficulty);
    }

    if (programName.isNotEmpty) {
      subtitleParts.add(programName);
    }

    final subtitle = subtitleParts.isEmpty
        ? savedExerciseSubtitle(fallback)
        : subtitleParts.join(' • ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSavedExerciseDetailsHero(),
        const SizedBox(height: 18),
        buildSavedExerciseMiniLabel(category),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 29,
            height: 1.08,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle.isEmpty ? 'Exercise program' : subtitle,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
            height: 1.35,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (couldNotRefresh) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF0D99E)),
            ),
            child: const Text(
              'Showing saved exercise information. Full details could not be refreshed right now.',
              style: TextStyle(
                color: Color(0xFF7A5A00),
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: buildSavedExerciseInfoChip(
                icon: Icons.repeat_rounded,
                label: 'Sets',
                value: sets,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildSavedExerciseInfoChip(
                icon: Icons.fitness_center_rounded,
                label: 'Reps',
                value: reps,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildSavedExerciseInfoChip(
                icon: Icons.timer_rounded,
                label: 'Rest',
                value: '${rest}s',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (meaning.isNotEmpty)
          buildSavedExerciseDetailSection(
            icon: Icons.lightbulb_rounded,
            title: 'Meaning',
            content: meaning,
          ),
        if (steps.isNotEmpty)
          buildSavedExerciseDetailSection(
            icon: Icons.checklist_rounded,
            title: 'Steps',
            content: steps,
          ),
        if (benefits.isNotEmpty)
          buildSavedExerciseDetailSection(
            icon: Icons.health_and_safety_rounded,
            title: 'Benefits',
            content: benefits,
          ),
        if (meaning.isEmpty && steps.isEmpty && benefits.isEmpty)
          buildSavedExerciseDetailSection(
            icon: Icons.info_outline_rounded,
            title: 'Details',
            content:
                'No full exercise details are available for this saved item yet.',
          ),
      ],
    );
  }

  Widget buildSavedExerciseDetailsHero() {
    return Container(
      height: 175,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F7C23),
            Color(0xFF1E9F36),
            Color(0xFF77D889),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF168A2A).withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            bottom: -35,
            child: Icon(
              Icons.fitness_center_rounded,
              size: 150,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          Center(
            child: Container(
              height: 92,
              width: 92,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_run_rounded,
                color: Colors.white,
                size: 54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSavedExerciseMiniLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF168A2A),
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget buildSavedExerciseInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4EBE1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF168A2A), size: 22),
          const SizedBox(height: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSavedExerciseDetailSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4EBE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF7EA),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF168A2A), size: 19),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14.5,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void openSavedArticleDetails(Map<String, dynamic> item) {
    final title = savedArticleTitle(item);
    final subtitle = savedArticleSubtitle(item);
    final body = readString(
      item,
      ['body', 'Body', 'content', 'Content', 'description', 'Description'],
    );

    showSavedLogDetails(
      icon: Icons.article_rounded,
      sectionTitle: 'Saved Article',
      title: title,
      subtitle: subtitle,
      content: body.isEmpty
          ? 'No full article content is available for this saved item.'
          : body,
    );
  }

  void showSavedLogDetails({
    required IconData icon,
    required String sectionTitle,
    required String title,
    required String subtitle,
    required String content,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFAFBF8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.76,
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 16, 10),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF168A2A),
                          size: 29,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          sectionTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF0F7C23),
                                Color(0xFF1E9F36),
                                Color(0xFF72D985),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Container(
                              height: 82,
                              width: 82,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icon,
                                color: Colors.white,
                                size: 44,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 26,
                            height: 1.12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFE4EBE1),
                            ),
                          ),
                          child: Text(
                            content,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              height: 1.55,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
                  : buildArticlesTab(),
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
            label: 'Exercises',
            value: '${workoutLogs.length}',
          ),
          buildDivider(),
          buildOverviewItem(
            icon: Icons.article_rounded,
            label: 'Articles',
            value: '${articleLogs.length}',
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
          Icon(icon, color: Colors.white, size: 22),
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
      ['Exercises', Icons.fitness_center_rounded],
      ['Articles', Icons.article_rounded],
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
    if (isLoadingWellnessLogs && workoutLogs.isEmpty) {
      return buildLoadingState('Loading saved exercises...');
    }

    if (wellnessLogsError.isNotEmpty && workoutLogs.isEmpty) {
      return buildErrorState(
        icon: Icons.fitness_center_rounded,
        title: 'Unable to load saved exercises',
        subtitle: wellnessLogsError,
      );
    }

    if (workoutLogs.isEmpty) {
      return buildEmptyState(
        icon: Icons.fitness_center_rounded,
        title: 'No saved exercises',
        subtitle: 'Saved exercises from Wellness Hub will appear here.',
      );
    }

    return Column(
      children: [
        buildSectionLabel('Saved Exercises'),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
            itemCount: workoutLogs.length,
            itemBuilder: (context, index) {
              final item = workoutLogs[index];

              return buildModernLogCard(
                icon: workoutIcon(index),
                title: savedExerciseTitle(item),
                subtitle: savedExerciseSubtitle(item),
                onTap: () {
                  openSavedExerciseDetails(item);
                },
                onDelete: () {
                  deleteSavedExercise(index);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildArticlesTab() {
    if (isLoadingWellnessLogs && articleLogs.isEmpty) {
      return buildLoadingState('Loading saved articles...');
    }

    if (wellnessLogsError.isNotEmpty && articleLogs.isEmpty) {
      return buildErrorState(
        icon: Icons.article_rounded,
        title: 'Unable to load saved articles',
        subtitle: wellnessLogsError,
      );
    }

    if (articleLogs.isEmpty) {
      return buildEmptyState(
        icon: Icons.article_rounded,
        title: 'No saved articles',
        subtitle: 'Saved articles from Wellness Hub will appear here.',
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
                title: savedArticleTitle(item),
                subtitle: savedArticleSubtitle(item),
                onTap: () {
                  openSavedArticleDetails(item);
                },
                onDelete: () {
                  deleteSavedArticle(index);
                },
              );
            },
          ),
        ),
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

  Widget buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFF168A2A)),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrorState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 60, 22, 22),
      children: [
        Icon(icon, color: Colors.red, size: 52),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, height: 1.4),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: loadSavedWellnessLogs,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF168A2A),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildModernLogCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onDelete,
    VoidCallback? onTap,
  }) {
    final card = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4EBE1)),
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
            child: Icon(icon, color: const Color(0xFF168A2A), size: 28),
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
                if (onTap != null) ...[
                  const SizedBox(height: 5),
                  const Text(
                    'Tap to view details',
                    style: TextStyle(
                      color: Color(0xFF168A2A),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF168A2A),
              size: 23,
            ),
          const SizedBox(width: 5),
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

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: card,
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
            child: Icon(icon, color: const Color(0xFF168A2A), size: 37),
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

}

