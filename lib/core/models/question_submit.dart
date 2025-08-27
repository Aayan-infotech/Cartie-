// file: models/quiz_result.dart
class RevQuestionOption {
  final String id;
  final String text;
  final bool isCorrect;

  RevQuestionOption({
    this.id = '',
    this.text = '',
    this.isCorrect = false,
  });

  factory RevQuestionOption.fromJson(Map<String, dynamic>? json) =>
      RevQuestionOption(
        id: json?['_id'] ?? '',
        text: json?['text'] ?? '',
        isCorrect: json?['isCorrect'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'text': text,
        'isCorrect': isCorrect,
      };
}

class RevQuestion {
  final String id;
  final String question;
  final List<RevQuestionOption> options;

  RevQuestion({
    this.id = '',
    this.question = '',
    this.options = const [],
  });

  factory RevQuestion.fromJson(Map<String, dynamic>? json) => RevQuestion(
        id: json?['_id'] ?? '',
        question: json?['question'] ?? '',
        options: (json?['options'] as List<dynamic>? ?? [])
            .map((o) => RevQuestionOption.fromJson(o))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'question': question,
        'options': options.map((o) => o.toJson()).toList(),
      };
}

class AnsweredQuestion {
  final String id;
  final RevQuestion question;
  final String selectedOption;
  final bool isCorrect;

  AnsweredQuestion({
    this.id = '',
    RevQuestion? question,
    this.selectedOption = '',
    this.isCorrect = false,
  }) : question = question ?? RevQuestion();

  factory AnsweredQuestion.fromJson(Map<String, dynamic>? json) =>
      AnsweredQuestion(
        id: json?['_id'] ?? '',
        question: RevQuestion.fromJson(json?['questionId']),
        selectedOption: json?['selectedOption'] ?? '',
        isCorrect: json?['isCorrect'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'questionId': question.toJson(),
        'selectedOption': selectedOption,
        'isCorrect': isCorrect,
      };
}

class QuizResult {
  final int score;
  final bool isPassed;
  final int totalQuestions;
  final int correctAnswers;
  final int attemptNumber;
  final bool sectionCompleted;
  final List<AnsweredQuestion> passedAttemptDetails;

  QuizResult({
    this.score = 0,
    this.isPassed = false,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.attemptNumber = 0,
    this.sectionCompleted = false,
    this.passedAttemptDetails = const [],
  });

  factory QuizResult.fromJson(Map<String, dynamic>? json) => QuizResult(
        score: json?['score'] ?? 0,
        isPassed: json?['isPassed'] ?? false,
        totalQuestions: json?['totalQuestions'] ?? 0,
        correctAnswers: json?['correctAnswers'] ?? 0,
        attemptNumber: json?['attemptNumber'] ?? 0,
        sectionCompleted: json?['sectionCompleted'] ?? false,
        passedAttemptDetails:
            (json?['passedAttemptDetails'] as List<dynamic>? ?? [])
                .map((e) => AnsweredQuestion.fromJson(e))
                .toList(),
      );

  Map<String, dynamic> toJson() => {
        'score': score,
        'isPassed': isPassed,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'attemptNumber': attemptNumber,
        'sectionCompleted': sectionCompleted,
        'passedAttemptDetails':
            passedAttemptDetails.map((e) => e.toJson()).toList(),
      };
}
