import 'dart:async';

import 'package:app_template/app/init/default_app.dart';
import 'package:flutter/material.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;

class AppInit {
  static void run() {
    //捕获异常
    catchException(() => DefaultApp.run());
  }

  ///异常捕获处理
  static void catchException<T>(T callback()) {
    //捕获异常的回调
    FlutterError.onError = (FlutterErrorDetails details) {
      reportErrorAndLog(details);
    };
    FlutterError.demangleStackTrace = (StackTrace stack) {
      if (stack is stack_trace.Trace) return stack.vmTrace;
      if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
      return stack;
    };
    runZonedGuarded<Future<void>>(() async {
      callback();
    }, (error, stack) {
      var details = makeDetails(error, stack);
      reportErrorAndLog(details);
    }, zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        collectLog(parent, zone, line); // 收集日志
      },
    ));
  }

  //日志拦截, 收集日志
  static void collectLog(ZoneDelegate parent, Zone zone, String line) {
    parent.print(zone, "日志拦截: $line");
  }

  //上报错误和日志逻辑
  static void reportErrorAndLog(FlutterErrorDetails details) {
    print(details);
  }

  // 构建错误信息
  static FlutterErrorDetails makeDetails(Object obj, StackTrace stack) {
    return FlutterErrorDetails(stack: stack, exception: obj);
  }
}
