import 'package:flutter/foundation.dart';

//計算上下一步的步數
@immutable
class FastRedoUndoCount {
  final int redo;
  final int undo;

  const FastRedoUndoCount({
    this.redo = 0,
    this.undo = 0,
  });

  const FastRedoUndoCount.initialized() : this();

  FastRedoUndoCount copyWith({
    int? redoCount,
    int? undoCount,
  }) {
    return FastRedoUndoCount(
      redo: redoCount ?? redo,
      undo: undoCount ?? undo,
    );
  }
}
