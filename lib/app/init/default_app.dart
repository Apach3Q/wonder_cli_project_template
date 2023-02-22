import 'dart:io';

import 'package:app_template/core/analytics/firebase_service.dart';
import 'package:app_template/core/http/api_ping.dart';
import 'package:app_template/tools/utils/log_utils.dart';
import 'package:app_template/tools/router/app_router.dart';
import 'package:app_template/generated/l10n.dart';
import 'package:app_template/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DefaultApp {
  static void run() {
    _initFirst().then(
      (value) => runApp(
        UncontrolledProviderScope(
          container: Providers.instance.providerContainer,
          child: MyApp(),
        ),
      ),
    );
    _initApp();
  }

  static Future<void> _initFirst() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    LogUtils.init(tag: '', isDebug: true, maxLen: 128000); // todo: tag
    await FirebaseService.initialize();
    await _initializeTensorFlow();
    if (Platform.isIOS) {
      _registiOSWidget();
    }
    await Providers.instance.initialized();
  }

  /// 程序初始化操作
  static void _initApp() {
    ApiPing.init();
  }

  static Future<void> _initializeTensorFlow() async {}

  static void _registiOSWidget() {}
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 667),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp.router(
          routeInformationProvider: AppRouter.router.routeInformationProvider,
          routeInformationParser: AppRouter.router.routeInformationParser,
          routerDelegate: AppRouter.router.routerDelegate,
          title: '', // todo
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          localeResolutionCallback: (locale, supportLocales) {
            if (locale != null) {
              // Global.currentLocale = locale;
              // S.load(Global.currentLocale);
            }
            // 中文 简繁体处理
            if (locale?.languageCode == 'zh') {
              // zh-CN：地区限制匹配规范，表示用在中国大陆区域的中文。
              // 包括各种大方言、小方言、繁体、简体等等都可以被匹配到。
              if (locale?.scriptCode == 'Hant') {
                // zh-Hant和zh-CHT相同相对应;
                return const Locale('zh', 'HK'); //繁体
              } else {
                // zh-Hans：语言限制匹配规范，表示简体中文
                return const Locale('zh', 'CN'); //简体
              }
            }
            return null;
          },
          builder: EasyLoading.init(
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child ?? Container(),
              );
            },
          ),
        );
      },
    );
  }
}
