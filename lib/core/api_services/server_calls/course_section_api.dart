import 'package:cartie/core/api_services/api_base.dart';
import 'package:cartie/core/api_services/call_helper.dart';

class CourseSectionApi extends ApiBase {
  Future<ApiResponseWithData<Map<String, dynamic>>> getCourseSection() async {
    return await CallHelper().getWithData<Map<String, dynamic>>(
      'api/user/video/getVideos',
      {}, // Default data in case of failure
    );
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> updateProgress(
      String locationId,
      String sectionId,
      String videoId,
      String watchedDuration) async {
    Map<String, dynamic> data = {
      "userId": userId,
      "locationId": locationId,
      "sectionId": sectionId,
      "videoId": videoId,
      "watchedDuration": watchedDuration
    };
    print(data);
    return await CallHelper().postWithData<Map<String, dynamic>>(
        'api/user/video/updateVideo',
        data,
        data // Default data in case of failure
        );
  }

  String formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    String minStr = '${minutes}m';
    String secStr = remainingSeconds.toString().padLeft(2, '0') + 's';

    return '$minStr $secStr';
  }
}
