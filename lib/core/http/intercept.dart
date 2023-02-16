import 'package:app_template/core/http/apis.dart';
import 'package:app_template/core/http/error_handle.dart';
import 'package:app_template/core/utils/log.dart';
import 'package:app_template/providers/shared_preferences_service.dart';
import 'package:dio/dio.dart';

class ApiKeyInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['APIKEY'] = APIs.apiKey();
    super.onRequest(options, handler);
  }
}

class LoggingInterceptor extends Interceptor {
  late DateTime _startTime;
  late DateTime _endTime;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _startTime = DateTime.now();
    LogUtils.d('-------------------- Start --------------------');
    LogUtils.d('RequestMethod: ${options.method}');
    LogUtils.d('RequestHeaders:${options.headers}');
    LogUtils.d('RequestContentType: ${options.contentType}');
    LogUtils.d('RequestData: ${options.data.toString()}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    _endTime = DateTime.now();
    final int duration = _endTime.difference(_startTime).inMilliseconds;
    if (response.statusCode == ExceptionHandle.success) {
      LogUtils.d('ResponseCode: ${response.statusCode}');
    } else {
      LogUtils.e('ResponseCode: ${response.statusCode}');
    }
    LogUtils.d('-------------------- End: $duration 毫秒 --------------------');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    LogUtils.d('-------------------- Error --------------------');
    super.onError(err, handler);
  }
}
