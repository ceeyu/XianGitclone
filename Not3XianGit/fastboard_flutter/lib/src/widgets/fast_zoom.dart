import 'dart:math';

import 'package:flutter/material.dart';

import '../controller.dart';
import 'fast_base_ui.dart';
import 'fast_gap.dart';
import 'fast_icons.dart';
import 'fast_theme.dart';
//縮放功能在fastboard裡的實踐

class FastZoomView extends FastRoomControllerWidget {
  final num minScale;
  final num maxScale;

  const FastZoomView(
    FastRoomController controller, {
    Key? key,
    this.minScale = 0.25,
    this.maxScale = 10,
  }) : super(controller, key: key);

  @override
  State<StatefulWidget> createState() {
    return FastZoomState();
  }
}

class FastZoomState extends FastRoomControllerState<FastZoomView> {
  late num zoomScale;

  @override
  void initState() {
    super.initState();
    _updateZoomScale();
  }

  @override
  Widget build(BuildContext context) {
    return FastContainer(
      child: Row(
        children: [
          InkWell(
            child: FastIcon(FastIcons.zoomIn),
            onTap: _onZoomIn,
          ),
          SizedBox(width: FastGap.gap_1),
          FastText("${(zoomScale * 100).ceil()}%"),
          SizedBox(width: FastGap.gap_1),
          InkWell(
            child: FastIcon(FastIcons.zoomOut),
            onTap: _onZoomOut,
          ),
          InkWell(
            child: FastIcon(FastIcons.zoomReset),
            onTap: _onZoomReset,
          ),
        ],
      ),
    );
  }

  void _onZoomIn() {
    widget.controller.zoomTo(max(zoomScale * 0.8, widget.minScale));
  }

  void _onZoomOut() {
    widget.controller.zoomTo(min(zoomScale / 0.8, widget.maxScale));
  }

  void _onZoomReset() {
    widget.controller.zoomReset();
  }

  @override
  void calculateState() {
    _updateZoomScale();
  }

  void _updateZoomScale() {
    var cameraState = widget.controller.value.roomState.cameraState;
    zoomScale = cameraState?.scale ?? 1;
  }
}

class FastText extends StatelessWidget {
  const FastText(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    var themeData = FastTheme.of(context);
    var defaultTestStyle = DefaultTextStyle.of(context).style;

    return Text(
      text,
      style: defaultTestStyle.copyWith(
        color: themeData.textColorOnBackground,
      ),
    );
  }
}
