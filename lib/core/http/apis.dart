import 'package:app_template/providers/shared_preferences_service.dart';

class APIs {
  static String _internalApiKey = 'ee027e0cf4dd446587758c0079c05f88';
  static String _abroadApiKey = '3dd99ac1afbc48b9892d6551ff8b4d0e';

  static String _internalUrl = 'https://picupapi.tukeli.net/';
  static String _abroadUrl = 'https://www.cutout.pro/';

  static String _abroadUploadImageUrl = 'https://restapi.cutout.pro/';
  static String _internalUploadImageUrl = 'http://47.99.178.15:8083/';

  static String mattingApi = 'api/v1/mattingByUrl';
  static String cartoonApi = 'api/v1/cartoonSelfieByUrl';
  static String uploadApi = 'oss/upload';
  static String swapFace = 'api/v1/faceSwapPic';
  static String text2ImageAsyncApi = 'api/v1/text2imageAsync';
  static String getText2imageResultApi = 'api/v1/getText2imageResult';

  static String baseUrl() {
    if (sharedPreferencesService.getIsInternalHost()) {
      return _internalUrl;
    } else {
      return _abroadUrl;
    }
  }

  static String baseUrlUploadImage() {
    if (sharedPreferencesService.getIsInternalHost()) {
      return _internalUploadImageUrl;
    } else {
      return _abroadUploadImageUrl;
    }
  }

  static String apiKey() {
    if (sharedPreferencesService.getIsInternalHost()) {
      return _internalApiKey;
    } else {
      return _abroadApiKey;
    }
  }
}
