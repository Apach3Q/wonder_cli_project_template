import 'dart:async';
import 'dart:convert';

import 'package:app_template/core/http/apis.dart';
import 'package:app_template/core/http/dio_utils.dart';
import 'package:app_template/core/http/error_handle.dart';
import 'package:app_template/core/http/http_utils.dart';
import 'package:app_template/core/http/intercept.dart';
import 'package:app_template/tools/utils/image_cache_utils.dart';
import 'package:app_template/tools/utils/image_process_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:heic_to_jpg/heic_to_jpg.dart';

class WonderHttp {
  static late HttpUtils _http;
  static init() {
    _http = HttpUtils().initDio(
      baseUrl: APIs.baseUrl(),
      interceptors: [
        ApiKeyInterceptor(),
        LogInterceptor(),
      ],
    );
  }

  static Future<WonderImageHandleResult> uploadImage({
    required String path,
    CancelToken? cancelToken,
    int? quality,
  }) async {
    final Completer<WonderImageHandleResult> completer =
        Completer<WonderImageHandleResult>();
    String? imgPath = path;
    if (imgPath.contains('.heic')) {
      imgPath = await HeicToJpg.convert(imgPath);
    }
    if (imgPath == null) {
      completer.complete(WonderImageHandleResult.errorResult);
    } else {
      FormData formData = FormData.fromMap({
        "file": await ImageProcessUtils.compressImage(
          path: imgPath,
          quality: quality,
        ),
      });
      _retryAction(
        method: Method.post,
        baseUrl: APIs.baseUrlUploadImage(),
        url: APIs.uploadApi,
        params: formData,
        cancelToken: cancelToken,
        success: (final successResult) {
          String urlString = successResult;
          completer.complete(WonderImageHandleResult(
            httpResultType: WonderImageHandleResultType.success,
            bytes: null,
            url: urlString,
          ));
        },
        error: (WonderImageHandleResult result) {
          completer.complete(result);
        },
      );
    }
    return completer.future;
  }

  static Future<WonderImageHandleResult> clipImage({
    required String imageUrl,
    CancelToken? cancelToken,
  }) async {
    return await _mattingImage(
      imageUrl: imageUrl,
      mattingType: 6,
      cancelToken: cancelToken,
    );
  }

  static Future<WonderImageHandleResult> defaultCartoonImage({
    required String imageUrl,
    CancelToken? cancelToken,
  }) async {
    return await _mattingImage(
      imageUrl: imageUrl,
      mattingType: 11,
      cancelToken: cancelToken,
    );
  }

  static Future<WonderImageHandleResult> handleImageCartoon({
    required String imageUrl,
    required String cartoonType,
    CancelToken? cancelToken,
  }) async {
    Map<String, dynamic> params = {
      'cartoonType': cartoonType,
      'url': imageUrl,
      'outputFormat': 'jpg',
    };
    final Completer<WonderImageHandleResult> completer =
        Completer<WonderImageHandleResult>();
    _retryAction(
      method: Method.get,
      baseUrl: APIs.baseUrl(),
      url: APIs.cartoonApi,
      params: params,
      cancelToken: cancelToken,
      success: (final successResult) {
        Uint8List bytes =
            const Base64Decoder().convert(successResult['imageBase64']);
        String url = successResult['imageUrl'];
        completer.complete(WonderImageHandleResult(
          httpResultType: WonderImageHandleResultType.success,
          bytes: bytes,
          url: url,
        ));
      },
      error: (WonderImageHandleResult result) {
        completer.complete(result);
      },
    );
    return completer.future;
  }

  static Future<WonderImageHandleResult> handleSwapFace(
    String imageUrl,
    String target,
    CancelToken cancelToken,
  ) async {
    Map<String, dynamic> params = {
      'target': target,
      'src': imageUrl,
      'outputFormat': 'jpg',
    };
    final Completer<WonderImageHandleResult> completer =
        Completer<WonderImageHandleResult>();
    _retryAction(
      method: Method.get,
      baseUrl: APIs.baseUrl(),
      url: APIs.swapFace,
      params: params,
      cancelToken: cancelToken,
      success: (final successResult) async {
        String swapUrl = successResult;
        final fileInfo = await ImageCacheUtils.cacheImage(swapUrl);
        if (fileInfo != null) {
          completer.complete(WonderImageHandleResult(
            httpResultType: WonderImageHandleResultType.success,
            bytes: fileInfo,
            url: swapUrl,
          ));
        } else {
          completer.complete(WonderImageHandleResult.errorResult);
        }
      },
      error: (WonderImageHandleResult result) {
        completer.complete(result);
      },
    );
    return completer.future;
  }

  static Future<int?> text2ImageAsync({
    required String prompt,
    required CancelToken cancelToken,
    required String? imageUrl,
    required String? style,
    required Size? size,
  }) async {
    Map<String, dynamic> params = {
      'prompt': prompt,
    };
    if (imageUrl != null) {
      params['imageUrl'] = imageUrl;
    }
    if (style != null) {
      params['style'] = style;
    }
    if (size != null) {
      params['width'] = size.width.toInt();
      params['height'] = size.height.toInt();
    }
    final Completer<int?> completer = Completer<int?>();
    _retryAction(
      method: Method.post,
      baseUrl: APIs.baseUrl(),
      url: APIs.text2ImageAsyncApi,
      params: params,
      cancelToken: cancelToken,
      success: (final successResult) {
        completer.complete(successResult);
      },
      error: (WonderImageHandleResult result) {
        completer.complete(null);
      },
    );
    return completer.future;
  }

  static Future<WonderText2ImageResult> getText2ImageResult({
    required String taskId,
    required CancelToken cancelToken,
  }) async {
    Map<String, dynamic> params = {
      'taskId': taskId,
    };
    final Completer<WonderText2ImageResult> completer =
        Completer<WonderText2ImageResult>();

    _retryAction(
      method: Method.get,
      baseUrl: APIs.baseUrl(),
      url: APIs.getText2imageResultApi,
      params: params,
      cancelToken: cancelToken,
      success: (final successResult) {
        completer.complete(WonderText2ImageResult(
          httpResultType: WonderImageHandleResultType.success,
          json: successResult,
        ));
      },
      error: (WonderImageHandleResult result) {
        completer.complete(WonderText2ImageResult(
          httpResultType: result.httpResultType,
          json: null,
        ));
      },
    );
    return completer.future;
  }

  static Future<WonderImageHandleResult> _mattingImage({
    required String imageUrl,
    required int mattingType,
    CancelToken? cancelToken,
  }) async {
    Map<String, dynamic> params = {
      'mattingType': mattingType,
      'url': imageUrl,
      'outputFormat': 'jpg',
    };
    final Completer<WonderImageHandleResult> completer =
        Completer<WonderImageHandleResult>();
    _retryAction(
      method: Method.get,
      baseUrl: APIs.baseUrl(),
      url: APIs.mattingApi,
      params: params,
      cancelToken: cancelToken,
      success: (final successResult) {
        Uint8List bytes =
            const Base64Decoder().convert(successResult['imageBase64']);
        String url = successResult['imageUrl'];
        completer.complete(WonderImageHandleResult(
          httpResultType: WonderImageHandleResultType.success,
          bytes: bytes,
          url: url,
        ));
      },
      error: (WonderImageHandleResult result) {
        completer.complete(result);
      },
    );
    return completer.future;
  }

  static void _retryAction({
    required Method method,
    required String baseUrl,
    required String url,
    required params,
    required CancelToken? cancelToken,
    required Success? success,
    required void Function(WonderImageHandleResult) error,
  }) {
    int retryCount = 1;
    void requestAction() {
      _http.updateBaseUrl(baseUrl);
      _http.request(
        method,
        url,
        params,
        cancelToken: cancelToken,
        success: success,
        fail: (int code, String msg) {
          if (_codeIsTimeOut(code) && retryCount < 3) {
            retryCount += 1;
            requestAction();
          } else {
            _handleError(
              code,
              (type) {
                error(WonderImageHandleResult.errorWith(type));
              },
            );
          }
        },
      );
    }

    requestAction();
  }

  static _handleError(
    int code,
    void Function(WonderImageHandleResultType type) resultTypeCallback,
  ) {
    WonderImageHandleResultType errorType = WonderImageHandleResultType.error;
    if (code == ExceptionHandle.cancel_error) {
      errorType = WonderImageHandleResultType.interrupt;
    } else if (code == ExceptionHandle.no_face) {
      errorType = WonderImageHandleResultType.noFace;
    }
    resultTypeCallback(errorType);
  }

  static bool _codeIsTimeOut(int code) {
    return code == ExceptionHandle.send_timeout_error ||
        code == ExceptionHandle.connect_timeout_error ||
        code == ExceptionHandle.receive_timeout_error;
  }
}

class WonderImageHandleResult {
  final WonderImageHandleResultType httpResultType;
  final Uint8List? bytes;
  final String? url;

  static WonderImageHandleResult errorResult = WonderImageHandleResult(
    httpResultType: WonderImageHandleResultType.error,
    bytes: null,
    url: null,
  );

  static WonderImageHandleResult errorWith(WonderImageHandleResultType error) {
    return WonderImageHandleResult(
      httpResultType: error,
      bytes: null,
      url: null,
    );
  }

  WonderImageHandleResult({
    required this.httpResultType,
    required this.bytes,
    required this.url,
  });
}

enum WonderImageHandleResultType {
  success,
  error,
  noFace,
  interrupt,
}

class WonderText2ImageResult {
  final WonderImageHandleResultType httpResultType;
  final Map<String, dynamic>? json;

  WonderText2ImageResult({
    required this.httpResultType,
    required this.json,
  });
}
