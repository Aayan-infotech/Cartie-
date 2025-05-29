class QuestionSubmission {
  final String locationId;
  final String sectionId;
  final String sectionNumber;
  final int duration;
  final List<QuestionAnswer> questions;

  QuestionSubmission({
    required this.locationId,
    required this.sectionId,
    required this.sectionNumber,
    required this.duration,
    required this.questions,
  });

  factory QuestionSubmission.fromJson(Map<String, dynamic> json) {
    return QuestionSubmission(
      locationId: json['locationId'] ?? '',
      sectionId: json['sectionId'] ?? '',
      sectionNumber: json['sectionNumber'] ?? '',
      duration: json['duration'] ?? 0,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => QuestionAnswer.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locationId': locationId,
      'sectionId': sectionId,
      'sectionNumber': sectionNumber,
      'duration': duration,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class QuestionAnswer {
  final String questionId;
  final String selectedOption;

  QuestionAnswer({
    required this.questionId,
    required this.selectedOption,
  });

  factory QuestionAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionAnswer(
      questionId: json['questionId'] ?? '',
      selectedOption: json['selectedOption'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedOption': selectedOption,
    };
  }
}
