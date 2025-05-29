// Updated model to include `guidelines` field

class LSVInfo {
  final String id;
  final LSVQuestions questions;
  final List<LSVSection> sections;
  final List<LSVGuideline> guidelines;

  LSVInfo({
    required this.id,
    required this.questions,
    required this.sections,
    required this.guidelines,
  });

  factory LSVInfo.fromJson(Map<String, dynamic> json) {
    return LSVInfo(
      id: json['_id'],
      questions: LSVQuestions.fromJson(json['questions']),
      sections: (json['sections'] as List)
          .map((e) => LSVSection.fromJson(e))
          .toList(),
      guidelines: (json['guidelines'] as List)
          .map((e) => LSVGuideline.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'questions': questions.toJson(),
        'sections': sections.map((e) => e.toJson()).toList(),
        'guidelines': guidelines.map((e) => e.toJson()).toList(),
      };
}

class LSVQuestions {
  final String whatIsLSV;
  final String importance;
  final String safety;
  final String id;

  LSVQuestions({
    required this.whatIsLSV,
    required this.importance,
    required this.safety,
    required this.id,
  });

  factory LSVQuestions.fromJson(Map<String, dynamic> json) {
    return LSVQuestions(
      whatIsLSV: json['whatIsLSV'],
      importance: json['importance'],
      safety: json['safety'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'whatIsLSV': whatIsLSV,
        'importance': importance,
        'safety': safety,
        '_id': id,
      };
}

class LSVSection {
  final String title;
  final String description;
  final bool isActive;
  final String id;

  LSVSection({
    required this.title,
    required this.description,
    required this.isActive,
    required this.id,
  });

  factory LSVSection.fromJson(Map<String, dynamic> json) {
    return LSVSection(
      title: json['title'],
      description: json['description'],
      isActive: json['isActive'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'isActive': isActive,
        '_id': id,
      };
}

class LSVGuideline {
  final String title;
  final String description;
  final String imageUrl;
  final String id;

  LSVGuideline({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.id,
  });

  factory LSVGuideline.fromJson(Map<String, dynamic> json) {
    return LSVGuideline(
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        '_id': id,
      };
}
