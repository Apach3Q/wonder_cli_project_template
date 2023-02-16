import 'package:app_template/core/http/apis.dart';
import 'package:app_template/core/http/http_utils.dart';
import 'package:app_template/core/http/intercept.dart';
import 'package:dio/dio.dart';

class Http1 {
  static late HttpUtils http;
  static init() {
    http = HttpUtils().initDio(
      baseUrl: 'baseUrl',
      interceptors: [
        ApiKeyInterceptor(),
        LogInterceptor(),
      ],
    );
  }
}

class Http2 {
  static late HttpUtils http;
  static init() {
    http = HttpUtils().initDio(
      baseUrl: 'baseUrl',
      interceptors: [
        ApiKeyInterceptor(),
        LogInterceptor(),
      ],
    );
  }
}
