import 'package:app_template/tools/utils/log_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageProcessUtils {
  static Future<dynamic> compressImage({
    required String path,
    int? quality,
  }) async {
    var preProcessStart = DateTime.now().millisecondsSinceEpoch;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    // 分割参数(带参数不能保存到本地)
    var split = name.split("?");
    name = split[0];
    var file = await MultipartFile.fromFile(path, filename: name);
    LogUtils.d('原图大小-->>>${_getPrintSize(file.length)}');

    final result = await FlutterImageCompress.compressWithFile(
      path,
      quality: quality ?? 95,
      format: CompressFormat.jpeg,
    );
    if (result != null) {
      file = MultipartFile.fromBytes(result, filename: name);
    }
    LogUtils.d('压缩后大小-->>>${_getPrintSize(file.length)}');
    var endProcessEnd = DateTime.now().millisecondsSinceEpoch;
    LogUtils.d('压缩时间 ${endProcessEnd - preProcessStart}');
    return file;
  }

  static String _getPrintSize(limit) {
    String size = "";
    //内存转换
    if (limit < 0.1 * 1024) {
      //小于0.1KB，则转化成B
      size = limit.toString();
      size = "${size.substring(0, size.indexOf(".") + 3)}  B";
    } else if (limit < 0.1 * 1024 * 1024) {
      //小于0.1MB，则转化成KB
      size = (limit / 1024).toString();
      size = "${size.substring(0, size.indexOf(".") + 3)}  KB";
    } else if (limit < 0.1 * 1024 * 1024 * 1024) {
      //小于0.1GB，则转化成MB
      size = (limit / (1024 * 1024)).toString();
      size = "${size.substring(0, size.indexOf(".") + 3)}  MB";
    } else {
      //其他转化成GB
      size = (limit / (1024 * 1024 * 1024)).toString();
      size = "${size.substring(0, size.indexOf(".") + 3)}  GB";
    }
    return size;
  }
}
