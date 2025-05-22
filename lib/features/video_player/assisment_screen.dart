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

class _AssessmentScreenState extends State<AssessmentScreen> {
  late PageController _pageController;
  List<int?> _selectedAnswers = [];
  bool _showResults = false;
  int _score = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      final page = _pageController.page?.round();
      if (page != null && page != _currentPage) {
        setState(() => _currentPage = page);
      }
    });
    _fetchQuizData();
  }

  @override
  void dispose() {
    _pageController.dispose();
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

  void _calculateScore() {
    final provider = context.read<CourseProvider>();
    int score = 0;
    for (int i = 0; i < provider.quiz!.questions.length; i++) {
      final question = provider.quiz!.questions[i];
      final selectedIndex = _selectedAnswers[i];
      if (selectedIndex != null && question.options[selectedIndex].isCorrect) {
        score++;
      }
    }
    setState(() {
      _score = score;
      _showResults = true;
    });
  }

  Widget _buildQuestionPage(Question question, int index) {
    final provider = context.read<CourseProvider>();
    final isLastQuestion = index == provider.quiz!.questions.length - 1;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                    setState(() => _selectedAnswers[index] = optionIndex);
                  }
                },
              );
            }),
            const SizedBox(height: 30),
            if (!_showResults) _buildNavigationControls(isLastQuestion, index),
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
          ),
          child: Text(isLastQuestion ? "Submit" : "Next"),
        ),
      ],
    );
  }

  Widget _buildResultsScreen() {
    final provider = context.read<CourseProvider>();
    final totalQuestions = provider.quiz!.questions.length;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Assessment Complete!",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              "Your Score: $_score/$totalQuestions",
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text("Back to Course"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return Scaffold(
      appBar: _showResults
          ? null
          : AppBar(
              title: Text(
                "Section ${widget.sectionNumber} Assessment",
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.black,
              actions: [
                if (!_showResults && provider.quiz != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Center(
                      child: Text(
                        "${_currentPage + 1}/${provider.quiz!.questions.length}",
                        style: const TextStyle(color: Colors.red, fontSize: 18),
                      ),
                    ),
                  ),
              ],
            ),
      body: provider.quiz == null
          ? const Center(child: CircularProgressIndicator())
          : _showResults
              ? _buildResultsScreen()
              : PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.quiz!.questions.length,
                  itemBuilder: (context, index) => _buildQuestionPage(
                    provider.quiz!.questions[index],
                    index,
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
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: _getBorderColor(context),
              width: 2,
            ),
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
