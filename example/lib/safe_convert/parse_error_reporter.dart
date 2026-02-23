import 'package:flutter/foundation.dart';

/*
  // 1. main.dart 初始化异常拦截器
  ParseErrorReporter.onReport = (expectedType, invalidValue, stackTrace) {
    final errorMsg = 'JSON Parsing Error: Expected [$expectedType] but got [$invalidValue] of type ${invalidValue.runtimeType}';
    
    // 方案 A: 接入 Sentry (推荐)
    // Sentry.captureException(Exception(errorMsg), stackTrace: stackTrace);

    // 方案 B: 接入 Firebase Crashlytics
    // FirebaseCrashlytics.instance.recordError(Exception(errorMsg), stackTrace, reason: 'PHP API Format Error');

    // 方案 C: 本地日志打印 (开发时查看堆栈)
    debugPrint('🚨 $errorMsg\n$stackTrace');
  };

*/
class ParseErrorReporter {
  // 定义一个全局回调，方便在 main.dart 中注入第三方日志平台 (如 Sentry, Bugly)
  static void Function(
          String expectedType, dynamic invalidValue, StackTrace stackTrace)?
      onReport;

  // 内部调用的上报方法
  static void report(String expectedType, dynamic invalidValue) {
    if (onReport != null) {
      // 捕获当前的堆栈信息
      final stackTrace = StackTrace.current;
      onReport!(expectedType, invalidValue, stackTrace);
    } else {
      // 开发环境下，如果没有配置回调，直接在控制台打印警告
      debugPrint(
          '⚠️ [数据解析异常] 期望类型: $expectedType, 实际值: $invalidValue (${invalidValue.runtimeType})');
    }
  }
}
