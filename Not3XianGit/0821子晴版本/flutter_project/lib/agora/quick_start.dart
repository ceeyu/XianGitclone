import 'dart:async';
//import 'package:whiteboard_sdk_flutter/whiteboard_sdk_flutter.dart';
import 'package:fastboard_flutter/fastboard_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';
import 'page.dart';
import 'widgets.dart';
// 定義快速啟動頁面
class QuickStartPage extends FastExamplePage 
{
  const QuickStartPage()
  : super
  (
    const Icon(Icons.rocket_launch_rounded),
    'Quick Start',
  );

  @override
  Widget build(BuildContext context) 
  {
    return const QuickStartBody();
  }
}
class QuickStartBody extends StatefulWidget 
{
  final String? leafName;
  const QuickStartBody
  (
    {
      Key?key,
      this.leafName,
    }
  ):super(key:key); 

  @override
  State<StatefulWidget> createState() 
  {
    return QuickStartBodyState();
  }
}
class QuickStartBodyState extends State<QuickStartBody> 
{
  Completer<FastRoomController> completerController = Completer();
  final _storage = const FlutterSecureStorage(); // 用於存儲 access_token
  List<Map<String,dynamic>> getGardenerList=[];
  bool isListVisible=false;
  String? leafName;
  @override
  void initState() 
  {
    super.initState();
    leafName=widget.leafName;
    SystemChrome.setPreferredOrientations
    (
      [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp,
      ]
    ); // 設置首選方向（支持橫屏和豎屏）
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); // 隱藏系統UI元素（例如狀態欄和導航欄）
  }
  Future<String?> getAccessToken() async 
  {
    // 從 flutter_secure_storage 取得 access_token
    String? accessToken = await _storage.read(key: 'access_token');
    if (kDebugMode) 
    {
      print('Access Token: $accessToken');
    }
    return accessToken;
  }
  Future<void>listAllGardeners()async
  {
    try
    {
      final response=await http.post
      (
        Uri.parse('http://120.126.16.222/gardenerofleafs/get-all-gardener'),
        headers:<String,String>
        {
          'Content-Type':'application/json',
        },
        body:jsonEncode(<String,String>
        {
          'leaf_id':ROOM_UUID,
        }),
      );
      if(kDebugMode)
      {
        print("Get-All-Gardeners: $ROOM_UUID");
      }
      if(response.statusCode>=200&&response.statusCode<300)
      {
        final responseData=jsonDecode(response.body);
        if(kDebugMode)
        {
          print('listAllGardeners API 回傳資料: $responseData');
        }
        if(responseData[0]['error_message']=='Leaf not found !')
        {
          final errorMessage=responseData[0]['error_message'];
          if (kDebugMode) 
          {
            print('listAllGardener回傳error_message:$errorMessage');
          }
          setState(() 
          {
            getGardenerList.clear();
            getGardenerList.add({'error_message':errorMessage});
            isListVisible=true;
            _showGardenerListDialog(context);
            if (kDebugMode) 
            {
              print('Error_message的getGardenerList:$getGardenerList');
            }
          });
        }
        else 
        {
          setState(() 
          {
            getGardenerList=List<Map<String,dynamic>>.from(responseData);
            isListVisible=true;
            _showGardenerListDialog(context);
            if (kDebugMode) 
            {
              print('傳送之後getGardenerList:$getGardenerList');
            }
          });
        }
      }
      else
      {
        if(kDebugMode)
        {
          print('Error:請求失敗\n$response\nStatusCode: ${response.statusCode}');
        }
      }
    }
    catch(error)
    {
      if(kDebugMode)
      {
        print('Catch Error: $error');
      }
    }
  }
  void _showGardenerListDialog(BuildContext context)
  {
    showDialog
    (
      context: context, 
      builder: (BuildContext context)
      {
        return AlertDialog
        (
          title: const Text('葉子園丁清單'),
          content: SingleChildScrollView
          (
            child: ListBody
            (
              children:getGardenerList.map((gardener)
              {
                if(gardener.containsKey('error_message'))
                {
                  return const ListTile
                  (
                    title:Text('該葉子不存在!'),
                  );
                }
                else
                {
                  return ListTile
                  (
                    title: Text(gardener['first_name']),
                    subtitle: Text('Account: ${gardener['account']}'),

                  );
                }
              }).toList(),
            ),
          ),
          actions: 
          [
            ElevatedButton
            (
              onPressed:()
              {
                Navigator.of(context).pop();
              }, 
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
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
  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: Center
        (
          child: Text(leafName?? 'Leaf Name'),
        ),
        actions: <Widget>
        [
          //越後面的button越右，由左往右的方向
          PopupMenuButton<void>
          (
            onSelected: (value)
            {
              listAllGardeners();
            },
            itemBuilder: (BuildContext context)
            {
              return
              [
                const PopupMenuItem
                (
                  // ignore: void_checks
                  value:1,
                  child: Text('Gardener List'),
                ),
              ];
            },
            icon: const Icon(Icons.list_alt), 
          ),
          IconButton
          (
            tooltip: "彈幕",
            icon: _is_message_on
                ? const Icon(Icons.message)
                : const Icon(Icons.speaker_notes_off,),
            onPressed: () 
            {
              // do something
              setState(() 
              {
                // Here we changing the icon.
                _is_message_on = !_is_message_on;
              });
            },
          ),
          IconButton
          (
            tooltip: "錄影",
            icon: _is_videio_on
                ? const Icon(Icons.videocam)
                : const Icon(Icons.videocam_off,),
            onPressed: () 
            {
              // do something
              setState(() 
              {
                // Here we changing the icon.
                _is_videio_on = !_is_videio_on;
              });
            },
          ),
        ],
        backgroundColor: Colors.green,
        elevation: 0.0,
      ),
      body: Stack
      (
        children: 
        [
          FastRoomView
          (
            fastRoomOptions: FastRoomOptions
            (
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
          FutureBuilder<FastRoomController>
          (
            future: completerController.future,
            builder: (context, snapshot) 
            {
              if (snapshot.connectionState == ConnectionState.waiting) 
              {
                return const CircularProgressIndicator();
              } 
              else if (snapshot.hasData) 
              {
                return Positioned
                (
                  child: CloudTestWidget(controller: snapshot.data!),
                );
              } 
              else 
              {
                return Container();
              }
            },
          ),
          Positioned
          (
            left: 30,
            top: 30,
            child: InkWell
            (
              child: const Icon(Icons.face),
              onTap: () 
              {
                // 點擊face 按鈕時，動作
                showDialog
                (
                  context: context,
                  builder: (BuildContext context) 
                  {
                    String textToCopy = 'Someone sent you a link : $LINK';

                    return AlertDialog
                    (
                      title: const Text('複製連結'),
                      content: Column
                      (
                        mainAxisSize: MainAxisSize.min,
                        children: 
                        [
                          TextField
                          (
                            controller: TextEditingController(text: textToCopy),
                            readOnly: true,
                            decoration: const InputDecoration
                            (
                              border: OutlineInputBorder(),
                              labelText: '複製連結',
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton
                          (
                            onPressed: () 
                            {
                              Clipboard.setData
                              (
                                ClipboardData(text: textToCopy)
                              );
                              Navigator.of(context).pop(); // 關閉警示框
                            },
                            child: const Text('複製連結'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget customControllerBuilder(BuildContext context,FastRoomController controller,) 
  {
    return Stack
    (
      alignment: Alignment.center,
      children: 
      [
        FastOverlayHandlerView(controller),
        Positioned
        (
          //頁數增加
          bottom: FastGap.gap_3,
          right: FastGap.gap_3,
          //頁數增加
          child: FastPageIndicator(controller),
        ),
        FastToolBoxExpand(controller), //工具箱
        FastStateHandlerView(controller), //工具箱縮放
      ],
    );
  }
  //Fastborad創建的地方
  Future<void> onFastRoomCreated(FastRoomController controller) async 
  {
    completerController.complete(controller);
  }
}
