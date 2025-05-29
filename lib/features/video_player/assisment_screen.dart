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

  // void _calculateScore() {
  //   final provider = context.read<CourseProvider>();
  //   provider.completeAssessment();
  //   int score = 0;
  //   final questions = provider.quiz?.questions ?? [];

  //   for (int i = 0; i < questions.length; i++) {
  //     if (_selectedAnswers[i] != null &&
  //         questions[i].options[_selectedAnswers[i]!].isCorrect) {
  //       score++;
  //     }
  //   }

  //   setState(() {
  //     _score = score;
  //     _showResults = true;
  //   });
  // }
  void _calculateScore() async {
    final provider = context.read<CourseProvider>();
    provider.completeAssessment();
    int score = 0;
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

    List<QuestionAnswer> questionAnswers = [];
    for (int i = 0; i < questions.length; i++) {
      final selectedIndex = _selectedAnswers[i]!;
      if (questions[i].options[selectedIndex].isCorrect) {
        score++;
      }
      questionAnswers.add(
        QuestionAnswer(
          questionId: questions[i].id, // Ensure Question model has an `id`
          selectedOption: questions[i].options[selectedIndex].id,
        ),
      );
    }

    // Create QuestionSubmission instance
    final submission = QuestionSubmission(
      locationId: widget.locationId,
      sectionId: widget.sectionId,
      sectionNumber: widget.sectionNumber.toString(),
      duration: provider.elapsedSeconds,
      questions: questionAnswers,
    );

    // Submit the quiz data
    var response = await provider.submitQuiz(submission);
    if (response.success) {
      await provider.fetchCourseSections();
    }

    setState(() {
      _score = score;
      _showResults = true;
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
    provider.pauseAssessment();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Assessment Paused"),
        content: const Text("Do you want to resume or exit the assessment?"),
        actions: [
          TextButton(
            onPressed: () {
              provider.resumeAssessment();
              Navigator.pop(context);
            },
            child: const Text("Resume"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Exit"),
          ),
        ],
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Section ${widget.sectionNumber} Assessment",
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 30),
          const Icon(
            Icons.quiz,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              context.read<CourseProvider>().startAssessment();
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[800],
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child:
                const Text("Start Assessment", style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(Question question, int index, QuizSection quiz) {
    final provider = context.read<CourseProvider>();
    final isLastQuestion = index == provider.quiz!.questions.length - 1;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (index + 1) / provider.quiz!.questions.length,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
            const SizedBox(height: 20),
            Text(
              "Question ${index + 1}",
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              question.question,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            ...question.options.asMap().entries.map((entry) {
              final optionIndex = entry.key;
              final option = entry.value;
              final isSelected = _selectedAnswers[index] == optionIndex;

              return _OptionCard(
                optionText: option.text,
                isSelected: isSelected,
                isCorrect: option.isCorrect,
                showResults: _showResults,
                onTap: () {
                  if (!_showResults) {
                    _animationController.reset();
                    _animationController.forward();
                    setState(() => _selectedAnswers[index] = optionIndex);
                  }
                },
              );
            }),
            const SizedBox(height: 30),
            if (!_showResults) _buildNavigationControls(isLastQuestion, index),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.red),
                    Text(
                      _formatTime(provider.elapsedSeconds),
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: _showPauseDialog,
                  color: Colors.red,
                ),
              ],
            )
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
    final totalQuestions = provider.quiz?.questions.length ?? 0;
    final percentage = (_score / totalQuestions) * 100;
    final isPassed = percentage >= 60; // Adjust passing threshold as needed

    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.2),
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
              color: isPassed ? Colors.green : Colors.red,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              isPassed ? "Assessment Passed!" : "Assessment Failed",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isPassed ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 25),
            _buildResultRow("Total Questions:", "$totalQuestions"),
            _buildResultRow("Correct Answers:", "$_score"),
            _buildResultRow("Your Score:", "${percentage.toStringAsFixed(1)}%"),
            _buildResultRow("Attempt Number:", "2"), // From response data
            const SizedBox(height: 30),
            Column(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Back to Course"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                SizedBox(
                  height: 20,
                ),
                if (!isPassed)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text("Try Again"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      // Add retry logic
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
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

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _showResults
            ? null
            : provider.assessmentInProgress
                ? AppBar(
                    title: Text(
                      "Section ${widget.sectionNumber} Assessment",
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.black,
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
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : !provider.assessmentInProgress && !_showResults
                ? _buildStartScreen()
                : quiz?.questions.isEmpty ?? true
                    ? const Center(
                        child: Text(
                          "No questions available",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )
                    : _showResults
                        ? _buildResultsScreen()
                        : PageView.builder(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: quiz!.questions.length,
                            itemBuilder: (context, index) => _buildQuestionPage(
                                quiz.questions[index], index, quiz),
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
    if (!showResults) return isSelected ? Colors.red : Colors.transparent;
    if (isSelected) return isCorrect ? Colors.green : Colors.red;
    return isCorrect ? Colors.green.withOpacity(0.5) : Colors.transparent;
  }

  Color _getTextColor(BuildContext context) {
    if (!showResults) return isSelected ? Colors.red : Colors.white;
    if (isSelected) return isCorrect ? Colors.green : Colors.red;
    return isCorrect ? Colors.green : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[900],
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
                  style: TextStyle(
                    color: _getTextColor(context),
                    fontSize: 16,
                  ),
                ),
              ),
              if (showResults && isSelected)
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
