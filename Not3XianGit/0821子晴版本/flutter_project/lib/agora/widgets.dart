import 'package:fastboard_flutter/fastboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/MyPage1.dart';
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
  Future<void> deleteAccessToken() async 
  {
    // 從 flutter_secure_storage 刪除 access_token
    await _storage.delete(key: 'access_token');
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
          if (Message == '房間不存在' || Message == '不是此房間創始人，不能關閉房間'|| Message == '沒有權限關閉房間') 
          {
            // ignore: use_build_context_synchronously
            await showBanRoomResultDialog(context, Message);
          } 
          else 
          {
            //await logOut();
            if(kDebugMode)
            {
              print('BanRoomButton已成功關閉會議！');
            }
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
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          } 
          //isFounder&&isLastOne
          else if(body[0]['message'] == '成功離開' &&body[0]['isFounder'] == 'true'&&body[0]['isLast']=='true')
          {
            if (kDebugMode) 
            {
              print("is Founder but also 最後一人所以可直接關閉葉子");
            }
            _handleBanRoomButton();
          }
          //isFounder
          else if(body[0]['message'] == '成功離開' &&body[0]['isFounder'] == 'true'&&body[0]['isLast']=='false')
          {
            if (kDebugMode) 
            {
              print("is Founder所以可選擇關閉或離開葉子");
            }
            // ignore: use_build_context_synchronously
            showDialog
            (
              context: context, 
              builder: (context)=>AlertDialog
              (
                title: const Text('選擇關閉或離開'),
                content: const Text('您是創建葉子者，可選擇關閉或離開葉子\n離開：還能通過連結再加入噢\n關閉：直接結束這會議(不是創建者或會議最後使用者只能離開)'),
                actions: 
                [
                  ElevatedButton
                  (
                    onPressed: ()async
                    {
                      await _handleBanRoomButton();
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    }, 
                    child:const Text('關閉會議'),
                  ),
                  ElevatedButton
                  (
                    onPressed: ()async
                    {
                      await showDisconnectResultDialog(context, '成功離開');
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    }, 
                    child:const Text('離開會議'),
                  ),

                ],
              ),
            );
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
  Future<void> banRoomAndLeaveRoom()async 
  {
    // ignore: use_build_context_synchronously
    showDialog
    (
      context: context, 
      builder: (context)=>AlertDialog
      (
        title: const Text('離開/關閉葉子'),
        content: const Text
        (
          '離開：還能通過連結再加入噢\n關閉：直接結束這會議(不是創建者或會議最後使用者只能離開)'
        ),
        actions: 
        [
          ElevatedButton
          (
            onPressed: ()async
            {
              await _handleLeaveButton();
            }, 
            child:const Text('關閉會議'),
          ),
          ElevatedButton
          (
            onPressed: () async 
            {
              await _handleLeaveButton();
            },
            child: const Text('離開會議'),
          ),
        ],
      ),
    );
  }
  Future<void> logOut()async
  {
    final savedAccessToken=await getAccessToken();
    if (savedAccessToken != null) 
    {
      // 呼叫登出 API
      try 
      {
        final response = await http.post
        (
          Uri.parse('http://120.126.16.222/gardeners/logout'),
          headers: <String, String>
          {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $savedAccessToken',
          },
          body: jsonEncode(<String, String>
          {
            'access_token': savedAccessToken,
          }),
        );
        if (response.statusCode == 200) 
        {
          // 輸出登出成功的回傳資料
          final body = jsonDecode(response.body);
          // ignore: use_build_context_synchronously
          Navigator.pushAndRemoveUntil
          (
            context,MaterialPageRoute(builder:(_)=>const MyPage1()),
            (route)=>false,
          );
          if(kDebugMode)
          {
            print('After BanRoom Logout Successful!\n$body');
          }
          await deleteAccessToken(); // 登出後刪除保存的 access_token
        } 
        else 
        {
          // 登出失敗
          final errorMessage = response.body;
          if(kDebugMode)
          {
            print('After BanRoom Logout Failed!\n$errorMessage');
          }

        }
      } 
      catch (e) 
      {
        if (kDebugMode) 
        {
          print('Catch Error登出失敗:$e');
        }
      }
    } 
    else 
    {
      // 沒有保存的 access_token，直接顯示錯誤訊息
      const errorMessage = '尚未登入，無法進行登出。';
      if (kDebugMode) 
      {
        print(errorMessage);
      }
    }
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
        await banRoomAndLeaveRoom(); // 呼叫API
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
