class Course {
  final String id;
  final String admin;
  final String location;
  final List<Section> sections;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  Course({
    required this.id,
    required this.admin,
    required this.location,
    required this.sections,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory Course.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('Course JSON is null');
    }

    return Course(
      id: json['_id'] ?? '',
      admin: json['admin'] ?? '',
      location: json['locationId'] ?? '',
      sections: (json['sections'] as List<dynamic>?)
              ?.map((x) => Section.fromJson(x))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      version: json['__v'] is int ? json['__v'] : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'admin': admin,
      'location': location,
      'sections': sections.map((x) => x.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}

class Section {
  final int sectionNumber;
  final String title;
  final String durationTime;
  final List<Video> videos;
  final String id;

  Section({
    required this.sectionNumber,
    required this.title,
    required this.durationTime,
    required this.videos,
    required this.id,
  });

  factory Section.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('Section JSON is null');
    }

    final sectionId = json['_id'] ?? '';

    return Section(
      sectionNumber: json['sectionNumber'] is int ? json['sectionNumber'] : 0,
      title: json['title'] ?? '',
      durationTime: json['durationTime'] ?? '',
      videos: (json['videos'] as List<dynamic>?)
              ?.map((x) => Video.fromJson(x, sectionId: sectionId))
              .toList() ??
          [],
      id: sectionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionNumber': sectionNumber,
      'title': title,
      'durationTime': durationTime,
      'videos': videos.map((x) => x.toJson()).toList(),
      '_id': id,
    };
  }
}

class Video {
  final String title;
  final String url;
  final String description;
  final String durationTime;
  final int watchedDuration;
  final bool isActive;
  final String id;
  final String sectionId; // New field

  Video({
    required this.watchedDuration,
    required this.title,
    required this.url,
    required this.description,
    required this.durationTime,
    required this.isActive,
    required this.id,
    required this.sectionId,
  });

  factory Video.fromJson(Map<String, dynamic>? json,
      {required String sectionId}) {
    if (json == null) {
      throw ArgumentError('Video JSON is null');
    }

    return Video(
      watchedDuration: int.tryParse(json['watchedDuration'].toString()) ?? 0,
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      description: json['description'] ?? '',
      durationTime: json['durationTime'] ?? '',
      isActive: json['isActive'] is bool ? json['isActive'] : false,
      id: json['_id'] ?? '',
      sectionId: sectionId, // Assign sectionId here
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'description': description,
      'durationTime': durationTime,
      'isActive': isActive,
      '_id': id,
      'sectionId': sectionId, // Include sectionId in JSON
    };
  }
}
