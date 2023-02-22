import 'dart:convert';
import 'dart:io';
import 'package:app_template/core/http/error_handle.dart';
import 'package:app_template/tools/utils/log_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

int _connectTimeout = 15000; // 15s
int _receiveTimeout = 15000;
int _sendTimeout = 15000;

typedef NetSuccessCallback<T> = Function(T data);
typedef NetSuccessListCallback<T> = Function(List<T> data);
typedef NetErrorCallback = Function(int code, String msg);

class DioUtils {
  List<Interceptor> _interceptors = [];
  late Dio _dio;

  DioUtils init({
    required String baseUrl,
    int? connectTimeout,
    int? receiveTimeout,
    int? sendTimeout,
    List<Interceptor>? interceptors,
  }) {
    final BaseOptions options = BaseOptions(
      responseType: ResponseType.json,
      validateStatus: (status) {
        return true;
      },
      baseUrl: baseUrl,
      headers: _httpHeaders,
      connectTimeout: Duration(milliseconds: connectTimeout ?? _connectTimeout),
      receiveTimeout: Duration(milliseconds: receiveTimeout ?? _receiveTimeout),
      sendTimeout: Duration(milliseconds: sendTimeout ?? _sendTimeout),
    );
    _dio = Dio(options);
    (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
    void addInterceptor(Interceptor interceptor) {
      _dio.interceptors.add(interceptor);
    }

    _interceptors.forEach(addInterceptor);
    return this;
  }

  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  Future request<T>(
    Method method,
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    NetSuccessCallback? onSuccess,
    NetErrorCallback? onError,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        _onError(ExceptionHandle.net_error, '网络异常，请检查你的网络！', onError);
        return;
      }
      final Response response = await _dio.request<T>(
        url,
        data: data,
        queryParameters: queryParameters,
        options: _checkOptions(MethodValues[method], options),
        cancelToken: cancelToken,
      );
      if (response.statusCode == ExceptionHandle.success) {
        final data = response.data;
        final resultCode = data['code'];
        final resultData = data['data'];
        if (resultCode == ExceptionHandle.result_success) {
          onSuccess?.call(resultData);
        } else if (resultCode == ExceptionHandle.no_face) {
          _onError(resultCode, 'no face', onError);
        } else {
          _onError(resultCode, resultData, onError);
        }
      } else {
        _onError(ExceptionHandle.net_error, '网络异常，请检查你的网络！', onError);
      }
    } on DioError catch (e) {
      _cancelLogPrint(e, url);
      final NetError error = ExceptionHandle.handleException(e);
      _onError(error.code, error.msg, onError);
    }
  }
}

Options _checkOptions(String? method, Options? options) {
  options ??= Options();
  options.method = method;
  return options;
}

void _cancelLogPrint(dynamic e, String url) {
  if (e is DioError && CancelToken.isCancel(e)) {
    LogUtils.e('取消请求接口： $url');
  }
}

void _onError(int? code, String msg, NetErrorCallback? onError) {
  if (code == null) {
    code = ExceptionHandle.unknown_error;
    msg = '未知异常';
  }
  LogUtils.e('接口请求异常： code: $code, msg: $msg');
  onError?.call(code, msg);
}

/// 自定义Header
Map<String, dynamic> _httpHeaders = {
  'Accept': 'application/json,*/*',
  'Content-Type': 'application/json',
};

Map<String, dynamic> parseData(String data) {
  return json.decode(data) as Map<String, dynamic>;
}

enum Method { get, post, put, patch, delete, head }

/// 使用：MethodValues[Method.post]
const MethodValues = {
  Method.get: 'get',
  Method.post: 'post',
  Method.delete: 'delete',
  Method.put: 'put',
  Method.patch: 'patch',
  Method.head: 'head',
};
