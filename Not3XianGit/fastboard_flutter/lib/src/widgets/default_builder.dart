import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart'; 

// 引入 controller.dart 檔案中的定義
import '../controller.dart';

// 引入 widgets.dart 檔案中的定義
import 'widgets.dart';

// 自訂的 Widget 建構函式，用於建立預設的控制器畫面
Widget defaultControllerBuilder(
  BuildContext context,
  FastRoomController controller,
) {
  return Stack(
    alignment: Alignment.center, // 設定 Stack 中的 Widget 對齊方式為中心
    children: [
      FastOverlayHandlerView(controller), // 使用 FastOverlayHandlerView Widget，傳入控制器
      Positioned(
        child: FastPageIndicator(controller), // 使用 FastPageIndicator Widget，傳入控制器
        bottom: FastGap.gap_3, // 設定 FastPageIndicator Widget 與底部的間距
      ),
      Positioned(
        child: Row(
          children: [
            FastRedoUndoView(controller), // 使用 FastRedoUndoView Widget，傳入控制器
            SizedBox(width: FastGap.gap_2), // 使用 SizedBox 建立寬度為 FastGap.gap_2 的間距
            FastZoomView(controller), // 使用 FastZoomView Widget，傳入控制器
          ],
        ),
        bottom: FastGap.gap_3, // 設定整個 Row Widget 與底部的間距
        left: FastGap.gap_3, // 設定整個 Row Widget 與左側的間距
      ),
      //0809新增
      FastToolBoxExpand(controller), // 使用 FastToolBoxExpand Widget，傳入控制器
      FastStateHandlerView(controller), // 使用 FastStateHandlerView Widget，傳入控制器
      Positioned(
        child: InkWell(
          child: Icon(Icons.power_settings_new), // 自訂斷開連接的按鈕圖示
          onTap: () {
            // 點擊按鈕時，執行斷開連接的操作
            if (controller != null) {
              controller.disconnect(); // 執行斷開連接的函式
              Navigator.pop(context); // 回到上一頁
            }
          },
        ),
        bottom: FastGap.gap_3,
        right: FastGap.gap_3,
      ),
      
    ],
  );
}


