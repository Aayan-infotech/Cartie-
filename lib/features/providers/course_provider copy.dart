import 'package:flutter/foundation.dart';
import 'package:cartie/core/api_services/server_calls/course_section_api.dart';
import 'package:cartie/core/models/course_model.dart';
import 'package:cartie/core/models/quiz_model.dart'; // Make sure this file exists

class CourseProvider extends ChangeNotifier {
  final CourseSectionApi _api = CourseSectionApi();

  Course? _sections;
  QuizSection? _quiz;
  bool _isLoading = false;
  bool _isQuizLoading = false;

  Course? get sections => _sections;
  QuizSection? get quiz => _quiz;
  bool get isLoading => _isLoading;
  bool get isQuizLoading => _isQuizLoading;
  final Map<String, QuizSection> _sectionQuizzes = {};
  final Set<String> _completedQuizzes = {};

  // Add these methods
  void markQuizCompleted(String sectionId) {
    _completedQuizzes.add(sectionId);
    notifyListeners();
  }

  bool isQuizCompleted(String sectionId) =>
      _completedQuizzes.contains(sectionId);

  QuizSection? getQuizForSection(String sectionId) =>
      _sectionQuizzes[sectionId];

  /// Fetch all course sections
  Future<void> fetchCourseSections() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.getCourseSection();
      if (response.success) {
        _sections = Course.fromJson(response.data['data'][0]);
        print("Course fetched successfully.");
      } else {
        print("Failed to fetch course: ${response.message}");
      }
    } catch (e) {
      print("Error while fetching course: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark a video as completed and check if section is completed
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

    final video = section.videos.firstWhere(
      (v) => v.id == videoId,
      orElse: () => throw Exception('Video not found'),
    );

    video.isCompleted = true;

    // Mark section as completed if all videos are done
    final allVideosCompleted = section.videos.every((v) => v.isCompleted);
    if (allVideosCompleted) {
      section.isSectionCompleted = true;
      await fetchQuiz(
        locationId: locationId,
        sectionId: sectionId,
        sectionNumber: section.sectionNumber,
      );
    }

    notifyListeners();
  }

  /// Update video watch progress
  Future<void> updateVideoProgress({
    required String locationId,
    required String sectionId,
    required String videoId,
    required String watchedDuration,
  }) async {
    try {
      final response = await _api.updateProgress(
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
      print("Error while updating video progress: $e");
    }
  }

  /// Fetch quiz/assessment data
  Future<void> fetchQuiz({
    required String locationId,
    required String sectionId,
    required int sectionNumber,
  }) async {
    _isQuizLoading = true;
    notifyListeners();

    try {
      final response =
          await _api.getAssisment(locationId, sectionId, sectionNumber);

      if (response.success) {
        final quizData = response.data['data'];
        _quiz = QuizSection.fromJson(quizData);

        _sectionQuizzes[sectionId] = QuizSection.fromJson(quizData);
        print("Quiz fetched: ${_quiz!.questions.length} questions loaded.");
      } else {
        print("Failed to fetch quiz: ${response.message}");
      }
    } catch (e) {
      print("Error while fetching quiz: $e");
    } finally {
      _isQuizLoading = false;
      notifyListeners();
    }
  }

  bool isSectionFullyCompleted(String sectionId) {
    final section = _sections?.sections.firstWhere(
      (s) => s.id == sectionId,
      orElse: () => null as Section,
    );
    if (section == null) return false;
    return section.isSectionCompleted &&
        (!_sectionQuizzes.containsKey(sectionId) ||
            _completedQuizzes.contains(sectionId));
  }

  /// Clear course and quiz data (optional helper)
  void clear() {
    _sections = null;
    _quiz = null;
    notifyListeners();
  }
}
