import 'fast_region.dart';

//轉換相關

class InsertDocParams {
  InsertDocParams({
    required this.taskUUID,
    required this.taskToken,
    required this.dynamic,
    required this.title,
    this.region,
  });

  /// 檔案轉換任務的UUID。
  /// 您可以從「啟動檔案轉換」（POST）API呼叫成功後的回應內容中獲取UUID。
  final String taskUUID;

  /// 檔案轉換任務的任務令牌，
  /// 這個令牌必須與您用來啟動檔案轉換任務的任務令牌相同。
  final String taskToken;

  /// 子視窗的標題。
  final String title;

  /// 創建轉換時的檔案類型。
  /// 大多數情況下：
  ///   true：用於PPT、PPTX等。
  ///   false：用於DOC、PDF等。
  final bool dynamic;

  /// 創建轉換時的區域。更多資訊請參考 [FastRegion]。
  final FastRegion? region;
}
