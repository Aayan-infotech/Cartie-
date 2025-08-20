class QuizSection {
  final String sectionId;
  final String locationId;
  final List<Question> questions;

  QuizSection({required this.locationId,required this.sectionId, required this.questions});

  factory QuizSection.fromJson(Map<String, dynamic> json) {
    return QuizSection(
      locationId: json['locationId']??'',
      sectionId: json['sectionId'] ?? '',
      questions:
          (json['questions'] as List).map((q) => Question.fromJson(q)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionId': sectionId,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class Question {
  final String id;
  final String question;
  final List<Option> options;

  Question({required this.id, required this.question, required this.options});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['_id'],
      question: json['question'],
      options:
          (json['options'] as List).map((opt) => Option.fromJson(opt)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'question': question,
      'options': options.map((opt) => opt.toJson()).toList(),
    };
  }
}

class Option {
  final String id;
  final String text;
  final bool isCorrect;

  Option({required this.id, required this.text, required this.isCorrect});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['_id'],
      text: json['text'],
      isCorrect: json['isCorrect'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'text': text,
      'isCorrect': isCorrect,
    };
  }
}
