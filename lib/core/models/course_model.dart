// class Course {
//   final String id;
//   final String location;
//   final List<Section> sections;
//   final String totalDuration;
//   final int totalVideos;

//   Course({
//     required this.id,
//     required this.location,
//     required this.sections,
//     required this.totalDuration,
//     required this.totalVideos,
//   });

//   factory Course.fromJson(Map<String, dynamic>? json) {
//     if (json == null) throw ArgumentError('Course JSON is null');

//     return Course(
//       id: json['_id'] ?? '',
//       location: json['locationId'] ?? '',
//       totalDuration: json['totalDuration'] ?? '',
//       totalVideos: json['totalVideos'] ?? 0,
//       sections: (json['sections'] as List<dynamic>?)
//               ?.map((x) => Section.fromJson(x))
//               .toList() ??
//           [],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'locationId': location,
//       'totalDuration': totalDuration,
//       'totalVideos': totalVideos,
//       'sections': sections.map((x) => x.toJson()).toList(),
//     };
//   }
// }

// class Section {
//   final int sectionNumber;
//   final String title;
//   final String durationTime;
//    bool isSectionCompleted;
//   final List<Video> videos;
//   final String id;

//   Section({
//     required this.sectionNumber,
//     required this.title,
//     required this.durationTime,
//     required this.isSectionCompleted,
//     required this.videos,
//     required this.id,
//   });

//   factory Section.fromJson(Map<String, dynamic>? json) {
//     if (json == null) throw ArgumentError('Section JSON is null');

//     final sectionId = json['_id'] ?? '';

//     return Section(
//       sectionNumber: json['sectionNumber'] ?? 0,
//       title: json['title'] ?? '',
//       durationTime: json['durationTime'] ?? '',
//       isSectionCompleted: json['isSectionCompleted'] ?? false,
//       videos: (json['videos'] as List<dynamic>?)
//               ?.map((x) => Video.fromJson(x, sectionId: sectionId))
//               .toList() ??
//           [],
//       id: sectionId,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'sectionNumber': sectionNumber,
//       'title': title,
//       'durationTime': durationTime,
//       'isSectionCompleted': isSectionCompleted,
//       'videos': videos.map((x) => x.toJson()).toList(),
//       '_id': id,
//     };
//   }
// }

// class Video {
//   final String title;
//   final String url;
//   final String description;
//   final String durationTime;
//    int watchedDuration;
//   final bool isActive;
//    bool isCompleted;
//   final String id;
//   final String sectionId;

//   Video({
//     required this.title,
//     required this.url,
//     required this.description,
//     required this.durationTime,
//     required this.watchedDuration,
//     required this.isActive,
//     required this.isCompleted,
//     required this.id,
//     required this.sectionId,
//   });

//   factory Video.fromJson(Map<String, dynamic>? json,
//       {required String sectionId}) {
//     if (json == null) throw ArgumentError('Video JSON is null');

//     return Video(
//       title: json['title'] ?? '',
//       url: json['url'] ?? '',
//       description: json['description'] ?? '',
//       durationTime: json['durationTime'] ?? '',
//       watchedDuration: int.tryParse(json['watchedDuration'].toString()) ?? 0,
//       isActive: json['isActive'] ?? false,
//       isCompleted: json['isCompleted'] ?? false,
//       id: json['_id'] ?? '',
//       sectionId: sectionId,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'title': title,
//       'url': url,
//       'description': description,
//       'durationTime': durationTime,
//       'watchedDuration': watchedDuration,
//       'isActive': isActive,
//       'isCompleted': isCompleted,
//       '_id': id,
//       'sectionId': sectionId,
//     };
//   }
// }
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
    try {
      return Course(
        id: json?['_id']?.toString() ?? '',
        location: json?['locationId']?.toString() ?? '',
        totalDuration: json?['totalDuration']?.toString() ?? '',
        totalVideos: int.tryParse(json?['totalVideos']?.toString() ?? '') ?? 0,
        sections: (json?['sections'] as List<dynamic>?)
                ?.map((x) => Section.fromJson(x))
                .toList() ??
            [],
      );
    } catch (e) {
      return Course(
        id: '',
        location: '',
        totalDuration: '',
        totalVideos: 0,
        sections: [],
      );
    }
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
  final Test test;
  final List<Video> videos;
  final String id;

  Section({
    required this.sectionNumber,
    required this.title,
    required this.durationTime,
    required this.isSectionCompleted,
    required this.test,
    required this.videos,
    required this.id,
  });

  factory Section.fromJson(Map<String, dynamic>? json) {
    try {
      final sectionId = json?['_id']?.toString() ?? '';
      return Section(
        sectionNumber:
            int.tryParse(json?['sectionNumber']?.toString() ?? '') ?? 0,
        title: json?['title']?.toString() ?? '',
        durationTime: json?['durationTime']?.toString() ?? '',
        isSectionCompleted:
            json?['isSectionCompleted']?.toString() == 'true' ? true : false,
        test: Test.fromJson(json?['test']),
        videos: (json?['videos'] as List<dynamic>?)
                ?.map((x) => Video.fromJson(x, sectionId: sectionId))
                .toList() ??
            [],
        id: sectionId,
      );
    } catch (e) {
      return Section(
        sectionNumber: 0,
        title: '',
        durationTime: '',
        isSectionCompleted: false,
        test: Test(isSectionCompleted: false, nextSectionUnlocked: false),
        videos: [],
        id: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionNumber': sectionNumber,
      'title': title,
      'durationTime': durationTime,
      'isSectionCompleted': isSectionCompleted,
      'test': test.toJson(),
      'videos': videos.map((x) => x.toJson()).toList(),
      '_id': id,
    };
  }
}

class Test {
  final bool isSectionCompleted;
  final bool nextSectionUnlocked;

  Test({
    required this.isSectionCompleted,
    required this.nextSectionUnlocked,
  });

  factory Test.fromJson(Map<String, dynamic>? json) {
    try {
      return Test(
        isSectionCompleted:
            json?['isSectionCompleted']?.toString() == 'true' ? true : false,
        nextSectionUnlocked:
            json?['nextSectionUnlocked']?.toString() == 'true' ? true : false,
      );
    } catch (e) {
      return Test(isSectionCompleted: false, nextSectionUnlocked: false);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'isSectionCompleted': isSectionCompleted,
      'nextSectionUnlocked': nextSectionUnlocked,
    };
  }
}

class Video {
  final String title;
  final String url;
  final String description;
  final String durationTime;
  int watchedDuration;
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
    try {
      return Video(
        title: json?['title']?.toString() ?? '',
        url: json?['url']?.toString() ?? '',
        description: json?['description']?.toString() ?? '',
        durationTime: json?['durationTime']?.toString() ?? '',
        watchedDuration:
            int.tryParse(json?['watchedDuration']?.toString() ?? '') ?? 0,
        isActive: json?['isActive']?.toString() == 'true' ? true : false,
        isCompleted: json?['isCompleted']?.toString() == 'true' ? true : false,
        id: json?['_id']?.toString() ?? '',
        sectionId: sectionId,
      );
    } catch (e) {
      return Video(
        title: '',
        url: '',
        description: '',
        durationTime: '',
        watchedDuration: 0,
        isActive: false,
        isCompleted: false,
        id: '',
        sectionId: sectionId,
      );
    }
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
