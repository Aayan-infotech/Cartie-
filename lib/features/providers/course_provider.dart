import 'package:cartie/core/api_services/server_calls/course_section_api.dart';
import 'package:cartie/core/models/course_model.dart';
import 'package:cartie/core/models/quiz_model.dart';
import 'package:flutter/foundation.dart';

class CourseProvider extends ChangeNotifier {
  final CourseSectionApi _api = CourseSectionApi();

  Course? _sections;
  bool _isLoading = false;

  Course get sections => _sections!;
  bool get isLoading => _isLoading;

  /// Fetch quiz/assessment data
  QuizSection? quiz;

  ///
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
        final quizData = response.data['data'][0];
        quiz = QuizSection.fromJson(quizData);

        //_sectionQuizzes[sectionId] = QuizSection.fromJson(quizData);
        print("Quiz fetched: ${quiz!.questions.length} questions loaded.");
      } else {
        print("Failed to fetch quiz: ${response.message}");
      }
    } catch (e) {
      print("Error while fetching quiz: $e");
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
      // section.isSectionCompleted = true;
    }

    notifyListeners();
  }

  Future<void> fetchCourseSections() async {
    _isLoading = true;
    notifyListeners();

    try {
      var response = await _api.getCourseSection();
      if (response.success) {
        _sections = Course.fromJson(response.data['data'][0]);
        print(_sections);
      }
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ NEW METHOD TO CALL updateProgress
  Future<void> updateVideoProgress({
    required String locationId,
    required String sectionId,
    required String videoId,
    required String watchedDuration,
  }) async {
    try {
      var response = await _api.updateProgress(
        locationId,
        sectionId,
        videoId,
        watchedDuration,
      );

      if (response.success) {
        print("Video progress updated successfully.");
      } else {
        print("Failed to update progress: ${response.message}");
      }
    } catch (e) {
      print("Error while updating progress: $e");
    }
  }
}
