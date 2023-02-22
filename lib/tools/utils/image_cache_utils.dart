import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ImageCacheUtils {
  static Future<Uint8List?> cacheImage(String imagePath) async {
    return getNetworkImageData(imagePath);
  }

  static Future<bool> getFromMemory(String imagePath) async {
    final Directory cacheImagesDirectory = Directory(
        join((await getTemporaryDirectory()).path, cacheImageFolderName));
    if (cacheImagesDirectory.existsSync()) {
      final md5Key = keyToMd5(imagePath);
      final File cacheFlie = File(join(cacheImagesDirectory.path, md5Key));
      if (cacheFlie.existsSync()) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
