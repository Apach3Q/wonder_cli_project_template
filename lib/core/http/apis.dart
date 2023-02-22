import 'package:app_template/core/store/shared_preferences_service.dart';

class APIs {
  static String _internalApiKey = ''; // todo: api key
  static String _abroadApiKey = '';

  static String _internalUrl = 'https://picupapi.tukeli.net/';
  static String _abroadUrl = 'https://restapi.cutout.pro/';

  static String _internalUploadImageUrl = 'http://47.99.178.15:8083/';
  static String _abroadUploadImageUrl = 'https://restapi.cutout.pro/';

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
