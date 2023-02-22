import 'package:app_template/core/http/dio_utils.dart';
import 'package:app_template/tools/log.dart';
import 'package:dio/dio.dart';

typedef Success<T> = Function(T data);
typedef Fail = Function(int code, String msg);

class HttpUtils {
  late DioUtils _dioUtils;

  HttpUtils initDio({
    required String baseUrl,
    int? connectTimeout,
    int? receiveTimeout,
    int? sendTimeout,
    List<Interceptor>? interceptors,
  }) {
    _dioUtils = _dioUtils.init(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      interceptors: interceptors,
    );
    return this;
  }

  void updateBaseUrl(String baseUrl) {
    _dioUtils.updateBaseUrl(baseUrl);
  }

  /// get 请求
  void get<T>(
    String url,
    Map<String, dynamic>? params, {
    CancelToken? cancelToken,
    Success? success,
    Fail? fail,
  }) {
    request(
      Method.get,
      url,
      params,
      cancelToken: cancelToken,
      success: success,
      fail: fail,
    );
  }

  /// post 请求
  void post<T>(
    String url,
    params, {
    CancelToken? cancelToken,
    Success? success,
    Fail? fail,
  }) {
    request(
      Method.post,
      url,
      params,
      cancelToken: cancelToken,
      success: success,
      fail: fail,
    );
  }

  /// _request 请求
  void request<T>(
    Method method,
    String url,
    params, {
    CancelToken? cancelToken,
    Success? success,
    Fail? fail,
  }) {
    LogUtils.d('---------- HttpUtils URL ----------');
    LogUtils.d(url);
    LogUtils.d('---------- HttpUtils params ----------');
    LogUtils.d(params);
    var data;
    var queryParameters;
    if (method == Method.get) {
      queryParameters = params;
    }
    if (method == Method.post) {
      data = params;
    }
    _dioUtils.request(method, url,
        data: data,
        cancelToken: cancelToken,
        queryParameters: queryParameters, onSuccess: (result) {
      LogUtils.d('---------- HttpUtils response ----------');
      LogUtils.d(result);
      success?.call(result);
    }, onError: (code, msg) {
      fail?.call(code, msg);
    });
  }
}
