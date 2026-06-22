import 'package:flutter/material.dart';

import '../core/storage/api_session_store.dart';
import '../features/wellness/data/wellness_api.dart';
import '../features/wellness/models/wellness_article.dart';
import '../features/wellness/models/wellness_exercise.dart';

class WellnessHubScreen extends StatefulWidget {
  static const routeName = '/wellness-hub';

  const WellnessHubScreen({super.key});

  @override
  State<WellnessHubScreen> createState() => _WellnessHubScreenState();
}

class _WellnessHubScreenState extends State<WellnessHubScreen> {
  int selectedTab = 0;
  int currentUserId = 0;

  bool isLoadingArticles = true;
  String articlesError = '';
  List<WellnessArticle> allArticles = [];

  bool isLoadingExercises = true;
  String exercisesError = '';
  List<WellnessExercise> allExercises = [];

  bool isSavingArticle = false;
  int? savingArticleId;

  bool isSavingExercise = false;
  int? savingExerciseId;

  // Maps each content ID to its saved-record ID in the backend.
  // The saved-record ID is required when the user taps Saved to remove it.
  final Map<int, int> savedArticleRecordIds = <int, int>{};
  final Map<int, int> savedExerciseRecordIds = <int, int>{};

  @override
  void initState() {
    super.initState();
    initializeWellnessHub();
  }

  Future<void> initializeWellnessHub() async {
    final userId = await ApiSessionStore.getUserId();

    if (!mounted) return;

    setState(() {
      currentUserId = userId;
    });

    await Future.wait([loadArticles(), loadExercises(), loadSavedWellnessState()]);
  }

  Future<void> loadArticles() async {
    if (mounted) {
      setState(() {
        isLoadingArticles = true;
        articlesError = '';
      });
    }

    try {
      final articles = await WellnessApi.getArticles();

      if (!mounted) return;

      setState(() {
        allArticles = articles;
        isLoadingArticles = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoadingArticles = false;
        articlesError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> loadExercises() async {
    if (currentUserId <= 0) {
      if (!mounted) return;

      setState(() {
        isLoadingExercises = false;
        allExercises = [];
        exercisesError = 'No valid logged-in user ID was found.';
      });
      return;
    }

    if (mounted) {
      setState(() {
        isLoadingExercises = true;
        exercisesError = '';
      });
    }

    try {
      final exercises = await WellnessApi.getExercises(userId: currentUserId);

      if (!mounted) return;

      setState(() {
        allExercises = exercises;
        isLoadingExercises = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoadingExercises = false;
        exercisesError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }


  int articleKey(WellnessArticle article) {
    if (article.articleId > 0) return article.articleId;
    return article.id;
  }

  int exerciseKey(WellnessExercise exercise) {
    if (exercise.userExerciseId > 0) return exercise.userExerciseId;
    if (exercise.exerciseId > 0) return exercise.exerciseId;
    return exercise.id;
  }

  bool isArticleSaved(WellnessArticle article) {
    final id = articleKey(article);
    return id > 0 && savedArticleRecordIds.containsKey(id);
  }

  bool isExerciseSaved(WellnessExercise exercise) {
    final id = exerciseKey(exercise);
    return id > 0 && savedExerciseRecordIds.containsKey(id);
  }

  int readSavedId(Map<String, dynamic> item, List<String> keys) {
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

  int articleSavedRecordId(WellnessArticle article) {
    return savedArticleRecordIds[articleKey(article)] ?? 0;
  }

  int exerciseSavedRecordId(WellnessExercise exercise) {
    return savedExerciseRecordIds[exerciseKey(exercise)] ?? 0;
  }

  Future<void> loadSavedWellnessState() async {
    if (currentUserId <= 0) return;

    try {
      final savedArticlesFuture = WellnessApi.getSavedArticles(
        userId: currentUserId,
      );
      final savedExercisesFuture = WellnessApi.getSavedExercises(
        userId: currentUserId,
      );

      final savedArticles = await savedArticlesFuture;
      final savedExercises = await savedExercisesFuture;

      final articleRecords = <int, int>{};
      final exerciseRecords = <int, int>{};

      for (final item in savedArticles) {
        final articleId = readSavedId(
          item,
          [
            'ArticleId',
            'articleId',
            'article_id',
          ],
        );

        final savedId = readSavedId(
          item,
          [
            'SavedId',
            'savedId',
            'saved_id',
            'SavedArticleId',
            'savedArticleId',
            'saved_article_id',
            'SavedArticleByUserId',
            'savedArticleByUserId',
            'saved_article_by_user_id',
            'id',
          ],
        );

        if (articleId > 0 && savedId > 0) {
          articleRecords[articleId] = savedId;
        }
      }

      for (final item in savedExercises) {
        final exerciseId = readSavedId(
          item,
          [
            'UserExerciseId',
            'userExerciseId',
            'user_exercise_id',
            'ExerciseId',
            'exerciseId',
            'exercise_id',
          ],
        );

        final savedId = readSavedId(
          item,
          [
            'SavedExerciseByUserId',
            'savedExerciseByUserId',
            'saved_exercise_by_user_id',
            'SavedExerciseId',
            'savedExerciseId',
            'saved_exercise_id',
            'SavedId',
            'savedId',
            'saved_id',
            'id',
          ],
        );

        if (exerciseId > 0 && savedId > 0) {
          exerciseRecords[exerciseId] = savedId;
        }
      }

      if (!mounted) return;

      setState(() {
        savedArticleRecordIds
          ..clear()
          ..addAll(articleRecords);

        savedExerciseRecordIds
          ..clear()
          ..addAll(exerciseRecords);
      });
    } catch (_) {
      // The Wellness Hub remains usable even if saved status is delayed.
    }
  }

  Future<void> toggleArticleSave(WellnessArticle article) async {
    if (isArticleSaved(article)) {
      await removeSavedArticle(article);
    } else {
      await saveArticle(article);
    }
  }

  Future<void> toggleExerciseSave(WellnessExercise exercise) async {
    if (isExerciseSaved(exercise)) {
      await removeSavedExercise(exercise);
    } else {
      await saveExercise(exercise);
    }
  }

  Future<void> saveArticle(WellnessArticle article) async {
    if (currentUserId <= 0) {
      showMessage(
        'No valid logged-in user ID was found. Please log in again.',
        isError: true,
      );
      return;
    }

    final articleId = articleKey(article);

    if (articleId <= 0) {
      showMessage('This article has no valid article ID.', isError: true);
      return;
    }

    if (isSavingArticle) return;

    setState(() {
      isSavingArticle = true;
      savingArticleId = articleId;
    });

    try {
      final result = await WellnessApi.saveArticle(
        userId: currentUserId,
        article: article,
      );

      if (!mounted) return;

      // Reload to retrieve the real SavedId needed for a future unsave.
      await loadSavedWellnessState();

      // Keep the button visibly saved even if the backend does not include
      // the SavedId immediately in the returned list.
      if (!mounted) return;
      if (!savedArticleRecordIds.containsKey(articleId)) {
        setState(() {
          savedArticleRecordIds[articleId] = 0;
        });
      }

      showMessage(
        result['message']?.toString() ?? 'Article saved to Activity Log.',
      );
    } catch (error) {
      if (!mounted) return;

      showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSavingArticle = false;
          savingArticleId = null;
        });
      }
    }
  }

  Future<void> saveExercise(WellnessExercise exercise) async {
    if (currentUserId <= 0) {
      showMessage(
        'No valid logged-in user ID was found. Please log in again.',
        isError: true,
      );
      return;
    }

    final exerciseId = exerciseKey(exercise);

    if (exerciseId <= 0) {
      showMessage('This exercise has no valid exercise ID.', isError: true);
      return;
    }

    if (isSavingExercise) return;

    setState(() {
      isSavingExercise = true;
      savingExerciseId = exerciseId;
    });

    try {
      final result = await WellnessApi.saveExercise(
        userId: currentUserId,
        exercise: exercise,
      );

      if (!mounted) return;

      // Reload to retrieve the real saved-record ID for removal.
      await loadSavedWellnessState();

      if (!mounted) return;
      if (!savedExerciseRecordIds.containsKey(exerciseId)) {
        setState(() {
          savedExerciseRecordIds[exerciseId] = 0;
        });
      }

      showMessage(
        result['message']?.toString() ?? 'Exercise saved to Activity Log.',
      );
    } catch (error) {
      if (!mounted) return;

      showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSavingExercise = false;
          savingExerciseId = null;
        });
      }
    }
  }

  Future<void> removeSavedArticle(WellnessArticle article) async {
    final articleId = articleKey(article);
    var savedId = articleSavedRecordId(article);

    if (savedId <= 0) {
      await loadSavedWellnessState();
      savedId = articleSavedRecordId(article);
    }

    if (savedId <= 0) {
      showMessage(
        'Unable to find the saved article record. Refresh Wellness Hub and try again.',
        isError: true,
      );
      return;
    }

    if (isSavingArticle) return;

    setState(() {
      isSavingArticle = true;
      savingArticleId = articleId;
    });

    try {
      await WellnessApi.deleteSavedArticle(savedArticleId: savedId);

      if (!mounted) return;

      setState(() {
        savedArticleRecordIds.remove(articleId);
      });

      showMessage('Article removed from Activity Log.');
    } catch (error) {
      if (!mounted) return;

      showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSavingArticle = false;
          savingArticleId = null;
        });
      }
    }
  }

  Future<void> removeSavedExercise(WellnessExercise exercise) async {
    final exerciseId = exerciseKey(exercise);
    var savedId = exerciseSavedRecordId(exercise);

    if (savedId <= 0) {
      await loadSavedWellnessState();
      savedId = exerciseSavedRecordId(exercise);
    }

    if (savedId <= 0) {
      showMessage(
        'Unable to find the saved exercise record. Refresh Wellness Hub and try again.',
        isError: true,
      );
      return;
    }

    if (isSavingExercise) return;

    setState(() {
      isSavingExercise = true;
      savingExerciseId = exerciseId;
    });

    try {
      await WellnessApi.deleteSavedExercise(savedExerciseId: savedId);

      if (!mounted) return;

      setState(() {
        savedExerciseRecordIds.remove(exerciseId);
      });

      showMessage('Exercise removed from Activity Log.');
    } catch (error) {
      if (!mounted) return;

      showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSavingExercise = false;
          savingExerciseId = null;
        });
      }
    }
  }

  Widget buildArticleSaveControl(
    WellnessArticle article, {
    bool filled = false,
  }) {
    final saved = isArticleSaved(article);
    final saving =
        isSavingArticle && savingArticleId == articleKey(article);

    return Material(
      color: saved
          ? const Color(0xFFE0F4E3)
          : filled
              ? Colors.white.withOpacity(0.92)
              : Colors.transparent,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: saved ? 'Remove saved article' : 'Save article',
        onPressed: saving ? null : () => toggleArticleSave(article),
        icon: saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.3,
                  color: Color(0xFF168A2A),
                ),
              )
            : Icon(
                saved
                    ? Icons.bookmark_remove_rounded
                    : filled
                        ? Icons.bookmark_add_rounded
                        : Icons.bookmark_add_outlined,
                color: const Color(0xFF168A2A),
              ),
      ),
    );
  }

  Widget buildArticleSaveButton(WellnessArticle article) {
    final saved = isArticleSaved(article);
    final saving =
        isSavingArticle && savingArticleId == articleKey(article);

    return ElevatedButton.icon(
      onPressed: saving ? null : () => toggleArticleSave(article),
      icon: saving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Colors.white,
              ),
            )
          : Icon(
              saved
                  ? Icons.bookmark_remove_rounded
                  : Icons.bookmark_add_rounded,
            ),
      label: Text(saved ? 'Saved' : 'Save Article'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF168A2A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget buildExerciseSaveButton(
    WellnessExercise exercise, {
    required String label,
  }) {
    final saved = isExerciseSaved(exercise);
    final saving =
        isSavingExercise && savingExerciseId == exerciseKey(exercise);

    return ElevatedButton.icon(
      onPressed: saving ? null : () => toggleExerciseSave(exercise),
      icon: saving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Colors.white,
              ),
            )
          : Icon(
              saved
                  ? Icons.bookmark_remove_rounded
                  : Icons.bookmark_add_rounded,
            ),
      label: Text(saved ? 'Saved' : label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF168A2A),
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFF168A2A),
        disabledForegroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 13),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
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

  void openArticleDetails(WellnessArticle article) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.90,
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildDetailsImage(article),
                        const SizedBox(height: 20),
                        buildMiniLabel(
                          article.category.isEmpty
                              ? 'WELLNESS'
                              : article.category,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          article.title,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 27,
                            height: 1.12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          article.meta,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13.5,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          article.body.isEmpty
                              ? 'No article content is available.'
                              : article.body,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: buildArticleSaveButton(article),
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


  void openExerciseDetails(WellnessExercise exercise) {
    final subtitleParts = <String>[];

    if (exercise.difficulty.isNotEmpty) {
      subtitleParts.add(exercise.difficulty);
    }

    if (exercise.programName.isNotEmpty) {
      subtitleParts.add(exercise.programName);
    }

    final subtitle = subtitleParts.isEmpty
        ? 'Exercise program'
        : subtitleParts.join(' • ');

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
                  padding: const EdgeInsets.fromLTRB(10, 0, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () {
                          Navigator.pop(sheetContext);
                        },
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildExerciseDetailsHero(exercise),
                        const SizedBox(height: 18),
                        buildMiniLabel(
                          exercise.category.isEmpty
                              ? 'EXERCISE'
                              : exercise.category,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          exercise.name.isEmpty
                              ? 'Unnamed Exercise'
                              : exercise.name,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 29,
                            height: 1.08,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            height: 1.35,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: buildExerciseInfoChip(
                                icon: Icons.repeat_rounded,
                                label: 'Sets',
                                value: '${exercise.sets}',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: buildExerciseInfoChip(
                                icon: Icons.fitness_center_rounded,
                                label: 'Reps',
                                value: exercise.reps.isEmpty
                                    ? '12'
                                    : exercise.reps,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: buildExerciseInfoChip(
                                icon: Icons.timer_rounded,
                                label: 'Rest',
                                value: '${exercise.restSeconds}s',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        if (exercise.meaning.isNotEmpty)
                          buildExerciseDetailSection(
                            icon: Icons.lightbulb_rounded,
                            title: 'Meaning',
                            content: exercise.meaning,
                          ),
                        if (exercise.steps.isNotEmpty)
                          buildExerciseDetailSection(
                            icon: Icons.checklist_rounded,
                            title: 'Steps',
                            content: exercise.steps,
                          ),
                        if (exercise.benefits.isNotEmpty)
                          buildExerciseDetailSection(
                            icon: Icons.health_and_safety_rounded,
                            title: 'Benefits',
                            content: exercise.benefits,
                          ),
                        if (exercise.meaning.isEmpty &&
                            exercise.steps.isEmpty &&
                            exercise.benefits.isEmpty)
                          buildExerciseDetailSection(
                            icon: Icons.info_outline_rounded,
                            title: 'Details',
                            content:
                                'No detailed content is available for this exercise yet.',
                          ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: buildExerciseSaveButton(
                            exercise,
                            label: 'Save Exercise',
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

  Widget buildExerciseDetailsHero(WellnessExercise exercise) {
    return Container(
      height: 175,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F7C23), Color(0xFF1E9F36), Color(0xFF77D889)],
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

  Widget buildExerciseInfoChip({
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

  Widget buildExerciseDetailSection({
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
              child: selectedTab == 0
                  ? buildArticlesTab()
                  : buildExercisesTab(),
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
              Navigator.pop(context);
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
          colors: [Color(0xFF0F7C23), Color(0xFF1E9F36), Color(0xFF5ACD70)],
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wellness for you',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Articles and exercise content in one clean, feel-good space.',
                  style: TextStyle(
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
    if (isLoadingArticles) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF168A2A)),
      );
    }

    if (articlesError.isNotEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(22, 40, 22, 22),
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.red, size: 52),
          const SizedBox(height: 14),
          const Text(
            'Unable to load articles',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            articlesError,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: loadArticles,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ),
        ],
      );
    }

    if (allArticles.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadArticles,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 60, 22, 22),
          children: const [
            Icon(Icons.article_outlined, color: Color(0xFF168A2A), size: 54),
            SizedBox(height: 14),
            Text(
              'No wellness articles are available.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadArticles,
      color: const Color(0xFF168A2A),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
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
          buildFeaturedArticleCard(allArticles.first),
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
          ...allArticles.skip(1).map(buildArticleListCard),
        ],
      ),
    );
  }

  Widget buildFeaturedArticleCard(WellnessArticle item) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => openArticleDetails(item),
      child: Container(
        height: 220,
        decoration: cardDecoration(),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            buildArticleImage(item, fallbackIconSize: 70),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x33000000), Color(0xDD000000)],
                ),
              ),
            ),
            Positioned(
              top: 18,
              left: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Featured',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: buildArticleSaveControl(
                item,
                filled: true,
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      height: 1.07,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
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

  Widget buildArticleListCard(WellnessArticle item) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => openArticleDetails(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: cardDecoration(),
        child: Row(
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: buildArticleImage(item, fallbackIconSize: 34),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildMiniLabel(
                    item.category.isEmpty ? 'WELLNESS' : item.category,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 17,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black45,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            buildArticleSaveControl(item),
          ],
        ),
      ),
    );
  }

  Widget buildArticleImage(
    WellnessArticle article, {
    required double fallbackIconSize,
  }) {
    if (article.assetImagePath.isEmpty) {
      return buildArticleImageFallback(fallbackIconSize);
    }

    return Image.asset(
      article.assetImagePath,
      fit: BoxFit.cover,
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            return buildArticleImageFallback(fallbackIconSize);
          },
    );
  }

  Widget buildArticleImageFallback(double iconSize) {
    return Container(
      color: const Color(0xFFDCEEDB),
      alignment: Alignment.center,
      child: Icon(
        Icons.menu_book_rounded,
        color: const Color(0xFF168A2A),
        size: iconSize,
      ),
    );
  }

  Widget buildDetailsImage(WellnessArticle article) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: buildArticleImage(article, fallbackIconSize: 70),
      ),
    );
  }

  Widget buildExercisesTab() {
    if (isLoadingExercises) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF168A2A)),
      );
    }

    if (exercisesError.isNotEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(22, 40, 22, 22),
        children: [
          const Icon(Icons.fitness_center_rounded, color: Colors.red, size: 52),
          const SizedBox(height: 14),
          const Text(
            'Unable to load exercises',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            exercisesError,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: loadExercises,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ),
        ],
      );
    }

    if (allExercises.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadExercises,
        color: const Color(0xFF168A2A),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 60, 22, 22),
          children: const [
            Icon(
              Icons.fitness_center_rounded,
              color: Color(0xFF168A2A),
              size: 54,
            ),
            SizedBox(height: 14),
            Text(
              'No exercises are available for this account yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            Text(
              'Pull down to refresh after exercises are added.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadExercises,
      color: const Color(0xFF168A2A),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
        itemCount: allExercises.length,
        itemBuilder: (context, index) {
          return buildExerciseCard(index: index, exercise: allExercises[index]);
        },
      ),
    );
  }

  Widget buildExerciseCard({
    required int index,
    required WellnessExercise exercise,
  }) {
    final icon = index % 3 == 0
        ? Icons.directions_run_rounded
        : index % 3 == 1
        ? Icons.fitness_center_rounded
        : Icons.local_fire_department_rounded;

    final topColors = index % 3 == 0
        ? [const Color(0xFF2F9E44), const Color(0xFF74C882)]
        : index % 3 == 1
        ? [const Color(0xFF2D6A4F), const Color(0xFF74A98B)]
        : [const Color(0xFF0B6E1F), const Color(0xFF35B653)];

    final subtitleParts = <String>[];

    if (exercise.difficulty.isNotEmpty) {
      subtitleParts.add(exercise.difficulty);
    }

    if (exercise.programName.isNotEmpty) {
      subtitleParts.add(exercise.programName);
    }

    final subtitle = subtitleParts.isEmpty
        ? 'Exercise program'
        : subtitleParts.join(' • ');

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => openExerciseDetails(exercise),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: cardDecoration(),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: topColors),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -28,
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: Colors.white.withOpacity(0.14),
                      size: 112,
                    ),
                  ),
                  Center(
                    child: Icon(icon, color: Colors.white, size: 54),
                  ),
                  Positioned(
                    right: 14,
                    top: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'View',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
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
                  buildMiniLabel(
                    exercise.category.isEmpty ? 'EXERCISE' : exercise.category,
                  ),
                  const SizedBox(height: 9),
                  Text(
                    exercise.name.isEmpty ? 'Unnamed Exercise' : exercise.name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      height: 1.17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (exercise.meaning.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      exercise.meaning,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    '${exercise.sets} sets • '
                    '${exercise.reps} reps • '
                    '${exercise.restSeconds}s rest',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => openExerciseDetails(exercise),
                          icon: const Icon(Icons.visibility_rounded),
                          label: const Text('View Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF168A2A),
                            side: const BorderSide(
                              color: Color(0xFF168A2A),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildExerciseSaveButton(
                          exercise,
                          label: 'Save',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
        ),
      ),
    );
  }

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: const Color(0xFFE4EBE1)),
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
