import 'package:cartie/core/models/question_submit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizResultsScreen extends StatelessWidget {
  final QuizResult quizResult;

  const QuizResultsScreen({Key? key, required this.quizResult})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Quiz Results',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: colors.onBackground,
          ),
        ),
        centerTitle: true,
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.onBackground),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildScoreCircle(context),
            const SizedBox(height: 24),
            _buildStatusIndicator(context),
            const SizedBox(height: 24),
            _buildStatistics(context),
            const SizedBox(height: 24),
            _buildQuestionsReview(context),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCircle(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: CircularProgressIndicator(
            value: quizResult.score / 100,
            strokeWidth: 12,
            backgroundColor: colors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              quizResult.isPassed ? colors.primary : colors.error,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${quizResult.score}%',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: colors.onBackground,
              ),
            ),
            Text(
              'Score',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: quizResult.isPassed
            ? colors.primary.withOpacity(0.1)
            : colors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            quizResult.isPassed ? Icons.check_circle : Icons.cancel,
            color: quizResult.isPassed ? colors.primary : colors.error,
          ),
          const SizedBox(width: 8),
          Text(
            quizResult.isPassed ? 'Passed' : 'Failed',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: quizResult.isPassed ? colors.primary : colors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            'Correct',
            '${quizResult.correctAnswers}/${quizResult.totalQuestions}',
            Icons.check_circle,
            Colors.green,
          ),
          _buildStatItem(
            context,
            'Attempt',
            '${quizResult.attemptNumber}',
            Icons.assignment_turned_in,
            colors.primary,
          ),
          _buildStatItem(
            context,
            'Completed',
            quizResult.sectionCompleted ? 'Yes' : 'No',
            Icons.flag,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String title, String value,
      IconData icon, Color color) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.onBackground,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionsReview(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question Review',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colors.onBackground,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quizResult.passedAttemptDetails.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final answeredQuestion = quizResult.passedAttemptDetails[index];
            return _buildQuestionCard(context, answeredQuestion, index + 1);
          },
        ),
      ],
    );
  }

  Widget _buildQuestionCard(BuildContext context,
      AnsweredQuestion answeredQuestion, int questionNumber) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: answeredQuestion.isCorrect
                        ? Colors.green.withOpacity(0.2)
                        : colors.error.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$questionNumber',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: answeredQuestion.isCorrect
                          ? Colors.green
                          : colors.error,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    answeredQuestion.question.question,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colors.onBackground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...answeredQuestion.question.options.map(
              (option) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      _getOptionIcon(option, answeredQuestion),
                      size: 16,
                      color: _getOptionColor(context, option, answeredQuestion),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option.text,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _getOptionColor(
                              context, option, answeredQuestion),
                          fontWeight:
                              option.id == answeredQuestion.selectedOption
                                  ? FontWeight.w600
                                  : FontWeight.normal,
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
  }

  IconData _getOptionIcon(
      RevQuestionOption option, AnsweredQuestion answeredQuestion) {
    if (option.isCorrect) return Icons.check_circle;
    if (option.id == answeredQuestion.selectedOption && !option.isCorrect) {
      return Icons.cancel;
    }
    return Icons.circle_outlined;
  }

  Color _getOptionColor(BuildContext context, RevQuestionOption option,
      AnsweredQuestion answeredQuestion) {
    final colors = Theme.of(context).colorScheme;

    if (option.isCorrect) return Colors.green;
    if (option.id == answeredQuestion.selectedOption && !option.isCorrect) {
      return colors.error;
    }
    return colors.onSurfaceVariant;
  }
}
