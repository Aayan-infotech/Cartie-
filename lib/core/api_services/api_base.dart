import 'package:cartie/core/utills/constant.dart';
import 'package:cartie/core/utills/shared_pref_util.dart';


class ApiBase {
  String accessToken = '';
  String refreshToken = '';
  String userId = '';
  ApiBase() {
    accessToken = SharedPrefUtil.getValue(accessTokenPref, "") as String;
    refreshToken = SharedPrefUtil.getValue(refreshTokenPref, "") as String;
    userId = SharedPrefUtil.getValue(userIdPref, "") as String;
    print(accessToken);
  }
}
