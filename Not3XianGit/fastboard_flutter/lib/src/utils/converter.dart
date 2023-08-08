import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'convert_types.dart';

// 檔案轉換類型的列舉，包括靜態和動態
enum ConversionType {
  static,
  dynamic,
}

// 重試策略類別，用於控制重試次數
class RetryPolicy {
  RetryPolicy({
    this.maxAttempts = 3,
  });

  final int maxAttempts;

  int retryCount = 0;

  bool canRetry() {
    return retryCount < maxAttempts;
  }

  void inc() {
    retryCount++;
  }
}

// 對 ConversionType 的擴充，提供序列化功能
extension ConversionTypeExtensions on ConversionType {
  String serialize() {
    switch (this) {
      case ConversionType.static:
        return "static";
      case ConversionType.dynamic:
        return "dynamic";
    }
  }
}

// 對 String? 的擴充，提供轉換為 ConversionType 的功能
extension ConversionTypeStringExtensions on String? {
  ConversionType toConversionType() {
    var conversionTypeMap = <String?, ConversionType>{
      "static": ConversionType.static,
      "dynamic": ConversionType.dynamic,
    };
    return conversionTypeMap[this] ?? ConversionType.static;
  }
}

// 定義轉換進度回調函數
typedef ConvertProgressCallback = void Function(
    num progress, ConversionInfo info);
// 定義轉換完成回調函數
typedef ConvertFinishedCallback = void Function(ConversionInfo info);

// 轉換查詢類別，用於指定轉換任務的相關設定和回調函數
class ConversionQuery {
  const ConversionQuery({
    required this.taskUUID,
    required this.takeToken,
    required this.convertType,
    required this.region,
    this.onProgress,
    this.onFinished,
    this.interval = 1 * 1000,
    this.maxAttempts = 3,
  });

  final String taskUUID;

  final String takeToken;

  final String region;

  final ConversionType convertType;

  // 重試間隔時間（毫秒）
  final int interval;

  // 最大重試次數
  final int maxAttempts;

  final ConvertProgressCallback? onProgress;

  final ConvertFinishedCallback? onFinished;
}

// 進度回調函數的基類
abstract class ProgressCallback {}

// 轉換器類別，用於處理轉換任務的相關操作
class Converter {
  Converter._internal();

  static final Converter _instance = Converter._internal();

  static Converter get instance => _instance;

  var httpClient = HttpClient();

  // 開始查詢轉換任務的進度
  Future<ConversionInfo> startQuery(ConversionQuery query) async {
    Completer<ConversionInfo> completer = Completer();

    RetryPolicy retryPolicy = RetryPolicy(maxAttempts: query.maxAttempts);
    await Future.doWhile(() async {
      bool keepGoing = false;
      var info = await _requestQuery(query);
      if (info != null) {
        switch (info.status) {
          case ServerConvertState.notFound:
          case ServerConvertState.fail:
            completer.completeError("檔案未找到或轉換失敗");
            keepGoing = false;
            break;
          case ServerConvertState.finished:
            completer.complete(info);
            keepGoing = false;
            break;
          case ServerConvertState.waiting:
          case ServerConvertState.converting:
            keepGoing = retryPolicy.canRetry();
            break;
        }
      } else {
        keepGoing = retryPolicy.canRetry();
      }
      if (keepGoing) {
        await Future<void>.delayed(Duration(milliseconds: query.interval));
        retryPolicy.inc();
      } else {
        if (!retryPolicy.canRetry()) {
          completer.completeError("超時");
        }
      }
      return keepGoing;
    });
    return completer.future;
  }

  // 請求查詢轉換任務的狀態
  Future<ConversionInfo?> _requestQuery(ConversionQuery query) async {
    var queryUri = Uri(
      scheme: "https",
      host: "api.netless.link",
      path: "v5/services/conversion/tasks/${query.taskUUID}",
      queryParameters: {
        "type": query.convertType.serialize(),
      },
    );

    var request = await httpClient.getUrl(queryUri);
    request.headers.add("token", query.takeToken);
    request.headers.add("region", query.region);
    request.headers.add("Content-Type", "application/json");
    request.headers.add("Accept", "application/json");

    HttpClientResponse response = await request.close();
    if (response.statusCode == 200) {
      String responseBody = await response.transform(utf8.decoder).join();
      var json = jsonDecode(responseBody);
      return ConversionInfo.fromJson(json);
    } else {
      return null;
    }
  }
}
