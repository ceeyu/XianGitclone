import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_project/HomePage.dart';
import 'package:flutter_project/screens/GardenerSettingPage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_project/agora/constants.dart';
import 'package:flutter_project/agora/quick_start.dart'; // 引入QuickStartPage
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

class CreateFreeLeafPage extends StatefulWidget 
{
  const CreateFreeLeafPage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _CreateFreeLeafPageState createState() => _CreateFreeLeafPageState();
}
class FreeLeafModel 
{
  final String uuid;
  final String roomToken;
  final String appIdentifier;
  final String link;
  const FreeLeafModel
  (
    {
    required this.roomToken,
    required this.appIdentifier,
    required this.uuid,
    required this.link,
    }
  );
  factory FreeLeafModel.fromJson(Map<String, dynamic> json) 
  {
    final roomData = json['roomData'];
    final leafData = json['leafData'];
    final roomToken = json['roomToken'];
    final appIdentifier = roomData['appIdentifier'];
    final link = leafData['link'];
    final uuid = roomData['uuid'];
    return FreeLeafModel
    (
      roomToken: roomToken,
      appIdentifier: appIdentifier,
      uuid: uuid,
      link: link,
    );
  }
  @override
  String toString() 
  {
    return 'FreeLeafModel{uuid: $uuid, roomToken: $roomToken, appIdentifier: $appIdentifier}';
  }
}
class _CreateFreeLeafPageState extends State<CreateFreeLeafPage> 
{
  // ignore: non_constant_identifier_names
  bool switchValue_Volume = true;
  // ignore: non_constant_identifier_names
  bool switchValue_Mic = true;
  // ignore: non_constant_identifier_names
  bool switchValue_Camera = true;
  // ignore: non_constant_identifier_names
  bool switchValue_Notify = true;
  final TextEditingController _leafNameController=TextEditingController();
  // ignore: non_constant_identifier_names
  String PostSeach = '';
  final _storage = const FlutterSecureStorage(); // 用於存儲 access_token
  String? firstName;
  String? account;
  String? avatarFileName;
  Uint8List? avatarImageBytes;
  String? passLeafName;
  List<dynamic> whitepptDataList=[];
  File? pptxFile;
  Future<String?> getAccessToken()async
  {
    // 從 flutter_secure_storage 取得 access_token
    String? accessToken = await _storage.read(key:'access_token');
    if (kDebugMode) 
    {
      print('Access Token: $accessToken');
    }
    return accessToken;
  }
  Future<String?> getLeafName()async
  {
    String? leafName=await _storage.read(key:'leaf_name');
    if (kDebugMode) 
    {
      print('leafName: $leafName');
    }
    return leafName;
  }
  Future<String?> getFileName() async
  {
    String? fileName = await _storage.read(key:'file_name');
    if (kDebugMode) 
    {
      print('FileName: $fileName');
    }
    return fileName;
  }
  Future<void> deleteAccessToken() async 
  {
    // 從 flutter_secure_storage 刪除 access_token
    await _storage.delete(key: 'access_token');
  }
  @override
  void initState()
  {
    super.initState();
    getUserInfo();
  }
  Future<void> getUserInfo() async//顯示drawer的user資料
  {
    final savedAccessToken=await getAccessToken();
    if(savedAccessToken!=null)
    {
      try 
      {
        final response = await http.post
        (
          Uri.parse('http://120.126.16.222/gardeners/show-info'),
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
          // 解析API回傳的JSON數據
          final userInfo = jsonDecode(response.body);
          final userName=userInfo[0]['firstname'];
          final userAccount=userInfo[0]['account'];
          final avatarPath=userInfo[0]['file_path'];
          final avatarFileName=avatarPath.split('/').last;
          setState(() 
          {
            firstName = userName;
            account=userAccount;
            this.avatarFileName = avatarFileName;
            avatarName=avatarFileName.split('.').first;
            if(kDebugMode)
            {
              print('帳號名字:$firstName');
              print('檔名:$avatarFileName');
              print('帳號名:$avatarName');
            }
          });
          await getAvatar();//取得頭像圖檔
        } 
        else 
        {
          setState(() 
          {
            firstName = null;
          });
          if(kDebugMode)
          {
            print('Error:請求失敗,$response,${response.statusCode}');
          }
        }
      } 
      catch (e) 
      {
        setState(() 
        {
          firstName = null;
        });
        if(kDebugMode)
        {
          print('Error:請求出錯,$e');
        }
      }
    } 
    else 
    {
      setState(() 
      {
        firstName = null;
      });
      if(kDebugMode)
      {
        print('沒有保存的access_token');
      }
    }      
  }
  Future<void> getAvatar()async//顯示頭像
  {
    final savedAccessToken=await getAccessToken();
    if(savedAccessToken!=null&&avatarFileName!=null)
    {
      try
      {
        final response=await http.post
        (
          Uri.parse('http://120.126.16.222/gardeners/show-info-avatar'),
          headers: <String,String>
          {
            'Authorization':'Bearer $savedAccessToken',
          },
          body: jsonEncode(<String,String>
          {
            'access_token':savedAccessToken,
          }),
        );
        if(response.statusCode>=200&&response.statusCode<405)
        {
          setState(() 
          {
            avatarImageBytes=response.bodyBytes;
          });
          // final newAvatarInfo=jsonDecode(response.body);
          // final message=newAvatarInfo[0]['message'];
        }
        else
        {
          if(kDebugMode)
          {
            print('Error:請求圖檔失敗,$response,${response.statusCode}');
          }
        }
      }
      catch(error)
      {
        if(kDebugMode)
        {
          print('Error:請求圖檔出錯,$error');
        }
      }
    }
    else 
    {
      if(kDebugMode)
      {
        print('沒有保存的access_token或沒有取得圖檔名');
      }
    }      
  }
  Future<void> showLogoutResultDialog(String message) async//登出
  {
    // 顯示登出 API 回傳的結果
    await showDialog
    (
      context: context,
      builder: (context) => AlertDialog
      (
        //title: const Text('登出結果'),
        content: 
        Text
        (
          message,
          style: const TextStyle(fontWeight:FontWeight.bold,fontSize: 24),
          textAlign: TextAlign.center,
        ),
        actions:
        [
          TextButton
          (
            onPressed: () 
            {
              Navigator.of(context).pop();
              if(message.contains('登出成功'))
              {
                Navigator.pushAndRemoveUntil
                (
                  context,MaterialPageRoute(builder:(_)=>const HomePage()),
                  (route)=>false,
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  Future<void> joinIntoRoom()async
  {
    final savedAccessToken = await getAccessToken();
    final leafName=_leafNameController.text;
    await _storage.write(key: 'leaf_name', value: leafName);
    final savedLeafName=await getLeafName();
    passLeafName=savedLeafName;
    APP_ID = '';
    ROOM_UUID = '';
    ROOM_TOKEN = '';
    LINK = '';
    if(kDebugMode)
    {
      print('joinIntoRoom Initial: \n1.RoomID:$ROOM_UUID\n2.RoomUUID:$ROOM_TOKEN\n3.RoomLink:$LINK');
      print('SavedLeafName: $savedLeafName');
    }
    if (savedAccessToken != null) 
    {
      try 
      {
        final response = await http.post
        (
          Uri.parse('http://120.126.16.222/leafs/create-white-leaf'),
          headers: <String, String>
          {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $savedAccessToken',
          },
          body: jsonEncode(<String, dynamic>
          {
            'region': 'cn-hz',
            'leaf_name':savedLeafName!,
          }),
        );
        if (response.statusCode >= 200 && response.statusCode < 300)
        {
          final responseData = jsonDecode(response.body);
          ROOM_UUID='';
          ROOM_TOKEN='';
          LINK = '';
          APP_ID='';
          if (responseData.isNotEmpty &&responseData[0]['roomData'] != null &&responseData[0]['roomToken'] != null &&responseData[0]['leafData'] != null) 
          {
            final leafData = responseData[0]['leafData'];
            final link = leafData['link']; // 獲取 leafData 內的 link 變數
            final roomData = responseData[0]['roomData'];
            final roomToken = responseData[0]['roomToken'];
            final appIdentifier = responseData[0]['appIdentifier'];
            final uuid = roomData['uuid'];

            final freeLeafModel = FreeLeafModel
            (
              roomToken: roomToken,
              appIdentifier: appIdentifier,
              uuid: uuid,
              link: link,
            );
            if (kDebugMode) 
            {
              print('FreeLeafModel: $freeLeafModel');
            }
            if (kDebugMode) 
            {
              print('Link: $link');
            } // 印出 link 變數的值
            // 更新 constant.dart 的變數值
            APP_ID = appIdentifier;
            ROOM_UUID = uuid;
            ROOM_TOKEN = roomToken;
            LINK = link;
            // 跳轉至 QuickStartPage
            setState(() // 在這裡傳遞給另一個Dart檔
            {
              Navigator.of(context).push
              (
                MaterialPageRoute(builder:(context)=>QuickStartBody(leafName:passLeafName))
              );
            });
          } 
          else 
          {
            if (kDebugMode) 
            {
              print('API response is missing required data');
            }
          }
        } 
        else 
        {
          throw Exception('${response.reasonPhrase},${response.statusCode}');
        }
      } 
      catch (e) 
      {
        if (kDebugMode) 
        {
          print('Error: $e');
        }
      }
    }
    else 
    {
      if (kDebugMode) 
      {
        print('API response is empty');
      }
    }
  }
  Future<void> createPPT()async//創空白ppt檔
  {
    final savedAccessToken=await getAccessToken();
    if(savedAccessToken!=null)
    {
      try
      {
        final response=await http.post
        (
          Uri.parse('http://120.126.16.222/gardenerofleafs/add-ppt-data'),
          headers:<String,String>
          {
            'Content-Type':'application/json',
            'Authorization':'Bearer $savedAccessToken',
          },
          body:jsonEncode(<String,String>
          {
            "uuid":ROOM_UUID,
          }),
        );
        if(response.statusCode>=200&&response.statusCode<300)
        {
          final responseData=jsonDecode(response.body);
          final fileName=responseData[0]['file_name'];
          final filePath=responseData[0]['file_path'];
          await _storage.write(key: 'file_name', value: fileName);
          await _storage.write(key: 'file_path', value: filePath);
          if (kDebugMode) 
          {
            print('請求之後fileName:$fileName');
            print('請求之後filePath:$filePath');
          }
          setState(()
          {
            whitepptDataList=List<Map<String,dynamic>>.from(responseData);
            if (kDebugMode) 
            {
              print('請求之後whitepptDataList:$whitepptDataList');
            }

          });
          if(kDebugMode)
          {
            print('createPPT回傳資料: $responseData');
          }
        }
        else
        {
          final responseData = jsonDecode(response.body);
          final errorMessage=responseData[0]['error_message'];
          if(errorMessage=='此房間不存在'||errorMessage=='此園丁不在房間裡')
          {
            // ignore: use_build_context_synchronously
            showDialog
            (
              context: context, 
              builder: (context)=>AlertDialog
              (
                title: const Text('創空白檔案失敗'),
                content: Text(errorMessage),
                actions: 
                [
                  ElevatedButton
                  (
                    onPressed: ()
                    {
                      Navigator.of(context).pop();
                    }, 
                    child:const Text('OK'),
                  ),
                ],
              ),
            );
          }
          else if(errorMessage=='修改失敗，資料庫沒修改')
          {
            // ignore: use_build_context_synchronously
            showDialog
            (
              context: context, 
              builder: (context)=>AlertDialog
              (
                title: const Text('創空白檔案失敗'),
                content: Text('$errorMessage \n 代表已創建過空白檔案'),
                actions: 
                [
                  ElevatedButton
                  (
                    onPressed: ()
                    {
                      Navigator.of(context).pop();
                    }, 
                    child:const Text('OK'),
                  ),
                ],
              ),
            );
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
  }
  Future<void> getFile()async//取得file
  {
    final savedAccessToken = await getAccessToken();
    final fileName = await getFileName();
    final savedZipFileName='${fileName!.split('.').first}_pptx';
    final savedFileName=fileName.split('.').first;
    await _storage.write(key: 'downloadfile_name', value: savedFileName);
    if(kDebugMode)
    {
      print('SavedZipFileName: $savedZipFileName');
      print('SavedFileName: $savedFileName');
    }
    if (savedAccessToken != null) 
    {
      try 
      {
        final response = await http.post
        (
          Uri.parse('http://120.126.16.222/gardenerofleafs/add-ppt-file'),
          headers: <String, String>
          {
            'Content-Type': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
            'Authorization': 'Bearer $savedAccessToken',
          },
          body: jsonEncode(<String, String>
          {
            'uuid': ROOM_UUID, 
          }),
        );
        if (response.statusCode >= 200 && response.statusCode < 300) 
        {
          final pptxBytes = response.bodyBytes;
          if(!kIsWeb)
          {
            final docDir = await getApplicationDocumentsDirectory();
            final pptxFilePath = '${docDir.path}/$savedFileName.pptx';
            final pptxFile = File(pptxFilePath);
            await pptxFile.writeAsBytes(pptxBytes);
            if(kDebugMode)
            {
              print('PPTX文件已保存在:$pptxFilePath');
              print('所取得的pptx: $pptxFile');
            }
          }
          // else if(kIsWeb)//web
          // {
          //   final archive=ZipDecoder().decodeBytes(fileDataBytes);
          //   for (final file in archive) 
          //   {
          //     if (!file.isFile) continue;
          //     if (file.name == '[Content_Types].xml') 
          //     {
          //       // Handle content types or any other specific files
          //       final content = utf8.decode(file.content);
          //       if (kDebugMode) 
          //       {
          //         print('Content of [Content_Types].xml:');
          //         print(content);
          //       }
          //     }
          //   }
          //   final blob = html.Blob([Uint8List.fromList(fileDataBytes)]);
          //   final url = html.Url.createObjectUrlFromBlob(blob);
          //   //window.open(url,'_blank');//網頁顯示
          //   final anchor=html.AnchorElement(href:url)
          //   ..target='blank'
          //   ..download='$savedFileName';
          //   anchor.click();
          //   if(kDebugMode)
          //   {
          //     print('檔案已下載！');
          //   }        
          // }
          else 
          {
            final responseData = jsonDecode(response.body);
            final errorMessage=responseData[0]['error_message'];
            if (kDebugMode) 
            {
              print('請求getFile失敗: $errorMessage');
            }
          }
        } 
        else
        {
          final responseData = jsonDecode(response.body);
          final errorMessage=responseData[0]['error_message'];
          if(errorMessage=='此房間不存在'||errorMessage=='此園丁不在房間裡')
          {
            // ignore: use_build_context_synchronously
            showDialog
            (
              context: context, 
              builder: (context)=>AlertDialog
              (
                title: const Text('下載空白檔案失敗'),
                content: Text(errorMessage),
                actions: 
                [
                  ElevatedButton
                  (
                    onPressed: ()
                    {
                      Navigator.of(context).pop();
                    }, 
                    child:const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      }
      catch (error) 
      {
        if (kDebugMode) 
        {
          print('Catch Error 請求File失敗:$error');
        }
      }
    }
  }  
  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: const Center
        (
          child: Text('創建自由葉子'), //陰影
        ),
        backgroundColor: Colors.green,
        elevation: 0.0,
      ),
      drawer: Drawer
      (
        backgroundColor: Colors.white,
        child: SingleChildScrollView
        (
          child: Column
          (
            crossAxisAlignment: CrossAxisAlignment.start,
            children: 
            [
              Container
              (
                height: 100,
                color: Colors.green,
                child: Row
                (
                  // ignore: prefer_const_literals_to_create_immutables
                  children:  
                  [
                    const SizedBox(width: 20),
                    if(avatarImageBytes!=null)
                      CircleAvatar
                      (
                        //圓形頭像
                        minRadius: 35,
                        maxRadius: 35,
                        backgroundImage: MemoryImage(avatarImageBytes!),
                      ),
                    const SizedBox(width: 10),
                    Column
                    (
                      children: 
                      [
                        const SizedBox(height: 25),
                        Column
                        (
                          mainAxisAlignment: MainAxisAlignment.start,
                          children:
                          [
                            Text
                            (
                              '名字: $firstName',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                        Column
                        (
                          mainAxisAlignment: MainAxisAlignment.start,
                          children:
                          [
                            Text
                            (
                              '帳號: $account',
                              style: const TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox
              (
                height: 20,
              ),
              Padding
              (
                //一個Padding是一個項目
                padding: const EdgeInsets.only(left: 15),
                child: GestureDetector
                (
                  onTap: (() 
                  {
                  }),
                  child: Row
                  (
                    // ignore: prefer_const_literals_to_create_immutables
                    children: 
                    [
                      const Icon(Icons.person),
                      SizedBox
                      (
                        width: 150,
                        height: 50,
                        child: TextButton
                        (
                          child: const Text
                          (
                            "使用者檔案",
                            style: TextStyle
                            (
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black
                            ),
                          ),
                          onPressed: () 
                          {
                            Navigator.push
                            (
                              context,
                              MaterialPageRoute
                              (
                                builder: (_) =>const GardenerSettingPage()
                              )
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox
              (
                height: 10,
              ),
              ExpansionTile
              (
                //下拉式
                title:const Row
                (
                  // ignore: prefer_const_literals_to_create_immutables
                  children: 
                  [
                    Icon(CupertinoIcons.settings),
                    SizedBox
                    (
                      width: 10,
                    ),
                    Text
                    (
                      "設定",
                      style: TextStyle
                      (
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black
                      ),
                    )
                  ],
                ),
                childrenPadding:const EdgeInsets.only(left: 25), // children padding
                // ignore: prefer_const_literals_to_create_immutables
                children: 
                [
                  Padding
                  (
                    padding: const EdgeInsets.only(left: 15),
                    child: GestureDetector
                    (
                      onTap: (() 
                      {
                      }),
                      child: Row
                      (
                        // ignore: prefer_const_literals_to_create_immutables
                        children:
                        [
                          const Icon
                          (
                            CupertinoIcons.waveform_circle_fill,
                            color: Colors.black87,
                          ),
                          const SizedBox
                          (
                            width: 10,
                          ),
                          const Text
                          (
                            "音量",
                            style: TextStyle
                            (
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87
                            ),
                          ),
                          const Spacer(),
                          CupertinoSwitch
                          (
                            // This bool value toggles the switch.
                            value: switchValue_Volume,
                            activeColor: CupertinoColors.activeGreen,
                            onChanged: (bool? value) 
                            {
                              // This is called when the user toggles the switch.
                              setState(() 
                              {
                                switchValue_Volume = value ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding
                  (
                    padding: const EdgeInsets.only(left: 15),
                    child: GestureDetector
                    (
                      onTap: (() 
                      {
                      }),
                      child: Row
                      (
                        // ignore: prefer_const_literals_to_create_immutables
                        children: 
                        [
                          const Icon(Icons.camera_alt_outlined),
                          const SizedBox
                          (
                            width: 10,
                          ),
                          const Text
                          (
                            "鏡頭",
                            style: TextStyle
                            (
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87
                            ),
                          ),
                          const Spacer(),
                          CupertinoSwitch
                          (
                            // This bool value toggles the switch.
                            value: switchValue_Camera,
                            activeColor: CupertinoColors.activeGreen,
                            onChanged: (bool? value) 
                            {
                              // This is called when the user toggles the switch.
                              setState(() 
                              {
                                switchValue_Camera = value ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding
                  (
                    padding: const EdgeInsets.only(left: 15),
                    child: GestureDetector
                    (
                      onTap: (() 
                      {
                      }),
                      child: Row
                      (
                        // ignore: prefer_const_literals_to_create_immutables
                        children: 
                        [
                          const Icon(Icons.mic),
                          const SizedBox
                          (
                            width: 10,
                          ),
                          const Text
                          (
                            "麥克風",
                            style: TextStyle
                            (
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87
                            ),
                          ),
                          const Spacer(),
                          CupertinoSwitch
                          (
                            // This bool value toggles the switch.
                            value: switchValue_Mic,
                            activeColor: CupertinoColors.activeGreen,
                            onChanged: (bool? value) 
                            {
                              // This is called when the user toggles the switch.
                              setState(()
                              {
                                switchValue_Mic = value ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding
                  (
                    padding: const EdgeInsets.only(left: 15),
                    child: GestureDetector
                    (
                      onTap: (() 
                      {
                      }),
                      child: Row
                      (
                        // ignore: prefer_const_literals_to_create_immutables
                        children: 
                        [
                          const Icon(Icons.notifications),
                          const SizedBox
                          (
                            width: 10,
                          ),
                          const Text
                          (
                            "通知",
                            style: TextStyle
                            (
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87
                            ),
                          ),
                          const Spacer(),
                          CupertinoSwitch
                          (
                            // This bool value toggles the switch.
                            value: switchValue_Notify,
                            activeColor: CupertinoColors.activeGreen,
                            onChanged: (bool? value) 
                            {
                              // This is called when the user toggles the switch.
                              setState(() 
                              {
                                switchValue_Notify = value ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  //more child menu
                ],
              ),
              const SizedBox(height: 10,),
              ElevatedButton
              (
                onPressed: ()async
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
                          //'account': account,
                          'access_token': savedAccessToken,
                        }),
                      );

                      if (response.statusCode == 200) 
                      {
                        // 輸出登出成功的回傳資料
                        //final body = jsonDecode(response.body);
                        const message = '登出成功\n';
                        await showLogoutResultDialog(message);
                        await deleteAccessToken(); // 登出後刪除保存的 access_token
                      } 
                      else 
                      {
                        // 登出失敗
                        final errorMessage = response.body;
                        await showLogoutResultDialog(errorMessage);
                      }
                    } 
                    catch (e) 
                    {
                      if (kDebugMode) 
                      {
                        print('登出失敗：$e');
                      }
                      final errorMessage = '登出失敗：$e';
                      await showLogoutResultDialog(errorMessage);
                    }
                  } 
                  else 
                  {
                    // 沒有保存的 access_token，直接顯示錯誤訊息
                    const errorMessage = '尚未登入，無法進行登出。';
                    await showLogoutResultDialog(errorMessage);
                  }
                }, 
                child: const Text('Logout'),
              ),            
            ],
          ),
        ),
      ),
      body: Column
      (
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>
        [
          Row
          (
            mainAxisAlignment: MainAxisAlignment.start,
            children: 
            [
              IconButton
              (
                tooltip: '返回上一頁',
                icon: const Icon(Icons.arrow_circle_left_outlined, size: 30),
                onPressed: () 
                {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          Center
          (
            child: Container
            (
              alignment: Alignment.center, //橫的
              height: 200.0,
              width:300.0,
              margin: const EdgeInsets.all(20.0),
              decoration: BoxDecoration
              (
                  borderRadius: const BorderRadius.only
                  (
                    topRight: Radius.circular(30.0),
                    topLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                  ),
                  color: Colors.green[300],
                  boxShadow: <BoxShadow>
                  [
                    BoxShadow
                    (
                      color: Colors.grey,
                      offset: Offset.fromDirection(1, 10)
                    ),
                  ]
              ),
              child: Row
              (
                mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>
                  [
                    Column
                    (
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>
                      [
                        SizedBox
                        (
                          width: 250,
                          height: 100,
                          child: Padding
                          (
                            padding: const EdgeInsets.only(left: 30, top: 40),
                            child: TextField
                            (
                              controller: _leafNameController,
                              obscureText: false,
                              decoration: const InputDecoration
                              (
                                prefixIcon: Icon(Icons.eco),
                                hintText: '輸入葉子名稱',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox
                        (
                          width: 250, //width:350
                          height: 100,
                          child: Padding
                          (
                            padding:EdgeInsets.only(left: 40, top: 15, right: 10),
                            child: Text
                            (
                              "本葉子最高上限50人",
                              style: TextStyle
                              (
                                color: Colors.black45,
                                fontSize: 18,
                                fontWeight: FontWeight.w100
                              )
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]
              ),
            ),
          ),
          Row
          (
            mainAxisAlignment: MainAxisAlignment.center,
            children: 
            [
              ElevatedButton
              (
                onPressed: () async 
                {
                  await joinIntoRoom();
                  await createPPT();
                  await getFile();
                },
                style: ElevatedButton.styleFrom
                (
                  foregroundColor: Colors.white, //text
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder
                  (
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 15.0,
                ),
                child: const Padding
                (
                  padding: EdgeInsets.all(10.0),
                  child: Text
                  (
                    '進入葉子',
                    style: TextStyle(fontSize: 20),
                  )
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}