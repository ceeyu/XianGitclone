import 'dart:ui';

import 'package:fastboard_flutter/fastboard_flutter.dart';

// 是白板房間的設定
/// [FastRoomOptions] 是白板房間的配置選項。
class FastRoomOptions {
  /// 由 Agora 發行的互動式白板專案的 App 識別符
  final String appId;

  /// 房間的 UUID，即房間的唯一識別符
  final String uuid;

  /// 用於用戶驗證的房間令牌
  final String token;

  /// 以字符串格式表示的用戶唯一識別符
  final String uid;

  /// 數據中心，必須與創建白板房間時選擇的數據中心相同
  final FastRegion fastRegion;

  /// 用戶是否以互動模式加入白板房間：
  /// true：以互動模式加入白板房間，即具有讀寫權限。
  /// false：以訂閱模式加入白板房間，即只具有只讀權限。
  final bool writable;

  /// fastboard 對多窗口有很強的依賴性。它支持一些像 insertDoc、insertVideo 等的 API。
  final bool useMultiViews;

  /// 多窗口本地顯示的內容高度寬度比，默認為 9:16
  final double? containerSizeRatio;

  /// 傳輸到多窗口的 CSS
  /// 例如：
  /// {
  ///   "top": "40",
  ///   "left": "40",
  ///   "right": "40",
  ///   "bottom": "40",
  ///   "position": "fixed",
  /// }
  final Map<String, String>? collectorStyles;

  FastRoomOptions({
    required this.appId,
    required this.uuid,
    required this.token,
    required this.uid,
    required this.fastRegion,
    this.writable = true,
    this.useMultiViews = true,
    this.containerSizeRatio,
    this.collectorStyles,
  });
}

extension FastRoomOptionsExtension on FastRoomOptions {
  WhiteOptions genWhiteOptions({
    Color? backgroundColor,
  }) {
    return WhiteOptions(
      appIdentifier: appId,
      useMultiViews: useMultiViews,
      backgroundColor: backgroundColor,
    );
  }

  RoomOptions genRoomOptions({
    double? ratioWhenNull,
    WindowPrefersColorScheme? prefersColorScheme,
  }) {
    return RoomOptions(
      uuid: uuid,
      roomToken: token,
      uid: uid,
      isWritable: writable,
      region: fastRegion.toRegion(),
      disableNewPencil: false,
      windowParams: WindowParams(
        containerSizeRatio: containerSizeRatio ?? ratioWhenNull ?? 9 / 16,
        prefersColorScheme: prefersColorScheme,
        chessboard: false,
        collectorStyles: collectorStyles ??
            {
              "right": "40",
              "bottom": "40",
              "position": "fixed",
            },
      ),
    );
  }
}
