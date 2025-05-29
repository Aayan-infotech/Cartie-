import 'package:cartie/core/models/lsv_model.dart';

class CartingRules {
  final String id;
  final CartingQuestions questions;
  final List<CartingSection> sections;
  final List<LSVGuideline> guidelines;

  final DateTime createdAt;

  CartingRules({
    required this.guidelines,
    required this.id,
    required this.questions,
    required this.sections,
    required this.createdAt,
  });

  factory CartingRules.fromJson(Map<String, dynamic> json) {
    return CartingRules(
      guidelines: (json['guidelines'] as List)
          .map((e) => LSVGuideline.fromJson(e))
          .toList(),
      id: json['_id'],
      questions: CartingQuestions.fromJson(json['questions']),
      sections: List<CartingSection>.from(
        json['sections'].map((section) => CartingSection.fromJson(section)),
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'questions': questions.toJson(),
      'sections': sections.map((section) => section.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class CartingQuestions {
  final String cartingRule;
  final String tips;
  final String safety;
  final String id;

  CartingQuestions({
    required this.cartingRule,
    required this.tips,
    required this.safety,
    required this.id,
  });

  factory CartingQuestions.fromJson(Map<String, dynamic> json) {
    return CartingQuestions(
      cartingRule: json['cartingRule'],
      tips: json['tips'],
      safety: json['safety'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartingRule': cartingRule,
      'tips': tips,
      'safety': safety,
      '_id': id,
    };
  }
}

class CartingSection {
  final String title;
  final String description;
  final bool isActive;
  final String id;

  CartingSection({
    required this.title,
    required this.description,
    required this.isActive,
    required this.id,
  });

  factory CartingSection.fromJson(Map<String, dynamic> json) {
    return CartingSection(
      title: json['title'],
      description: json['description'],
      isActive: json['isActive'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isActive': isActive,
      '_id': id,
    };
  }
}
