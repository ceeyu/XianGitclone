import 'dart:async';

import 'package:fastboard_flutter/fastboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';
import 'page.dart';
import 'widgets.dart';
import 'package:flutter_project/agora/agora_service.dart'; // 引入LoginPage

// 定義快速啟動頁面
class QuickStartPage extends FastExamplePage {
  const QuickStartPage()
      : super(
          const Icon(Icons.rocket_launch_rounded),
          'Quick Start',
        );

  @override
  Widget build(BuildContext context) {
    return const QuickStartBody();
  }
}

class QuickStartBody extends StatefulWidget {
  const QuickStartBody();

  @override
  State<StatefulWidget> createState() {
    return QuickStartBodyState();
  }
}

class QuickStartBodyState extends State<QuickStartBody> {
  Completer<FastRoomController> completerController = Completer();

  bool _is_videio_on = false;
  bool _is_message_on = false; //xian0519
  // ignore: non_constant_identifier_names
  bool switchValue_Volume = true;
  // ignore: non_constant_identifier_names
  bool switchValue_Mic = true;
  // ignore: non_constant_identifier_names
  bool switchValue_Camera = true;
  // ignore: non_constant_identifier_names
  bool switchValue_Notify = true;
  // 這是應用程序的根節點小工具。

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('葉子名稱'),
        ),
        actions: <Widget>[
          //越後面的button越右，由左往右的方向

          IconButton(
            tooltip: "彈幕",
            icon: _is_message_on
                ? const Icon(Icons.message)
                : const Icon(
                    Icons.speaker_notes_off,
                  ),
            onPressed: () {
              // do something
              setState(() {
                // Here we changing the icon.
                _is_message_on = !_is_message_on;
              });
            },
          ),
          IconButton(
            tooltip: "錄影",
            icon: _is_videio_on
                ? const Icon(Icons.videocam)
                : const Icon(
                    Icons.videocam_off,
                  ),
            onPressed: () {
              // do something
              setState(() {
                // Here we changing the icon.
                _is_videio_on = !_is_videio_on;
              });
            },
          ),
          IconButton(
            tooltip: "離開/結束",
            //最右邊
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              // do something
            },
          ),
        ],
        backgroundColor: Colors.green,
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          FastRoomView(
            fastRoomOptions: FastRoomOptions(
              appId: APP_ID, // 從constant.dart中獲取的Agora應用程式ID
              uuid: ROOM_UUID, // 從constant.dart中獲取的Agora房間UUID
              token: ROOM_TOKEN, // 從constant.dart中獲取的Agora房間令牌
              uid: UNIQUE_CLIENT_ID, // 自定義的用戶ID
              writable: true, // 房間是否可寫（可編輯）
              fastRegion: FastRegion.cn_hz, // 快速的區域（此處為杭州地區）
              containerSizeRatio: null, // 容器大小比例，此處為空
            ),
            useDarkTheme: false, // 使用淺色主題
            onFastRoomCreated: onFastRoomCreated, // 當FastRoomController創建時的回調函數
          ),
          FutureBuilder<FastRoomController>(
            future: completerController.future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasData) {
                return Positioned(
                  child: CloudTestWidget(controller: snapshot.data!),
                );
              } else {
                return Container();
              }
            },
          ),
          Positioned(
            child: InkWell(
              child: Icon(Icons.face),
              onTap: () {
               // 點擊返回按鈕時，動作
              },
            ),
            left: 30,
            top: 30,
          ),
        ],
      ),
    );
  }

  Widget customControllerBuilder(
    BuildContext context,
    FastRoomController controller,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        FastOverlayHandlerView(controller),
        Positioned(
          child: FastPageIndicator(controller),
          bottom: FastGap.gap_3,
          right: FastGap.gap_3,
        ),
        FastToolBoxExpand(controller),
        FastStateHandlerView(controller),
      ],
    );
  }

  Future<void> onFastRoomCreated(FastRoomController controller) async {
    completerController.complete(controller);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]); // 設置首選方向（支持橫屏和豎屏）
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); // 隱藏系統UI元素（例如狀態欄和導航欄）
  }

}
