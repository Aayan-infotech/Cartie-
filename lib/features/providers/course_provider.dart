import 'package:cartie/core/api_services/server_calls/course_section_api.dart';
import 'package:cartie/core/models/course_model.dart';
import 'package:flutter/foundation.dart';

class CourseProvider extends ChangeNotifier {
  final CourseSectionApi _api = CourseSectionApi();

  Course? _sections;
  bool _isLoading = false;

  Course get sections => _sections!;
  bool get isLoading => _isLoading;

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
