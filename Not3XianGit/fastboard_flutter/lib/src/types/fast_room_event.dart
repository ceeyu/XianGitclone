import 'dart:ui';

import 'package:fastboard_flutter/fastboard_flutter.dart';

/// 表示 FastRoom 事件的基本類別
class FastRoomEvent<T extends Object> {
  final T value;

  FastRoomEvent(this.value);
}

/// 處理 overlay 變更事件的類別
class OverlayChangedEvent extends FastRoomEvent<int> {
  static const int noOverlay = 0;
  static const int subAppliances = 1;

  OverlayChangedEvent(int value) : super(value);
}

/// FastRoom 錯誤事件的類別
class FastErrorEvent extends FastRoomEvent<WhiteException> {
  FastErrorEvent(WhiteException exception) : super(exception);
}

/// FastRoom 尺寸變更事件的類別
class SizeChangedEvent extends FastRoomEvent<Size> {
  SizeChangedEvent(Size size) : super(size);
}
