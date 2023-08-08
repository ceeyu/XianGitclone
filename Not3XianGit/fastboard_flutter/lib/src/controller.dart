import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:whiteboard_sdk_flutter/whiteboard_sdk_flutter.dart';

import 'fastboard.dart';
import 'types/types.dart';
import 'utils/converter.dart';

/// 控制 [FastRoomView] 的類別。選項
///
/// 可以通過設定 [FastRoomView.onFastRoomCreated] 回呼函式，來獲得 [FastRoomController] 的實例。
class FastRoomController extends ValueNotifier<FastRoomValue> {
  FastRoomController(this.fastRoomOptions)
      : super(FastRoomValue.uninitialized(fastRoomOptions.writable)) {
    containerSizeRatio = fastRoomOptions.containerSizeRatio;
  }

  /// whiteboard_flutter 的 [WhiteSdk] 實例，導出以供特定使用。
  WhiteSdk? whiteSdk;

  /// whiteboard_flutter 的 [WhiteRoom] 實例，導出以供特定使用。
  WhiteRoom? whiteRoom;

  FastRoomOptions fastRoomOptions;
  double? containerSizeRatio;

  num zoomScaleDefault = 1;
  Size? roomLayoutSize;
  bool? useDarkTheme;

  double? get ratioWhenNull {
    if (roomLayoutSize == null) {
      return null;
    }
    return roomLayoutSize!.height / roomLayoutSize!.width;
  }

  final StreamController<FastRoomEvent> _fastEventStreamController =
      StreamController<FastRoomEvent>.broadcast();

  /// 快速房間的覆蓋物（overlay）發生變化的事件流。
  /// 覆蓋物是房間的擴展操作視圖。
  Stream<OverlayChangedEvent> onOverlayChanged() {
    return _fastEventStreamController.stream.whereType<OverlayChangedEvent>();
  }

  /// 快速房間產生錯誤的事件流。
  Stream<FastErrorEvent> onError() {
    return _fastEventStreamController.stream.whereType<FastErrorEvent>();
  }

  /// 快速房間視圖尺寸發生變化的事件流。
  Stream<SizeChangedEvent> onSizeChanged() {
    return _fastEventStreamController.stream.whereType<SizeChangedEvent>();
  }

  void changeOverlay(int key) {
    _fastEventStreamController.add(OverlayChangedEvent(key));
  }

  void notifyFastError(WhiteException exception) {
    _fastEventStreamController.add(FastErrorEvent(exception));
  }

  void notifySizeChanged(Size size) {
    _fastEventStreamController.add(SizeChangedEvent(size));
  }

  /// 清除當前場景的所有繪畫元素（線條、文字等）和圖像。
  void cleanScene() {
    whiteRoom?.cleanScene(false);
  }

  /// 在當前場景的目錄中添加一個新頁面。
  void addPage() {
    whiteRoom?.addPage();
  }

  /// 切換到上一個頁面。
  void prevPage() {
    whiteRoom?.prevPage();
  }

  /// 切換到下一個頁面。
  void nextPage() {
    whiteRoom?.nextPage();
  }

  /// 移除所有頁面。
  void removePages() {
    whiteRoom?.removeScenes('/');
  }

  /// 設定白板工具，例如畫筆、橡皮擦等。
  /// 當 [fastAppliance] 是 [FastAppliance.clear] 時，清除場景的繪畫元素。
  void setAppliance(FastAppliance fastAppliance) {
    if (fastAppliance == FastAppliance.clear) {
      cleanScene();
      return;
    }
    var state = MemberState()
      ..currentApplianceName = fastAppliance.appliance
      ..shapeType = fastAppliance.shapeType;
    whiteRoom?.setMemberState(state);
  }

  /// 設定元素的繪畫筆觸寬度。
  void setStrokeWidth(num strokeWidth) {
    var state = MemberState()..strokeWidth = strokeWidth;
    whiteRoom?.setMemberState(state);
  }

  /// 設定元素的繪畫筆觸顏色。
  void setStrokeColor(Color color) {
    var state = MemberState()
      ..strokeColor = [
        color.red,
        color.green,
        color.blue,
      ];
    whiteRoom?.setMemberState(state);
  }

  /// 設定使用者在房間中的寫入權限。
  /// - `true`: 交互模式，即擁有讀寫權限。
  /// - `false`: 訂閱模式，即只有讀取權限。
  Future<bool> setWritable(bool writable) async {
    var result = await whiteRoom?.setWritable(writable) ?? false;
    value = value.copyWith(writable: result);
    if (result) {
      whiteRoom?.disableSerialization(false);
    }
    return result;
  }

  /// 撤銷上一步操作。
  void undo() {
    whiteRoom?.undo();
  }

  /// 重做一步操作。
  void redo() {
    whiteRoom?.redo();
  }

  /// 將白板縮放至指定比例。
  void zoomTo(num zoomScale) {
    whiteRoom?.moveCamera(CameraConfig(scale: zoomScale));
  }

  /// 重置白板的縮放比例。
  void zoomReset() {
    whiteRoom?.moveCamera(CameraConfig(
      scale: zoomScaleDefault,
      centerX: 0,
      centerY: 0,
    ));
  }

  Future<void> joinRoomWithSdk(WhiteSdk whiteSdk) async {
    this.whiteSdk = whiteSdk;
    await joinRoom();
  }

  /// 加入白板房間。
  Future<void> joinRoom() async {
    try {
      whiteRoom = await whiteSdk?.joinRoom(
        options: fastRoomOptions.genRoomOptions(
            ratioWhenNull: ratioWhenNull,
            prefersColorScheme: useDarkTheme ?? false
                ? WindowPrefersColorScheme.dark
                : WindowPrefersColorScheme.light),
        onRoomPhaseChanged: _onRoomPhaseChanged,
        onRoomStateChanged: _onRoomStateChanged,
        onCanRedoStepsUpdate: _onCanRedoUpdated,
        onCanUndoStepsUpdate: _onCanUndoUpdated,
        onRoomDisconnected: _onRoomDisconnected,
        onRoomKicked: _onRoomKicked,
        onRoomError: _onRoomError,
      );
      value = value.copyWith(isReady: true, roomState: whiteRoom?.state);
      if (fastRoomOptions.writable) {
        whiteRoom?.disableSerialization(false);
      }
    } on WhiteException catch (e) {
      debugPrint("joinRoom error ${e.message}");
      notifyFastError(e);
    } catch (e) {
      debugPrint("joinRoom error $e");
    }
  }

  Future<void> reconnect() async {
    value = FastRoomValue.uninitialized(fastRoomOptions.writable);
    if (whiteRoom != null) {
      await whiteRoom?.disconnect();
    }
    return joinRoom();
  }

    /// 斷開白板房間的連接。 0808
    Future<void> disconnect() async {
    try {
      if (whiteRoom != null) {
        await whiteRoom?.disconnect();
      }
      whiteRoom = null;
      whiteSdk = null;
      value = FastRoomValue.uninitialized(fastRoomOptions.writable);
    } catch (e) {
      debugPrint("disconnect error: $e");
    }
  }

  /// 在白板上插入一個圖片。
  /// - [url]: 圖片的 URL。
  /// - [width]: 圖片的寬度。
  /// - [height]: 圖片的高度。
  void insertImage(String url, num width, num height) {
    var info = ImageInformation(width: width, height: height);
    whiteRoom?.insertImageByUrl(info, url);
  }

  /// 在白板的子窗口插入一個視頻或音頻。
  /// - [url]: 視頻或音頻的 URL。
  /// - [title]: 窗口的標題。
  Future<String?> insertVideo(String url, String title) async {
    var windowAppParams = WindowAppParams.mediaPlayerApp(url, title);
    return await whiteRoom?.addApp(windowAppParams);
  }

  /// 在白板的子窗口插入一個文檔。
  /// - [params]: 插入文檔的相關參數，如 taskUUID、taskToken、dynamic 等。
  Future<String?> insertDoc(InsertDocParams params) async {
    if (whiteRoom == null) return null;
    try {
      ConversionQuery query = ConversionQuery(
        taskUUID: params.taskUUID,
        takeToken: params.taskToken,
        convertType:
            params.dynamic ? ConversionType.dynamic : ConversionType.static,
        region: (params.region ?? fastRoomOptions.fastRegion).toRegion(),
      );

      var info = await Converter.instance.startQuery(query);
      var windowAppParams = WindowAppParams.slideApp(
        "/${params.taskUUID}/${whiteRoom?.genUuidV4()}",
        info.toScenes(),
        params.title,
      );
      return await whiteRoom?.addApp(windowAppParams);
    } catch (e) {
      debugPrint("insertDoc error $e");
      return null;
    }
  }

  /// 設定容器的大小比例。
  void setContainerSizeRatio(double ratio) {
    containerSizeRatio = ratio;
    whiteRoom?.setContainerSizeRatio(ratio);
  }

  /// 更新 FastRoomView 的佈局尺寸。
  void updateRoomLayoutSize(Size size) {
    roomLayoutSize = size;
    if (containerSizeRatio == null) {
      whiteRoom?.setContainerSizeRatio(size.height / size.width);
    }
    notifySizeChanged(size);
  }

  /// 更新白板的主題。
  /// - [useDarkTheme]: 是否使用深色主題。
  /// - [themeData]: 主題數據。
  void updateThemeData(bool useDarkTheme, FastThemeData themeData) {
    this.useDarkTheme = useDarkTheme;
    whiteSdk?.setBackgroundColor(themeData.backgroundColor);
    whiteRoom?.setPrefersColorScheme(useDarkTheme
        ? WindowPrefersColorScheme.dark
        : WindowPrefersColorScheme.light);
  }

  void _onRoomStateChanged(RoomState newState) {
    value = value.copyWith(roomState: newState);
  }

  /// 當重新連接時，清除所有 redo 和 undo 計數。
  void _onRoomPhaseChanged(String phase) {
    var redoUndoCount = phase == RoomPhase.connected
        ? const FastRedoUndoCount.initialized()
        : value.redoUndoCount;
    value = value.copyWith(
      roomPhase: phase,
      redoUndoCount: redoUndoCount,
    );
  }

  void _onRoomKicked(String reason) {
    debugPrint("room kicked $reason");
  }

  void _onRoomError(String error) {
    debugPrint("on room error $error");
  }

  void _onRoomDisconnected(String error) {
    debugPrint("room disconnected $error");
  }

  void _onCanRedoUpdated(int redoCount) {
    var redoUndoCount = value.redoUndoCount.copyWith(redoCount: redoCount);
    value = value.copyWith(redoUndoCount: redoUndoCount);
  }

  void _onCanUndoUpdated(int undoCount) {
    var redoUndoCount = value.redoUndoCount.copyWith(undoCount: undoCount);
    value = value.copyWith(redoUndoCount: redoUndoCount);
  }

  @override
  void dispose() {
    super.dispose();
    _fastEventStreamController.close();
  }
}

/// 保留給回放使用
class FastReplayController {}
