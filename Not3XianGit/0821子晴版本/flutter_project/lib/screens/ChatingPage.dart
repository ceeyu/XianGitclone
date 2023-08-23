import 'dart:convert';
// import 'dart:html'as html;
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/HomePage.dart';
import 'package:flutter_project/screens/GardenerSettingPage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter_project/agora/quick_start.dart'; // 引入QuickStartPage
import 'package:flutter_project/agora/constants.dart';
import 'package:screenshot/screenshot.dart';
import 'package:file_saver/file_saver.dart';
class ChatingPage extends StatefulWidget 
{
  final String? selectedName;
  final String? selectedAccount;
  const ChatingPage
  (
    {
      Key?key,
      this.selectedName, 
      this.selectedAccount,
    }
  ):super(key:key);
  @override
  //ignore: library_private_types_in_public_api
  _ChatingPageState createState()=>_ChatingPageState();
}
class _ChatingPageState extends State<ChatingPage>
{
  // ignore: non_constant_identifier_names
  bool switchValue_Volume = true;
  // ignore: non_constant_identifier_names
  bool switchValue_Mic = true;
  // ignore: non_constant_identifier_names
  bool switchValue_Camera = true;
  // ignore: non_constant_identifier_names
  bool switchValue_Notify = true;
  final _storage = const FlutterSecureStorage(); // 用於存儲 access_token
  String? firstName;
  String? account;
  String? avatarFileName;
  Uint8List? avatarImageBytes;
  Uint8List? otheravatarImageBytes;
  String? selectedName;
  String? selectedAccount;
  File? file;//目前web端要用html,移動端要用io//File file;
  List<Map<String, dynamic>> chatDataList = [];
  bool isLinkMessage=false;
  List<Map<String,dynamic>> linkDataList=[];
  List<Map<String,dynamic>> joinDataList=[];
  final TextEditingController _messageController=TextEditingController();
  List<Map<String,dynamic>> whitepptDataList=[];
  final ScreenshotController _screenshotController = ScreenshotController();
  @override
  void initState()
  {
    super.initState();
    getUserInfo();
    showChatRecord();
    showOtherAvatar();
    selectedName=widget.selectedName;
    selectedAccount=widget.selectedAccount;
  }
  Future<String?> getlink()async
  {
    // 從 flutter_secure_storage 取得 access_token
    String? savedLink = await _storage.read(key:'link');
    if (kDebugMode) 
    {
      print('Leaf Link: $savedLink');
    }
    return savedLink;
  }
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
  Future<String?> getRoomUUID()async
  {
    // 從 flutter_secure_storage 取得 access_token
    String? roomUUID = await _storage.read(key:'roomUUID');
    if (kDebugMode) 
    {
      print('RoomUUID: $roomUUID');
    }
    return roomUUID;
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
  Future<void> getUserInfo() async
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
            if(kDebugMode)
            {
              print('檔名:$avatarFileName');
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
  Future<void> getAvatar()async
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
  Future<void> showLogoutResultDialog(String message) async
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
  Future<void> showChatRecord()async
  {
    final savedAccessToken=await getAccessToken();
    if(savedAccessToken!=null)
    {
      try
      {
        final response=await http.post
        (
          Uri.parse('http://120.126.16.222/chats/record'),
          headers:<String,String>
          {
            'Content-Type':'application/json',
            'Authorization':'Bearer $savedAccessToken',
          },
          body:jsonEncode(<String,String>
          {
            'other_account':selectedAccount??'',
          }),
        );
        if(response.statusCode>=200&&response.statusCode<300)
        {
          List<dynamic> responseData=jsonDecode(response.body);
          if(responseData.isNotEmpty)
          {
            if(responseData[0]['error_message']=='兩方帳號相同，不能自己跟自己聊天，所以不會有資料')
            {
              setState(() 
              {
                chatDataList=List<Map<String,dynamic>>.from(responseData);
              });
              if(kDebugMode)
              {
                print('ChatingPage API 回傳error_message: $chatDataList');
              }
            }
            else if(responseData[0]['message']!='他倆沒有聊天紀錄'&&responseData[0]['error_message']!='兩方帳號相同，不能自己跟自己聊天，所以不會有資料')
            {
              for(var chat in chatDataList)
              {
                if(chat['isLink']=='true')
                {
                  isLinkMessage=true;
                }
                else
                {
                  isLinkMessage=false;
                }
              }
              setState(() 
              {
                chatDataList=List<Map<String,dynamic>>.from(responseData);
              });
              if(kDebugMode)
              {
                print('ChatingPage API 回傳error_message: $chatDataList');
              }
            }
            else
            {
              setState(() 
              {
                chatDataList=List<Map<String,dynamic>>.from(responseData);
              });
              if(kDebugMode)
              {
                print('ChatingPage API 回傳error_message: $chatDataList');
              }
            }
          }
          else
          {
            setState(() 
            {
             chatDataList=[]; 
             return;
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
  }
  Future<void> sendMessage(String message)async
  {
    final savedAccessToken=await getAccessToken();
    if(savedAccessToken!=null)
    {
      try
      {
        final response=await http.post
        (
          Uri.parse('http://120.126.16.222/chats/send-message'),
          headers:<String,String>
          {
            'Content-Type':'application/json',
            'Authorization':'Bearer $savedAccessToken',
          },
          body:jsonEncode(<String,String>
          {
            'other_account':selectedAccount!,
            'chat_data':message,
          }),
        );
        if(response.statusCode>=200&&response.statusCode<300)
        {
          List<dynamic> responseData=jsonDecode(response.body);
          if(kDebugMode)
          {
            print('Send-Message ResponseData: $responseData');
          }
          if(responseData.isNotEmpty)
          {
            if(responseData[0]['error_message']=='發送方和接收方相同，不可以自己傳給自己')
            {
              final errorMessage=responseData[0]['error_message'];
              if(kDebugMode)
              {
                print('ChatingPage API 回傳error_message: $errorMessage');
              }
              setState(() 
              {
                showDialog
                (
                  context: context,
                  builder: (BuildContext context) 
                  {
                    return AlertDialog
                    (
                      title: const Text('傳送失敗'),
                      content: Text(errorMessage),
                      actions: <Widget>
                      [
                        ElevatedButton
                        (
                          child: const Text('返回搜尋他人'),
                          onPressed: () 
                          {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              });
            }
            else
            {
              setState(() 
              {
                chatDataList=List<Map<String,dynamic>>.from(responseData);
                if (kDebugMode) 
                {
                  print('傳送之後chatDatalist:$chatDataList');
                }
              });
              if(kDebugMode)
              {
                print('ChatingPage API 回傳資料: $responseData');
                print('SendMessage()selectedAccount內容:$selectedAccount');
              }
              if(message.startsWith('Someone sent you a link :')&&responseData[0]['isLink']=='true')
              {
                isLinkMessage=true;
              }
              else
              {
                isLinkMessage=false;
              }
            }
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
  }
  Future<void> handleLinkClick(String link)async 
  {
    const storage=FlutterSecureStorage();
    await storage.write(key: 'link', value: link);
    await joinLinkRoom(link);
    // ignore: use_build_context_synchronously
    showDialog
    (
      context: context, 
      builder: (context)=>AlertDialog
      (
        title: const Text('邀請加入葉子'),
        content: Text('Someone sent you a link : $link'),
        actions: 
        [
          ElevatedButton
          (
            onPressed: ()
            {
              Navigator.of(context).pop();
            }, 
            child:const Text('不加入'),
          ),
          ElevatedButton
          (
            onPressed: () async 
            {
              await joinRoom();//加入葉子
              await createPPT();//創空白ppt檔
              await getFile();//取得空白檔案
              captureScreenshotMobile();
              //ignore: use_build_context_synchronously
              Navigator.push
              (
                context,
                MaterialPageRoute
                (
                  builder: (context) => const QuickStartPage(),
                ),
              );
            },
            child: const Text('加入'),
          ),
        ],
      ),
    );
  }
  Future<void> joinLinkRoom(String link)async
  {
    final savedAccessToken=await getAccessToken();
    if(savedAccessToken!=null)
    {
      try
      {
        final response=await http.post
        (
          Uri.parse('http://120.126.16.222/leafs/catch-link'),
          headers:<String,String>
          {
            'Content-Type':'application/json',
          },
          body:jsonEncode(<String,String>
          {
            "link":"Someone sent you a link : $link",
          }),
        );
        if(kDebugMode)
        {
          print(link);
        }
        if(response.statusCode>=200&&response.statusCode<300)
        {
          final responseData=jsonDecode(response.body);
          final roomUUID=responseData[0]['roomUUID'];
          final roomToken=responseData[0]['roomToken'];
          final appID=responseData[0]['appID'];
          const storage=FlutterSecureStorage();
          await storage.write(key:'roomUUID',value:roomUUID);//add_roomUUID
          await storage.write(key: 'roomToken', value: roomToken);
          await storage.write(key: 'appID', value: appID);
          // 更新 constant.dart 的變數值
          APP_ID = appID;
          ROOM_UUID = roomUUID;
          ROOM_TOKEN = roomToken;
          LINK = link;
          setState(() 
          {
            linkDataList=List<Map<String,dynamic>>.from(responseData);
            // if (kDebugMode) 
            // {
            //   print('傳送之後linkDatalist:$linkDataList');
            // }
          });
          if(kDebugMode)
          {
            //print('joinLinkRoom 回傳資料: $responseData');
            print('RoomUUID: $roomUUID');
            print('RoomToken: $roomToken');
            print('AppID: $appID');
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
  }
  Future<void> joinRoom()async//加入葉子
  {
    final savedAccessToken=await getAccessToken();
    final savedRoomUUID=await getRoomUUID();
    if(savedAccessToken!=null)
    {
      try
      {
        final response=await http.post
        (
          Uri.parse('http://120.126.16.222/gardenerofleafs/add-gardener'),
          headers:<String,String>
          {
            'Content-Type':'application/json',
            'Authorization':'Bearer $savedAccessToken',
          },
          body:jsonEncode(<String,String>
          {
            "uuid":savedRoomUUID!,
          }),
        );
        if(kDebugMode)
        {
          print("Add-gardeners: $savedRoomUUID");
        }
        if(response.statusCode>=200&&response.statusCode<300)
        {
          final responseData=jsonDecode(response.body);
          if(responseData[0]['error_message']=='error_message: Room not found !')
          {
            // ignore: use_build_context_synchronously
            showDialog
            (
              context: context, 
              builder: (context)=>AlertDialog
              (
                title: const Text('加入葉子失敗'),
                content: const Text('此房間不存在'),
                actions: 
                [
                  ElevatedButton
                  (
                    onPressed: ()
                    {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }, 
                    child:const Text('OK'),
                  ),
                ],
              ),
            );
          }
          setState(() 
          {
            joinDataList=List<Map<String,dynamic>>.from(responseData);
            if (kDebugMode) 
            {
              print('傳送之後joinDatalist:$joinDataList');
            }
          });
          if(kDebugMode)
          {
            print('joinRoom 回傳資料: $responseData');
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
  }
  Future<void> showOtherAvatar()async
  {
    final savedAccessToken=await getAccessToken();
    if(savedAccessToken!=null)
    {
      try
      {
        final response=await http.post
        (
          Uri.parse('http://120.126.16.222/gardeners/get-other-avatar'),
          headers: <String,String>
          {
            'Authorization':'Bearer $savedAccessToken',
          },
          body: jsonEncode(<String,String>
          {
            'account':selectedAccount??'',//other_account
          }),
        );
        if(response.statusCode>=200&&response.statusCode<405)
        {
          setState(() 
          {
            otheravatarImageBytes=response.bodyBytes;
          });
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
  Future<void> createPPT()async//創空白ppt檔
  {
    final savedAccessToken=await getAccessToken();
    final savedRoomUUID=await getRoomUUID();
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
            "uuid":savedRoomUUID!,
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
    final savedRoomUUID = await getRoomUUID();
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
            'uuid': savedRoomUUID!, 
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
  void captureScreenshotMobile() async //移動端截圖
  {
    _screenshotController.capture().then((Uint8List? image)
    {
      FileSaver.instance.saveFile
      (
        name: 'test.jpg',
        bytes: image!,
        mimeType:MimeType.jpeg, 
      );
    });
    //getSavedScreenshot();
    if(kDebugMode)
    {
      print('截圖成功!');
    }
  }
  void getSavedScreenshot() async 
  {
    try 
    {
      final appDir = await getApplicationDocumentsDirectory();
      final filePath = '${appDir.path}/test.jpg'; // 检查实际的文件名和路径
      final savedScreenshotFile = File(filePath);
      if (await savedScreenshotFile.exists()) 
      {
        // 文件存在，你可以使用 savedScreenshotFile 进行操作，例如显示、分享等
        if (kDebugMode) {
          print('找到并操作保存的截图文件');
        }
      } else {
        if (kDebugMode) {
          print('截图文件不存在');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('获取截图文件时出现错误: $e');
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
          child:Text
          (
            'Not3',
            style:TextStyle(color:Colors.white),
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 0.0, //陰影
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
              const SizedBox(height: 20,),
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
              const SizedBox(height: 10,),
              ExpansionTile
              (
                //下拉式
                title: const Row
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
                        //mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
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
      body: SafeArea
      (
        child: Column
        (
          children: 
          [
            Row
            (
              mainAxisAlignment: MainAxisAlignment.start,
              children:<Widget>
              [
                IconButton
                (
                  tooltip: '返回上一頁',
                  icon:const Icon(Icons.arrow_circle_left_outlined,size:30),
                  onPressed: (){Navigator.of(context).pop();},
                ),
              ],
            ),
            Row
            (
              mainAxisAlignment: MainAxisAlignment.center,
              children: 
              [
                const SizedBox(width: 20),
                if(otheravatarImageBytes!=null) 
                  CircleAvatar
                  (
                    minRadius: 35,
                    maxRadius: 35,
                    backgroundImage: MemoryImage(otheravatarImageBytes!),
                  ),
                const SizedBox(width: 10),
                Text
                (
                  '$selectedName',
                  textAlign: TextAlign.center,
                  style:const TextStyle
                  (
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            Expanded
            (
              child:chatDataList.isEmpty
                ?const Center
                (
                  child: Text
                  (
                    '目前與他/她沒有聊天紀錄',
                    style:TextStyle(fontSize: 16),
                  ),
                )
                :ListView.builder
                (
                  reverse:false,
                  itemCount: chatDataList.length,
                  itemBuilder: (context,index)
                  {
                    Map<String,dynamic>chat=chatDataList[index];
                    if(chat.containsKey('error_message'))
                    {
                      String errorMessage=chat['error_message'];
                      if(errorMessage=='兩方帳號相同，不能自己跟自己聊天，所以不會有資料')
                      {
                        return const Center
                        (
                          child: Text
                          (
                            '不能自己跟自己聊天噢',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }
                      else if(errorMessage=='他倆沒有聊天紀錄')
                      {
                        return const Center
                        (
                          child: Text
                          (
                            '目前與他/她沒有聊天紀錄',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }                      
                    }
                    else
                    {
                      bool isSender=chat['sender_firstname']==widget.selectedName;//not me
                      Color bubbleColor=isSender?const Color.fromARGB(255, 14, 159, 203):const Color.fromARGB(255, 14, 100, 44);
                      if(isLinkMessage||chat['isLink']=='true')
                      {
                        return InkWell
                        (
                          onTap: ()
                          {
                            handleLinkClick(chat['chat_data']);
                          },
                          child:BubbleSpecialThree
                          (
                            text: 'Someone sent you a link : ${chat['chat_data']}',
                            color:bubbleColor,
                            textStyle: const TextStyle
                            (
                              color:Colors.white,
                              fontSize: 16,
                            ),
                            tail: true,
                            isSender: !isSender,
                          ),
                        );
                      }
                      else
                      {
                        return BubbleSpecialThree
                        (
                          text: chat['chat_data'],
                          color:bubbleColor,
                          textStyle: const TextStyle
                          (
                            color:Colors.white,
                            fontSize: 16,
                          ),
                          tail: true,
                          isSender: !isSender,
                        );
                      }
                    }
                    return const SizedBox.shrink();
                  },
                ),
            ),
            Expanded
            (
              child:MessageBar
              (
                onSend:(message)async
                {
                  if(message.isNotEmpty)
                  {
                    await sendMessage(message);
                    _messageController.clear();
                    setState((){});
                  }
                  if (kDebugMode) 
                  {
                    print('MessageBar傳送: $message');
                  }
                },
                actions: 
                [
                  InkWell
                  (
                    child: const Icon
                    (
                      Icons.add,
                      color:Colors.black,
                      size:24,
                    ),
                    onTap: (){},
                  ),
                  Padding
                  (
                    padding: const EdgeInsets.only(left:8,right:8),
                    child: InkWell
                    (
                      child: Icon
                      (
                        Icons.camera_alt,
                        color:Colors.blue.shade100,
                        size:24,
                      ),
                      onTap: (){},
                    ),
                  ),
                  Padding
                  (
                    padding: const EdgeInsets.only(left:8,right:8),
                    child: InkWell
                    (
                      child: Icon
                      (
                        Icons.emoji_emotions,
                        color:Colors.green.shade100,
                        size:24,
                      ),
                      onTap: (){},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),    
    );
  }
}