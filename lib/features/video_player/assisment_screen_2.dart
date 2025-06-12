// import 'dart:async';
// import 'package:cartie/core/models/question_submition.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cartie/core/models/quiz_model.dart';
// import 'package:cartie/features/providers/course_provider.dart';
//
// class AssessmentScreen extends StatefulWidget {
//   final String locationId;
//   final String sectionId;
//   final int sectionNumber;
//
//   const AssessmentScreen({
//     Key? key,
//     required this.locationId,
//     required this.sectionId,
//     required this.sectionNumber,
//   }) : super(key: key);
//
//   @override
//   _AssessmentScreenState createState() => _AssessmentScreenState();
// }
//
// class _AssessmentScreenState extends State<AssessmentScreen>
//     with WidgetsBindingObserver, SingleTickerProviderStateMixin {
//   late PageController _pageController;
//   List<int?> _selectedAnswers = [];
//   bool _showResults = false;
//   int _score = 0;
//   int _currentPage = 0;
//   late AnimationController _animationController;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _pageController = PageController();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _pageController.addListener(_pageListener);
//       _fetchQuizData();
//     });
//   }
//
//   void _pageListener() {
//     final page = _pageController.page?.round();
//     if (page != null && page != _currentPage) {
//       setState(() => _currentPage = page);
//     }
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     final provider = context.read<CourseProvider>();
//     if (state == AppLifecycleState.paused) {
//       provider.pauseAssessment();
//     } else if (state == AppLifecycleState.resumed &&
//         provider.assessmentInProgress) {
//       provider.resumeAssessment();
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _pageController.removeListener(_pageListener);
//     _pageController.dispose();
//     _animationController.dispose();
//     final provider = context.read<CourseProvider>();
//     if (!_showResults && provider.assessmentInProgress && !provider.isPaused) {
//       provider.completeAssessment();
//     }
//     super.dispose();
//   }
//
//   void _fetchQuizData() async {
//     final provider = context.read<CourseProvider>();
//     await provider.fetchQuiz(
//       locationId: widget.locationId,
//       sectionId: widget.sectionId,
//       sectionNumber: widget.sectionNumber,
//     );
//     if (provider.quiz != null) {
//       setState(() {
//         _selectedAnswers = List.filled(provider.quiz!.questions.length, null);
//       });
//     }
//   }
//
//   void _calculateScore() async {
//     final provider = context.read<CourseProvider>();
//     provider.completeAssessment();
//     int score = 0;
//     final questions = provider.quiz?.questions ?? [];
//
//     if (_selectedAnswers.contains(null)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please answer all questions before submitting.'),
//         ),
//       );
//       return;
//     }
//
//     List<QuestionAnswer> questionAnswers = [];
//     for (int i = 0; i < questions.length; i++) {
//       final selectedIndex = _selectedAnswers[i]!;
//       if (questions[i].options[selectedIndex].isCorrect) {
//         score++;
//       }
//       questionAnswers.add(
//         QuestionAnswer(
//           questionId: questions[i].id,
//           selectedOption: questions[i].options[selectedIndex].id,
//         ),
//       );
//     }
//
//     final submission = QuestionSubmission(
//       locationId: widget.locationId,
//       sectionId: widget.sectionId,
//       sectionNumber: widget.sectionNumber.toString(),
//       duration: provider.elapsedSeconds,
//       questions: questionAnswers,
//     );
//
//     var response = await provider.submitQuiz(submission);
//     if (response.success) {
//       await provider.fetchCourseSections();
//     }
//
//     setState(() {
//       _score = score;
//       _showResults = true;
//     });
//   }
//
//   String _formatTime(int seconds) {
//     final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
//     final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
//     return '$minutes:$remainingSeconds';
//   }
//
//   Future<bool> _onWillPop() async {
//     if (_showResults) return true;
//     final provider = context.read<CourseProvider>();
//     if (!provider.assessmentInProgress) return true;
//
//     _showPauseDialog();
//     return false;
//   }
//
//   void _showPauseDialog() {
//     final provider = context.read<CourseProvider>();
//     provider.pauseAssessment();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Assessment Paused"),
//         content: const Text("Do you want to resume or exit the assessment?"),
//         actions: [
//           TextButton(
//             onPressed: () {
//               provider.resumeAssessment();
//               Navigator.pop(context);
//             },
//             child: const Text("Resume"),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             child: const Text("Exit"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStartScreen() {
//     final theme = Theme.of(context);
//     final colors = theme.colorScheme;
//     final textTheme = theme.textTheme;
//
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             "Section ${widget.sectionNumber} Assessment",
//             style: textTheme.headlineMedium?.copyWith(color: colors.onBackground),
//           ),
//           const SizedBox(height: 30),
//           Icon(
//             Icons.quiz,
//             size: 80,
//             color: colors.primary,
//           ),
//           const SizedBox(height: 30),
//           ElevatedButton(
//             onPressed: () {
//               context.read<CourseProvider>().startAssessment();
//               setState(() {});
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: colors.primary,
//               padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//             child: Text(
//               "Start Assessment",
//               style: textTheme.titleLarge?.copyWith(color: colors.onPrimary),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQuestionPage(Question question, int index, QuizSection quiz) {
//     final theme = Theme.of(context);
//     final colors = theme.colorScheme;
//     final textTheme = theme.textTheme;
//     final provider = context.read<CourseProvider>();
//     final isLastQuestion = index == provider.quiz!.questions.length - 1;
//
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             LinearProgressIndicator(
//               value: (index + 1) / provider.quiz!.questions.length,
//               backgroundColor: colors.surfaceVariant,
//               valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               "Question ${index + 1}",
//               style: textTheme.titleLarge?.copyWith(color: colors.onBackground),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               question.question,
//               style: textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: colors.onBackground,
//               ),
//             ),
//             const SizedBox(height: 30),
//             ...question.options.asMap().entries.map((entry) {
//               final optionIndex = entry.key;
//               final option = entry.value;
//               final isSelected = _selectedAnswers[index] == optionIndex;
//
//               return _OptionCard(
//                 optionText: option.text,
//                 isSelected: isSelected,
//                 isCorrect: option.isCorrect,
//                 showResults: _showResults,
//                 onTap: () {
//                   if (!_showResults) {
//                     _animationController.reset();
//                     _animationController.forward();
//                     setState(() => _selectedAnswers[index] = optionIndex);
//                   }
//                 },
//               );
//             }),
//             const SizedBox(height: 30),
//             if (!_showResults) ...[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ElevatedButton(
//                     onPressed: currentIndex > 0
//                         ? () => _pageController.previousPage(
//                       duration: const Duration(milliseconds: 300),
//                       curve: Curves.easeInOut,
//                     )
//                         : null,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: colors.surfaceVariant,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 24, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                     ),
//                     child: Text(
//                       "Previous",
//                       style: textTheme.titleMedium?.copyWith(
//                           color: colors.onSurfaceVariant),
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () => isLastQuestion
//                         ? _calculateScore()
//                         : _pageController.nextPage(
//                       duration: const Duration(milliseconds: 300),
//                       curve: Curves.easeInOut,
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: colors.primary,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 24, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                     ),
//                     child: Text(
//                       isLastQuestion ? "Submit" : "Next",
//                       style: textTheme.titleMedium?.copyWith(
//                           color: colors.onPrimary),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.timer, color: colors.primary),
//                   const SizedBox(width: 8),
//                   Text(
//                     _formatTime(provider.elapsedSeconds),
//                     style: textTheme.titleMedium?.copyWith(
//                         color: colors.primary),
//                   ),
//                   const SizedBox(width: 20),
//                   IconButton(
//                     icon: Icon(Icons.pause, color: colors.primary),
//                     onPressed: _showPauseDialog,
//                   ),
//                 ],
//               )
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildResultsScreen() {
//     final theme = Theme.of(context);
//     final colors = theme.colorScheme;
//     final textTheme = theme.textTheme;
//     final provider = context.read<CourseProvider>();
//     final totalQuestions = provider.quiz?.questions.length ?? 0;
//     final percentage = (_score / totalQuestions) * 100;
//     final isPassed = percentage >= 60;
//
//     return Center(
//       child: Container(
//         margin: const EdgeInsets.all(20),
//         padding: const EdgeInsets.all(25),
//         decoration: BoxDecoration(
//           color: colors.surface,
//           borderRadius: BorderRadius.circular(25),
//           boxShadow: [
//             BoxShadow(
//               color: colors.primary.withOpacity(0.2),
//               spreadRadius: 5,
//               blurRadius: 10,
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               isPassed ? Icons.check_circle : Icons.error,
//               color: isPassed ? Colors.green : colors.error,
//               size: 80,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               isPassed ? "Assessment Passed!" : "Assessment Failed",
//               style: textTheme.headlineMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: isPassed ? Colors.green : colors.error,
//               ),
//             ),
//             const SizedBox(height: 25),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Total Questions:",
//                     style: textTheme.titleMedium?.copyWith(
//                         color: colors.onSurface.withOpacity(0.7)),
//                   ),
//                   Text(
//                     "$totalQuestions",
//                     style: textTheme.titleMedium?.copyWith(
//                         color: colors.onSurface,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Correct Answers:",
//                     style: textTheme.titleMedium?.copyWith(
//                         color: colors.onSurface.withOpacity(0.7)),
//                   ),
//                   Text(
//                     "$_score",
//                     style: textTheme.titleMedium?.copyWith(
//                         color: colors.onSurface,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Your Score:",
//                     style: textTheme.titleMedium?.copyWith(
//                         color: colors.onSurface.withOpacity(0.7)),
//                   ),
//                   Text(
//                     "${percentage.toStringAsFixed(1)}%",
//                     style: textTheme.titleMedium?.copyWith(
//                         color: colors.onSurface,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Attempt Number:",
//                     style: textTheme.titleMedium?.copyWith(
//                         color: colors.onSurface.withOpacity(0.7)),
//                   ),
//                   Text(
//                     "2",
//                     style: textTheme.titleMedium?.copyWith(
//                         color: colors.onSurface,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),
//             Column(
//               children: [
//                 ElevatedButton.icon(
//                   icon: Icon(Icons.arrow_back, color: colors.onPrimary),
//                   label: Text("Back to Course",
//                       style: textTheme.titleMedium?.copyWith(
//                           color: colors.onPrimary)),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: colors.primary,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 30, vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   onPressed: () => Navigator.of(context).pop(),
//                 ),
//                 const SizedBox(height: 20),
//                 if (!isPassed)
//                   ElevatedButton.icon(
//                     icon: Icon(Icons.refresh, color: colors.onSurface),
//                     label: Text("Try Again",
//                         style: textTheme.titleMedium?.copyWith(
//                             color: colors.onSurface)),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: colors.surfaceVariant,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 30, vertical: 15),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                     ),
//                     onPressed: () {
//                       // Add retry logic
//                     },
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colors = theme.colorScheme;
//     final textTheme = theme.textTheme;
//     final provider = context.watch<CourseProvider>();
//     final quiz = provider.quiz;
//
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: _showResults
//             ? null
//             : provider.assessmentInProgress
//             ? AppBar(
//           title: Text(
//             "Section ${widget.sectionNumber} Assessment",
//             style: textTheme.titleLarge?.copyWith(
//                 color: colors.onBackground),
//           ),
//           backgroundColor: colors.background,
//           actions: [
//             if (quiz != null && quiz.questions.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(right: 20),
//                 child: Center(
//                   child: Text(
//                     "${_currentPage + 1}/${quiz.questions.length}",
//                     style: textTheme.titleMedium?.copyWith(
//                         color: colors.primary),
//                   ),
//                 ),
//               ),
//           ],
//         )
//             : null,
//         body: provider.isLoading
//             ? Center(child: CircularProgressIndicator(color: colors.primary))
//             : !provider.assessmentInProgress && !_showResults
//             ? _buildStartScreen()
//             : quiz?.questions.isEmpty ?? true
//             ? Center(
//           child: Text(
//             "No questions available",
//             style: textTheme.titleMedium?.copyWith(
//                 color: colors.onBackground),
//           ),
//         )
//             : _showResults
//             ? _buildResultsScreen()
//             : PageView.builder(
//           controller: _pageController,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: quiz!.questions.length,
//           itemBuilder: (context, index) => _buildQuestionPage(
//               quiz.questions[index], index, quiz),
//         ),
//       ),
//     );
//   }
// }
//
// class _OptionCard extends StatelessWidget {
//   final String optionText;
//   final bool isSelected;
//   final bool isCorrect;
//   final bool showResults;
//   final VoidCallback onTap;
//
//   const _OptionCard({
//     required this.optionText,
//     required this.isSelected,
//     required this.isCorrect,
//     required this.showResults,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colors = theme.colorScheme;
//     final textTheme = theme.textTheme;
//
//     Color getBorderColor() {
//       if (!showResults) return isSelected ? colors.primary : Colors.transparent;
//       if (isSelected) return isCorrect ? Colors.green : colors.error;
//       return isCorrect ? Colors.green.withOpacity(0.5) : Colors.transparent;
//     }
//
//     Color getTextColor() {
//       if (!showResults) return isSelected ? colors.primary : colors.onBackground;
//       if (isSelected) return isCorrect ? Colors.green : colors.error;
//       return isCorrect ? Colors.green : colors.onBackground;
//     }
//
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15),
//       child: InkWell(
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: colors.surface,
//             borderRadius: BorderRadius.circular(15),
//             border: Border.all(
//               color: getBorderColor(),
//               width: 2,
//             ),
//             boxShadow: isSelected
//                 ? [
//               BoxShadow(
//                 color: getBorderColor().withOpacity(0.5),
//                 spreadRadius: 2,
//                 blurRadius: 5,
//               ),
//             ]
//                 : null,
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   optionText,
//                   style: textTheme.titleMedium?.copyWith(
//                     color: getTextColor(),
//                   ),
//                 ),
//               ),
//               if (showResults && isSelected)
//                 Icon(
//                   isCorrect ? Icons.check_circle : Icons.cancel,
//                   color: isCorrect ? Colors.green : colors.error,
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }