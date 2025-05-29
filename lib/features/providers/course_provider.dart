import 'dart:async';

import 'package:cartie/core/api_services/call_helper.dart';
import 'package:cartie/core/api_services/server_calls/course_section_api.dart';
import 'package:cartie/core/models/course_model.dart';
import 'package:cartie/core/models/question_submition.dart';
import 'package:cartie/core/models/quiz_model.dart';
import 'package:flutter/foundation.dart';

class CourseProvider extends ChangeNotifier {
  final CourseSectionApi _api = CourseSectionApi();

  Course? _sections;
  bool _isLoading = false;

  Course get sections => _sections!;
  bool get isLoading => _isLoading;
  bool isPaused = false;

  /// Fetch quiz/assessment data
  QuizSection? quiz = QuizSection(sectionId: '', questions: []);
  int _elapsedSeconds = 0;
  bool _assessmentInProgress = false;
  Timer? _timer;

  int get elapsedSeconds => _elapsedSeconds;
  bool get assessmentInProgress => _assessmentInProgress;

  void startAssessment() {
    _elapsedSeconds = 0;
    _assessmentInProgress = true;
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
    });
  }

  void pauseAssessment() {
    _timer?.cancel();
    notifyListeners();
  }

  void resumeAssessment() {
    if (_assessmentInProgress) _startTimer();
  }

  void completeAssessment() {
    _timer?.cancel();
    _assessmentInProgress = false;
    _elapsedSeconds = 0;
    notifyListeners();
  }

  Future<void> fetchQuiz({
    required String locationId,
    required String sectionId,
    required int sectionNumber,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response =
          await _api.getAssisment(locationId, sectionId, sectionNumber);

      if (response.success) {
        if (response.data['data'] != null &&
            response.data['data'] is List &&
            response.data['data'].isNotEmpty) {
          final quizData = response.data['data'][0];
          // Use quizData
          quiz = QuizSection.fromJson(quizData);
        } else {
          quiz = QuizSection(sectionId: '', questions: []);
          // Handle empty or invalid data case
        }
        // final quizData = response.data['data'][0];

        // //_sectionQuizzes[sectionId] = QuizSection.fromJson(quizData);
        // print("Quiz fetched: ${quiz!.questions.length} questions loaded.");
      } else {
        if (kDebugMode) {
          print("Failed to fetch quiz: ${response.message}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error while fetching quiz: $e");
      }
    } finally {
      _isLoading = false;
      // _isQuizLoading = false;
      notifyListeners();
    }
  }

  Future<void> markVideoCompleted({
    required String locationId,
    required String sectionId,
    required String videoId,
  }) async {
    final course = _sections;
    if (course == null) return;

    final section = course.sections.firstWhere(
      (s) => s.id == sectionId,
      orElse: () => throw Exception('Section not found'),
    );

    Video video = section.videos.firstWhere(
      (v) => v.id == videoId,
      orElse: () => throw Exception('Video not found'),
    );

    video.isCompleted = true;

    // Check if all videos in section are completed
    final allVideosCompleted = section.videos.every((v) => v.isCompleted);
    if (allVideosCompleted) {
      section.isSectionCompleted = true;
    }

    notifyListeners();
  }

  // Future<void> markVideoCompleted({
  //   required String locationId,
  //   required String sectionId,
  //   required String videoId,
  // }) async {
  //   final course = _sections;
  //   if (course == null) return;

  //   final section = course.sections.firstWhere(
  //     (s) => s.id == sectionId,
  //     orElse: () => throw Exception('Section not found'),
  //   );

  //   Video video = section.videos.firstWhere(
  //     (v) => v.id == videoId,
  //     orElse: () => throw Exception('Video not found'),
  //   );

  //   video.isCompleted = true;

  //   // Check if all videos in section are completed
  //   final allVideosCompleted = section.videos.every((v) => v.isCompleted);
  //   if (allVideosCompleted) {
  //     section.isSectionCompleted = true;
  //   }

  //   notifyListeners();
  // }

  Future<void> fetchCourseSections() async {
    _isLoading = true;
    notifyListeners();

    try {
      var response = await _api.getCourseSection();
      if (response.success) {
        _sections = Course.fromJson(response.data['data'][0]);
      } else {
        _sections = Course(
            id: '',
            location: '',
            sections: [],
            totalDuration: '12',
            totalVideos: 0);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ApiResponseWithData> submitQuiz(
      QuestionSubmission question_submition) async {
    var response = await _api.submitQuiz(question_submition);
    print(response);
    return response;
  }

  // ✅ NEW METHOD TO CALL updateProgress
 Future<void> updateVideoProgress({
    required String locationId,
    required String sectionId,
    required String videoId,
    required String watchedDuration,
  }) async {
    try {
      final course = _sections;
      if (course == null) return;

      final section = course.sections.firstWhere(
        (s) => s.id == sectionId,
        orElse: () => throw Exception('Section not found'),
      );

      final video = section.videos.firstWhere(
        (v) => v.id == videoId,
        orElse: () => throw Exception('Video not found'),
      );

      // Update local state first
      video.watchedDuration = int.tryParse(watchedDuration) ?? 0;

      // Check if video should be marked completed
      if (video.watchedDuration >= video.watchedDuration && !video.isCompleted) {
        await markVideoCompleted(
          locationId: locationId,
          sectionId: sectionId,
          videoId: videoId,
        );
      }

      // Update backend
      final response = await _api.updateProgress(
        locationId,
        sectionId,
        videoId,
        watchedDuration,
      );

      if (!response.success) {
        print("Failed to update progress: ${response.message}");
      }
    } catch (e) {
      print("Error updating video progress: $e");
    }
  }

}
