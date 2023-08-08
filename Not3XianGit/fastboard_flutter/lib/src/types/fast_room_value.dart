import 'package:flutter/foundation.dart';
import 'package:whiteboard_sdk_flutter/whiteboard_sdk_flutter.dart';

import 'fast_redo_undo_count.dart';

// 所有的 Fast 房間狀態，包括 isReady、writable、roomPhase 和 roomState。
class FastRoomValue {
  FastRoomValue({
    this.isReady = false,
    this.writable = false,
    this.roomPhase = RoomPhase.connecting,
    this.redoUndoCount = const FastRedoUndoCount(),
    RoomState? roomState,
  }) : roomState = roomState ?? RoomState();

  FastRoomValue.uninitialized(bool writable) : this(writable: writable);

  final bool isReady; // 是否已準備就緒

  final bool writable; // 是否可寫

  final RoomState roomState; // 房間狀態

  final String roomPhase; // 房間階段

  final FastRedoUndoCount redoUndoCount; // 重做和撤銷的次數

  /// 返回一個新的實例，該實例的值與當前實例的值相同，
  /// 除了傳遞給 [copyWith] 的任何覆蓋值之外。
  FastRoomValue copyWith({
    bool? isReady,
    bool? writable,
    RoomState? roomState,
    String? roomPhase,
    FastRedoUndoCount? redoUndoCount,
  }) {
    return FastRoomValue(
      isReady: isReady ?? this.isReady,
      writable: writable ?? this.writable,
      roomPhase: roomPhase ?? this.roomPhase,
      roomState: roomState ?? this.roomState,
      redoUndoCount: redoUndoCount ?? this.redoUndoCount,
    );
  }

  @override
  String toString() {
    return '${objectRuntimeType(this, 'FastRoomValue')}('
        'writable: $writable, '
        'roomPhase: $roomPhase, '
        'roomState: $roomState, ';
  }
}
