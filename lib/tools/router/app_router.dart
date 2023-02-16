import 'dart:io';

import 'package:app_template/core/analytics/firebase_service.dart';
import 'package:app_template/tools/router/const.dart';
import 'package:app_template/tools/router/routes.dart';
import 'package:app_template/core/store/global.dart';
import 'package:app_template/tools/service/email_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    observers: <NavigatorObserver>[FirebaseService.observer],
    initialLocation: appRoutePath,
    routes: routes,
  );

  /// 默认过渡动画
  static CustomTransitionPage buildPageWithDefaultTransition<T>({
    required BuildContext context,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  /// 跳转到根路由
  static popToRoot({
    required BuildContext context,
  }) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// 跳转到某个路由
  static popToRouteName({
    required BuildContext context,
    required String name,
  }) {
    Navigator.popUntil(context, (route) {
      return route.settings.name == name;
    });
  }

  /// 展示底部弹窗
  static Future<Future> showCustomModalBottomSheet({
    required BuildContext context,
    required Widget child,
    bool enableDrag = true,
  }) async {
    return await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: enableDrag,
      context: context,
      builder: (BuildContext context) {
        return child;
      },
    );
  }

  /// 打开 web
  static Future<void> openWebController({
    required String url,
  }) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $uri';
    }
  }

  /// 打开商店页面
  static showReviewApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.openStoreListing(
        appStoreId: Global.iOSStoreId,
        microsoftStoreId: Global.androidStoreId,
      );
    }
  }

  /// 展示评分
  static showRateApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  /// 展示联系我们
  static showContactUs() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? deviceName;
    String? version;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceName = androidInfo.model;
      version = androidInfo.version.release;
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceName = iosInfo.localizedModel;
      version = iosInfo.systemVersion;
    }
    String baseString =
        'Hey there! Please describe the issue you are facing above the line';
    String lineString = '\n\n\n\n\n—————————————————————\n';
    final EmailService service = EmailService();
    service.sendEmail(
      Global.email,
      subject: 'Ayaya Support',
      body: '$baseString${lineString}Device: $deviceName\nVersion: $version',
    );
  }
}
