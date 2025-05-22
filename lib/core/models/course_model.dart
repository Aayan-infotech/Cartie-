class Course {
  final String id;
  final String location;
  final List<Section> sections;
  final String totalDuration;
  final int totalVideos;

  Course({
    required this.id,
    required this.location,
    required this.sections,
    required this.totalDuration,
    required this.totalVideos,
  });

  factory Course.fromJson(Map<String, dynamic>? json) {
    if (json == null) throw ArgumentError('Course JSON is null');

    return Course(
      id: json['_id'] ?? '',
      location: json['locationId'] ?? '',
      totalDuration: json['totalDuration'] ?? '',
      totalVideos: json['totalVideos'] ?? 0,
      sections: (json['sections'] as List<dynamic>?)
              ?.map((x) => Section.fromJson(x))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'locationId': location,
      'totalDuration': totalDuration,
      'totalVideos': totalVideos,
      'sections': sections.map((x) => x.toJson()).toList(),
    };
  }
}

class Section {
  final int sectionNumber;
  final String title;
  final String durationTime;
   bool isSectionCompleted;
  final List<Video> videos;
  final String id;

  Section({
    required this.sectionNumber,
    required this.title,
    required this.durationTime,
    required this.isSectionCompleted,
    required this.videos,
    required this.id,
  });

  factory Section.fromJson(Map<String, dynamic>? json) {
    if (json == null) throw ArgumentError('Section JSON is null');

    final sectionId = json['_id'] ?? '';

    return Section(
      sectionNumber: json['sectionNumber'] ?? 0,
      title: json['title'] ?? '',
      durationTime: json['durationTime'] ?? '',
      isSectionCompleted: json['isSectionCompleted'] ?? false,
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
      'isSectionCompleted': isSectionCompleted,
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
   bool isCompleted;
  final String id;
  final String sectionId;

  Video({
    required this.title,
    required this.url,
    required this.description,
    required this.durationTime,
    required this.watchedDuration,
    required this.isActive,
    required this.isCompleted,
    required this.id,
    required this.sectionId,
  });

  factory Video.fromJson(Map<String, dynamic>? json,
      {required String sectionId}) {
    if (json == null) throw ArgumentError('Video JSON is null');

    return Video(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      description: json['description'] ?? '',
      durationTime: json['durationTime'] ?? '',
      watchedDuration: int.tryParse(json['watchedDuration'].toString()) ?? 0,
      isActive: json['isActive'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
      id: json['_id'] ?? '',
      sectionId: sectionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'description': description,
      'durationTime': durationTime,
      'watchedDuration': watchedDuration,
      'isActive': isActive,
      'isCompleted': isCompleted,
      '_id': id,
      'sectionId': sectionId,
    };
  }
}
