import 'dart:async';
import 'package:cartie/core/models/question_submition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cartie/core/models/quiz_model.dart';
import 'package:cartie/features/providers/course_provider.dart';

class AssessmentScreen extends StatefulWidget {
  final String locationId;
  final String sectionId;
  final int sectionNumber;

  const AssessmentScreen({
    Key? key,
    required this.locationId,
    required this.sectionId,
    required this.sectionNumber,
  }) : super(key: key);

  @override
  _AssessmentScreenState createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late PageController _pageController;
  List<int?> _selectedAnswers = [];
  bool _showResults = false;
  int _score = 0;
  int _currentPage = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.addListener(_pageListener);
      _fetchQuizData();
    });
  }

  void _pageListener() {
    final page = _pageController.page?.round();
    if (page != null && page != _currentPage) {
      setState(() => _currentPage = page);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final provider = context.read<CourseProvider>();
    if (state == AppLifecycleState.paused) {
      provider.pauseAssessment();
    } else if (state == AppLifecycleState.resumed &&
        provider.assessmentInProgress) {
      provider.resumeAssessment();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.removeListener(_pageListener);
    _pageController.dispose();
    _animationController.dispose();
    final provider = context.read<CourseProvider>();
    if (!_showResults && provider.assessmentInProgress && !provider.isPaused) {
      provider.completeAssessment();
    }
    super.dispose();
  }

  void _fetchQuizData() async {
    final provider = context.read<CourseProvider>();
    await provider.fetchQuiz(
      locationId: widget.locationId,
      sectionId: widget.sectionId,
      sectionNumber: widget.sectionNumber,
    );
    if (provider.quiz != null) {
      setState(() {
        _selectedAnswers = List.filled(provider.quiz!.questions.length, null);
      });
    }
  }

  bool isLoading = false;
  void _calculateScore() async {
    setState(() {
      isLoading = true;
    });
    final provider = context.read<CourseProvider>();
    final questions = provider.quiz?.questions ?? [];

    // Check if all questions are answered
    if (_selectedAnswers.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before submitting.'),
        ),
      );
      return;
    }

    // Calculate score locally
    int score = 0;
    List<QuestionAnswer> questionAnswers = [];
    for (int i = 0; i < questions.length; i++) {
      final selectedIndex = _selectedAnswers[i]!;
      if (questions[i].options[selectedIndex].isCorrect) {
        score++;
      }
      questionAnswers.add(
        QuestionAnswer(
          questionId: questions[i].id,
          selectedOption: questions[i].options[selectedIndex].id,
        ),
      );
    }

    // Immediately show results
    setState(() {
      _score = score;
      _showResults = true;
    });

    // Submit in background
    final submission = QuestionSubmission(
      locationId: widget.locationId,
      sectionId: widget.sectionId,
      sectionNumber: widget.sectionNumber.toString(),
      duration: provider.elapsedSeconds,
      questions: questionAnswers,
    );

    provider.completeAssessment();
    var response = await provider.submitQuiz(submission);
    if (response.success) {
      await provider.fetchCourseSections(context);
    }
    setState(() {
      isLoading = false;
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  Future<bool> _onWillPop() async {
    if (_showResults) return true;
    final provider = context.read<CourseProvider>();
    if (!provider.assessmentInProgress) return true;

    _showPauseDialog();
    return false;
  }

  void _showPauseDialog() {
    final provider = context.read<CourseProvider>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    provider.pauseAssessment();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.background,
        title: Text(
          "Assessment Paused",
          style: textTheme.titleLarge?.copyWith(color: colors.onBackground),
        ),
        content: Text(
          "Do you want to resume or exit the assessment?",
          style: textTheme.bodyMedium?.copyWith(color: colors.onBackground),
        ),
        actions: [
          TextButton(
            onPressed: () {
              provider.resumeAssessment();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: colors.primary,
              textStyle: textTheme.labelLarge,
            ),
            child: const Text("Resume"),
          ),
          TextButton(
            onPressed: () {
              if (provider.quiz!.sectionId.isEmpty) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                // Navigator.pop(context); // Exit assessment screen
              } else {
                Navigator.of(context).pop();
                // Navigator.pop(context); // Close dialog
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: colors.error,
              textStyle: textTheme.labelLarge,
            ),
            child: const Text("Exit"),
          ),
        ],
      ),
    );
  }

  Widget _buildStartScreen() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Section ${widget.sectionNumber} Assessment",
            style: textTheme.headlineMedium?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Icon(
            Icons.quiz,
            size: 80,
            color: colors.primary,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              context.read<CourseProvider>().startAssessment();
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: textTheme.titleLarge,
              elevation: 4,
            ),
            child: const Text("Start Assessment"),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(Question question, int index) {
    final provider = context.read<CourseProvider>();
    final isLastQuestion = index == provider.quiz!.questions.length - 1;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Filter out options with "N/A" text
    final validOptions =
        question.options.where((option) => option.text != "N/A").toList();
    // Find the original index of selected answer in the filtered list
    final selectedIndex = _selectedAnswers[index] != null
        ? validOptions.indexWhere(
            (opt) => opt.id == question.options[_selectedAnswers[index]!].id)
        : null;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (index + 1) / provider.quiz!.questions.length,
              backgroundColor: colors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              "Question ${index + 1}",
              style: textTheme.titleLarge?.copyWith(
                color: colors.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              question.question,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onBackground,
              ),
            ),
            const SizedBox(height: 30),
            ...validOptions.asMap().entries.map((entry) {
              final optionIndex = entry.key;
              final option = entry.value;
              final isSelected = selectedIndex == optionIndex;

              return _OptionCard(
                optionText: option.text,
                isSelected: isSelected,
                isCorrect: option.isCorrect,
                showResults: _showResults,
                onTap: () {
                  if (!_showResults) {
                    // Find the original index of this option in the unfiltered list
                    final originalIndex = question.options
                        .indexWhere((opt) => opt.id == option.id);
                    _animationController.reset();
                    _animationController.forward();
                    setState(() => _selectedAnswers[index] = originalIndex);
                  }
                },
              );
            }),
            const SizedBox(height: 30),
            if (!_showResults) _buildNavigationControls(isLastQuestion, index),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Icon(Icons.timer, color: colors.error),
                //     const SizedBox(width: 8),
                //     Text(
                //       _formatTime(provider.elapsedSeconds),
                //       style: textTheme.bodyLarge?.copyWith(
                //         color: colors.error,
                //         fontWeight: FontWeight.w600,
                //       ),
                //     ),
                //   ],
                // ),
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: _showPauseDialog,
                  color: colors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationControls(bool isLastQuestion, int currentIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: currentIndex > 0
              ? () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  )
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text("Previous"),
        ),
        ElevatedButton(
          onPressed: () => isLastQuestion
              ? _calculateScore()
              : _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[800],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(isLastQuestion ? "Submit" : "Next"),
        ),
      ],
    );
  }

  Widget _buildResultsScreen() {
    final provider = context.read<CourseProvider>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final totalQuestions = _selectedAnswers.length;
    final percentage = (_score / totalQuestions) * 100;
    final isPassed = percentage >= 60;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: colors.surfaceVariant,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: isPassed
                  ? colors.primary.withOpacity(0.2)
                  : colors.error.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPassed ? Icons.check_circle : Icons.error,
              color: isPassed ? colors.primary : colors.error,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              isPassed ? "Assessment Passed!" : "Assessment Failed",
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isPassed ? colors.primary : colors.error,
              ),
            ),
            const SizedBox(height: 25),
            _buildResultRow("Total Questions:", "$totalQuestions"),
            _buildResultRow("Correct Answers:", "$_score"),
            _buildResultRow("Your Score:", "${percentage.toStringAsFixed(1)}%"),
            const SizedBox(height: 30),
            Column(
              children: [
                ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Back to Course"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.error,
                      foregroundColor: colors.onError,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      if (provider.quiz!.sectionId.isEmpty) {
                        Navigator.of(context).pop();
                        // Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pop();
                      }
                    } // => Navigator.of(context).pop(),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final quiz = provider.quiz;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _showResults
            ? null
            : provider.assessmentInProgress
                ? AppBar(
                    backgroundColor: colors.background,
                    iconTheme: IconThemeData(color: colors.onBackground),
                    title: Text(
                      "Section ${widget.sectionNumber} Assessment",
                      style: TextStyle(color: colors.onBackground),
                    ),
                    actions: [
                      if (quiz != null && quiz.questions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Center(
                            child: Text(
                              "${_currentPage + 1}/${quiz.questions.length}",
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 18),
                            ),
                          ),
                        ),
                    ],
                  )
                : null,
        body: provider.isLoading || isLoading
            ? const Center(child: CircularProgressIndicator())
            : !provider.assessmentInProgress && !_showResults
                ? _buildStartScreen()
                : quiz?.questions.isEmpty ?? true
                    ? Center(
                        child: Text(
                          "No questions available",
                          style: TextStyle(color: colors.onBackground),
                        ),
                      )
                    : _showResults
                        ? _buildResultsScreen()
                        : PageView.builder(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: quiz!.questions.length,
                            itemBuilder: (context, index) => _buildQuestionPage(
                                quiz.questions[index], index),
                          ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String optionText;
  final bool isSelected;
  final bool isCorrect;
  final bool showResults;
  final VoidCallback onTap;

  const _OptionCard({
    required this.optionText,
    required this.isSelected,
    required this.isCorrect,
    required this.showResults,
    required this.onTap,
  });

  Color _getBorderColor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (!showResults) return isSelected ? colors.error : Colors.transparent;
    if (isSelected) return isCorrect ? colors.primary : colors.error;
    return isCorrect ? colors.primary.withOpacity(0.5) : Colors.transparent;
  }

  Color _getTextColor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (!showResults) return isSelected ? colors.error : colors.onSurface;
    if (isSelected) return isCorrect ? colors.primary : colors.error;
    return isCorrect ? colors.primary : colors.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: _getBorderColor(context),
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _getBorderColor(context).withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  optionText,
                  style: textTheme.bodyLarge?.copyWith(
                    color: _getTextColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (showResults && isSelected)
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? colors.primary : colors.error,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
