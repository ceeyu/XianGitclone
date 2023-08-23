import 'package:fastboard_flutter/fastboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'test_data.dart';
import 'dart:convert';
import 'constants.dart';
class CloudTestWidget extends StatefulWidget 
{
  final FastRoomController controller;
  const CloudTestWidget
  (
    {
      required this.controller,
      Key? key,
    }
  ) : super(key: key);

  @override
  State<CloudTestWidget> createState()
  {
    return CloudTestWidgetState();
  }
}
class CloudTestWidgetState extends State<CloudTestWidget> 
{
  var showCloud = false;
  final _storage = const FlutterSecureStorage(); // 用於存儲 access_token
  Future<String?> getAccessToken() async 
  {
    // 從 flutter_secure_storage 取得 access_token
    String? accessToken = await _storage.read(key: 'access_token');
    if (kDebugMode) 
    {
      print('Access Token: $accessToken');
    }
    return accessToken; //得到accessToken值
  }
  Future<void> showBanRoomResultDialog(BuildContext context, String message) async 
  {
    await showDialog
    (
      context: context,
      builder: (context) => AlertDialog
      (
        content: Text
        (
          message,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          textAlign: TextAlign.center,
        ),
        actions: 
        [
          TextButton
          (
            onPressed: () 
            {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  Future<void> showDisconnectResultDialog(BuildContext context, String message) async 
  {
    await showDialog
    (
      context: context,
      builder: (context) => AlertDialog
      (
        content: Text
        (
          message,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          textAlign: TextAlign.center,
        ),
        actions: 
        [
          TextButton
          (
            onPressed: () 
            {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  Future<void> _handleBanRoomButton() async 
  {
    final savedAccessToken = await getAccessToken();
    if (savedAccessToken != null) 
    {
      try 
      {
        final response = await http.post
        (
          Uri.parse('http://120.126.16.222/leafs/disable-room'),
          headers: <String, String>
          {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $savedAccessToken',
          },
          body: jsonEncode(<String, String>
          {
            'region': 'cn-hz',
            'uuid': ROOM_UUID, // 假設這是你的 ROOM_UUID
          }),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) 
        {
          final body = jsonDecode(response.body);
          // ignore: non_constant_identifier_names
          final Message = body[0]['error_message'];
          if (Message == '房間不存在' || Message == '不是此房間創始人，不能關閉房間') 
          {
            // ignore: use_build_context_synchronously
            await showBanRoomResultDialog(context, Message);
          } 
          else 
          {
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          }
        } 
        else 
        {
          final errorMessage = response.body;
          // ignore: use_build_context_synchronously
          await showBanRoomResultDialog(context, errorMessage);
        }
      } catch (e) 
      {
        final errorMessage = 'Ban房失敗：$e';
        // ignore: use_build_context_synchronously
        await showBanRoomResultDialog(context, errorMessage);
      }
    } 
    else 
    {
      const errorMessage = '尚未登入，無法進行登出。';
      // ignore: use_build_context_synchronously
      await showBanRoomResultDialog(context, errorMessage);
    }
  }
  Future<void> _handleLeaveButton() async 
  {
    final savedAccessToken = await getAccessToken();
    if (savedAccessToken != null) 
    {
      try 
      {
        final response = await http.post
        (
          Uri.parse('http://120.126.16.222/gardenerofleafs/delete-gardener'),
          headers: <String, String>
          {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $savedAccessToken',
          },
          body: jsonEncode(<String, String>
          {
            'uuid': ROOM_UUID, // 假設這是你的 ROOM_UUID
          }),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) 
        {
          final body = jsonDecode(response.body);
          //normal audiences
          if (body[0]['message'] == '成功離開' && body[0]['isFounder'] == 'false'&&body[0]['isLast'] == 'false') 
          {
            final message = body[0]['message'];
            // ignore: use_build_context_synchronously
            await showDisconnectResultDialog(context, message);
          } 
          //isLastOne
          else if (body[0]['message'] == '成功離開' && body[0]['isLast'] == 'true'&&body[0]['isFounder']== 'false') 
          {
            if (kDebugMode) 
            {
              print("最後一人所以直接關葉子");
            }
            _handleBanRoomButton();
          } 
          //isFounder&&isLastOne
          else if(body[0]['message'] == '成功離開' &&body[0]['isFounder'] == 'true'&&body[0]['isLast']=='true')
          {
            if (kDebugMode) 
            {
              print("is Founder but also 最後一人所以直接關葉子");
            }
            _handleBanRoomButton();
          }
          //isFounder
          else if(body[0]['message'] == '成功離開' &&body[0]['isFounder'] == 'true'&&body[0]['isLast']=='false')
          {
            if (kDebugMode) 
            {
              print("is Founder所以可直接關葉子");
            }
            _handleBanRoomButton();
          }
          else 
          {
            final errorMessage = response.body;
            // ignore: use_build_context_synchronously
            await showDisconnectResultDialog(context, errorMessage);
          }
        } 
        else 
        {
          final errorMessage = response.body;
          // ignore: use_build_context_synchronously
          await showDisconnectResultDialog(context, errorMessage);
        }
      } 
      catch (e) 
      {
        final errorMessage = '離開失敗：$e';
        // ignore: use_build_context_synchronously
        await showDisconnectResultDialog(context, errorMessage);
      }
    }
  }
  Future<void> _handleDownLoadButton()async
  {
    
  }
  @override
  Widget build(BuildContext context) 
  {
    return ConstrainedBox
    (
      constraints: const BoxConstraints.expand(),
      child: Stack
      (
        alignment: AlignmentDirectional.center,
        children: 
        [
          if (showCloud)
            Positioned
            (
              right: 56.0,
              child: buildCloudLayout(context),
            ),
          Positioned
          (
            right: 12.0,
            child: InkWell
            (
              onTap: switchShowCloud,
              child: Container
              (
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration
                (
                  color: Colors.white,
                  border: const Border.fromBorderSide
                  (
                    BorderSide
                    (
                      width: 1.0,
                      color: Colors.black38,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Icon(Icons.cloud, size: 24.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void switchShowCloud() 
  {
    setState(() 
    {
      showCloud = !showCloud;
    });
  }
  Widget buildCloudLayout(BuildContext context) 
  {
    var items = TestData.kCloudFiles;
    return Container
    (
      width: 250.0,
      decoration: BoxDecoration
      (
        color: Colors.white,
        border: const Border.fromBorderSide
        (
          BorderSide
          (
            width: 1.0,
            color: Colors.black38,
          ),
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column
      (
        children: 
        [
          const ListTile(title: Text("Cloud")), // 顯示 "Cloud" 標題
          SizedBox
          (
            height: 200,
            child: ListView.builder
            (
              itemCount: items.length,
              itemBuilder: (context, index) 
              {
                var item = items[index];
                return SizedBox
                (
                  height: 50,
                  child: InkWell
                  (
                    onTap: () => onItemClick(item), // 點擊項目時執行 onItemClick 函數
                    child: Row
                    (
                      children: 
                      [
                        Padding
                        (
                          padding: const EdgeInsets.symmetric(horizontal: 4.0,),
                          child: iconByItem(item), // 根據檔案類型顯示對應圖示
                        ),
                        Expanded
                        (
                          child: Text(items[index].name), // 顯示檔案名稱
                        ),
                        Padding
                        (
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: TestData.iconAdd,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget iconByItem(CloudFile item) 
  {
    var map = <String, Widget>
    {
      "pdf": TestData.iconPdf,
      "ppt": TestData.iconPpt,
      "pptx": TestData.iconPpt,
      "png": TestData.iconImage,
      "mp4": TestData.iconVideo,
    };
    return map[item.type] ?? TestData.iconPdf; // 根據檔案類型返回對應的圖示，預設為 PDF 圖示
  }

  Future<void> onItemClick(CloudFile item) 
  async 
  {
    switch (item.type) 
    {
      case "png":
      case "jpg":
        widget.controller.insertImage(item.url, item.width!, item.height!); // 插入圖片到白板中
        break;
      case "mp4":
        widget.controller.insertVideo(item.url, item.name); // 插入影片到白板中
        break;
      case "leave": //離開葉子
        await _handleLeaveButton(); // 呼叫API
        widget.controller.disconnect();
        break;
      case "download": //下載檔案
        await _handleDownLoadButton(); // 呼叫API
        break;
      case "pptx":
        widget.controller.insertDoc
        (
          InsertDocParams
          (
            taskUUID: item.taskUUID!,
            taskToken: item.taskToken!,
            dynamic: true,
            title: item.name,
            region: FastRegion.cn_hz,
          ),
        ); // 插入動態 PPT 到白板中
        break;
      case "pdf":
        widget.controller.insertDoc
        (
          InsertDocParams
          (
            taskUUID: item.taskUUID!,
            taskToken: item.taskToken!,
            dynamic: false,
            title: item.name,
            region: FastRegion.cn_hz,
          ),
        ); // 插入 PDF 到白板中
        break;
    }
    switchShowCloud(); // 點擊後關閉 Cloud 佈局
  }
}
