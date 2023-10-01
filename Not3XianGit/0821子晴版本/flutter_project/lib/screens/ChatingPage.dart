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
  final _storage = const FlutterSecureStorage();
  String? firstName;
  String? account;
  String? avatarFileName;
  Uint8List? avatarImageBytes;
  Uint8List? otheravatarImageBytes;
  String? selectedName;
  String? selectedAccount;
  String? passLeafName;
  File? file;
  List<Map<String, dynamic>> chatDataList = [];
  bool isLinkMessage=false;
  List<Map<String,dynamic>> linkDataList=[];
  List<Map<String,dynamic>> joinDataList=[];
  final TextEditingController _messageController=TextEditingController();
  List<Map<String,dynamic>> whitepptDataList=[];
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
    String? savedLink = await _storage.read(key:'link');
    return savedLink;
  }
  Future<String?> getAccessToken()async
  {
    String? accessToken = await _storage.read(key:'access_token');
    return accessToken;
  }
  Future<String?> getRoomUUID()async
  {
    String? roomUUID = await _storage.read(key:'roomUUID');
    return roomUUID;
  }
  Future<String?> getFileName() async
  {
    String? fileName = await _storage.read(key:'file_name');
    return fileName;
  }
  Future<void> deleteAccessToken() async 
  {
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
        );
        if (response.statusCode == 200) 
        {
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
    await showDialog
    (
      context: context,
      builder: (context) => AlertDialog
      (
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
  Future<void> logOut()async
  {
    final savedAccessToken=await getAccessToken();
    if (savedAccessToken != null) 
    {
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
      const errorMessage = '尚未登入，無法進行登出。';
      await showLogoutResultDialog(errorMessage);
    }
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
            }
            else
            {
              setState(() 
              {
                chatDataList=List<Map<String,dynamic>>.from(responseData);
              });
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
            print('showChatRecord Error:請求失敗\n$response\nStatusCode: ${response.statusCode}');
          }
        }
      }
      catch(error)
      {
        if(kDebugMode)
        {
          print('showChatRecord Catch Error: $error');
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
          if(responseData.isNotEmpty)
          {
            if(responseData[0]['error_message']=='發送方和接收方相同，不可以自己傳給自己')
            {
              final errorMessage=responseData[0]['error_message'];
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
              });
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
            print('sendMessage Error:請求失敗\n$response\nStatusCode: ${response.statusCode}');
          }
        }
      }
      catch(error)
      {
        if(kDebugMode)
        {
          print('sendMessage Catch Error: $error');
        }
      }
    }
  }
  Future<void> handleLinkClick(String link)async 
  {
    await _storage.write(key:'link',value:link);
    final savedRoomLink=await getlink();
    String linkMessage='';
    String enterLeaf='';
    if(savedRoomLink=='目前這Room連結已不存在')
    {
      setState(() 
      {
        linkMessage='此葉子連結已關閉！';
        enterLeaf='無法加入葉子';
      });
    }
    else
    {
      setState(() 
      {
        linkMessage='Someone sent you a link : $savedRoomLink';
        enterLeaf='邀請加入葉子';
      });
      await joinLinkRoom(link);
    }
    // ignore: use_build_context_synchronously
    showDialog
    (
      context: context, 
      builder: (context)=>AlertDialog
      (
        title: Text(enterLeaf),
        content: Text(linkMessage),
        actions: 
        [
          if(linkMessage!='此葉子連結已關閉！')
            ElevatedButton
            (
              onPressed: () async 
              {
                await joinRoom();//加入葉子
                await createPPT();//創空白ppt檔
                await getWhiteFile();//取得空白檔案
                //ignore: use_build_context_synchronously
                Navigator.of(context).push
                (
                  MaterialPageRoute
                  (
                    builder: (context) => QuickStartBody(leafName:passLeafName),
                  ),
                );
              },
              child: const Text('加入'),
            ),
          ElevatedButton
          (
            onPressed: ()
            {
              Navigator.of(context).pop();
            }, 
            child:const Text('關閉'),
          ),
        ],
      ),
    );
  }
  Future<void> joinLinkRoom(String roomlink)async
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
            "link":"Someone sent you a link : $roomlink",
          }),
        );
        if(kDebugMode)
        {
          print('Print RoomeLink:$roomlink');
        }
        if(response.statusCode>=200&&response.statusCode<405)
        {
          final responseData=jsonDecode(response.body);
          if(responseData[0]['roomUUID']!=null)
          {
            final roomUUID=responseData[0]['roomUUID'];
            final roomToken=responseData[0]['roomToken'];
            final appID=responseData[0]['appID'];
            final leafName=responseData[0]['leaf_name'];
            await _storage.write(key:'roomUUID',value:roomUUID);//add_roomUUID
            await _storage.write(key: 'roomToken', value: roomToken);
            await _storage.write(key: 'appID', value: appID);
            if(leafName!=null)
            {
              await _storage.write(key: 'leaf_name', value: leafName);
              passLeafName=leafName;
              // 更新 constant.dart 的變數值
              APP_ID = appID;
              ROOM_UUID = roomUUID;
              ROOM_TOKEN = roomToken;
              LINK = roomlink;
            }
            await _storage.write(key: 'link', value: roomlink);
            setState(() 
            {
              linkDataList=List<Map<String,dynamic>>.from(responseData);
            });
          }
          else if(responseData[0]['error_message']=="Link not found !")
          {
            await _storage.write(key: 'link', value: '目前這Room連結已不存在');
            if(kDebugMode)
            {
              print('目前這Room連結已不存在');
            }
          }
        }
        else
        {
          if(kDebugMode)
          {
            print('joinLinkRoom Error:請求失敗\n$response\nStatusCode: ${response.statusCode}');
          }
        }
      }
      catch(error)
      {
        if(kDebugMode)
        {
          print('joinLinkRoom Catch Error: $error');
        }
      }
    }
  }
  Future<void> joinRoom()async
  {
    final savedAccessToken=await getAccessToken();
    final savedRoomUUID=await getRoomUUID();
    if(savedAccessToken!=null&&savedRoomUUID!=null)
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
            "uuid":savedRoomUUID,
          }),
        );
        if(response.statusCode>=200&&response.statusCode<405)
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
          });
        }
        else
        {
          if(kDebugMode)
          {
            print('joinRoom Error:請求失敗\n$response\nStatusCode: ${response.statusCode}');
          }
        }
      }
      catch(error)
      {
        if(kDebugMode)
        {
          print('joinRoom Catch Error: $error');
        }
      }
    }
    else
    {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
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
            'account':selectedAccount!,//other_account
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
            print('showOtherAvatar Error:請求圖檔失敗,$response,${response.statusCode}');
          }
        }
      }
      catch(error)
      {
        if(kDebugMode)
        {
          print('showOtherAvatar Error:請求圖檔出錯,$error');
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
  Future<void> createPPT()async
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
          setState(()
          {
            whitepptDataList=List<Map<String,dynamic>>.from(responseData);
          });
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
          print('createPPT Catch Error: $error');
        }
      }
    }
  }
  Future<void> getWhiteFile()async
  {
    final savedAccessToken = await getAccessToken();
    final savedRoomUUID = await getRoomUUID();
    final fileName = await getFileName();
    final savedFileName=fileName!.split('.').first;
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
              print('空白PPTX文件已保存在:$pptxFilePath');
            }
          }
          else 
          {
            final responseData = jsonDecode(response.body);
            final errorMessage=responseData[0]['error_message'];
            if (kDebugMode) 
            {
              print('getWhiteFile請求getFile失敗: $errorMessage');
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
          print('getWhiteFile Catch Error 請求File失敗:$error');
        }
      }
    }
  }
  @override
  Widget build(BuildContext context)
  {
    Size screenSize=MediaQuery.of(context).size;
    double fontSize = screenSize.width * 0.05;
    return Scaffold
    (
      appBar: AppBar
      (
        title: const Text
        (
          '聊天室',
          style:TextStyle(color:Colors.white),
        ),
        centerTitle: true,
        leading:Builder
        (
          builder: (BuildContext context)
          {
            return IconButton
            (
              onPressed:()
              {
                Scaffold.of(context).openDrawer();
              }, 
              icon: const Icon(Icons.menu),
            );
          },
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
                        const SizedBox(height: 35),
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
                    SizedBox(width: 60,),
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
                        // Navigator.push(
                        //	 context,
                        //	 new MaterialPageRoute(
                        //		 builder: (context) => new VendorVenuePage()));
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
                      onTap: (() {}),
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
                ],
              ),
              const SizedBox(height: 10,),
              Padding
              (
                padding: const EdgeInsets.only(left: 15),
                child: GestureDetector
                (
                  onTap: (() {}),
                  child: Row
                  (
                    // ignore: prefer_const_literals_to_create_immutables
                    children: 
                    [
                      const Icon(Icons.logout_sharp),
                      SizedBox
                      (
                        width: 150,
                        height: 50,
                        child: TextButton
                        (
                          child: const Text
                          (
                            "登出",
                            style: TextStyle
                            (
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black
                            ),
                          ),
                          onPressed: () async
                          {
                            await logOut();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
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
                  style:TextStyle
                  (
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            Expanded
            (
              child:chatDataList.isEmpty
                ?Center
                (
                  child: Text
                  (
                    '目前與他/她沒有聊天紀錄',
                    style:TextStyle(fontSize: fontSize),
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
                        return Center
                        (
                          child: Text
                          (
                            '不能自己跟自己聊天噢',
                            style: TextStyle(fontSize: fontSize),
                          ),
                        );
                      }
                      else if(errorMessage=='他倆沒有聊天紀錄')
                      {
                        return Center
                        (
                          child: Text
                          (
                            '目前與他/她沒有聊天紀錄',
                            style: TextStyle(fontSize: fontSize),
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
                        if(kDebugMode){print('Print Link: ${chat['chat_data']}');}
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
                            textStyle: TextStyle
                            (
                              color:Colors.white,
                              fontSize: fontSize,
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
                          textStyle:TextStyle
                          (
                            color:Colors.white,
                            fontSize: fontSize,
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
                actions: //其他上傳圖片等擴充功能
                const 
                [
                  // InkWell
                  // (
                  //   child: const Icon
                  //   (
                  //     Icons.add,
                  //     color:Colors.black,
                  //     size:24,
                  //   ),
                  //   onTap: (){},
                  // ),
                  // Padding
                  // (
                  //   padding: const EdgeInsets.only(left:8,right:8),
                  //   child: InkWell
                  //   (
                  //     child: Icon
                  //     (
                  //       Icons.camera_alt,
                  //       color:Colors.blue.shade100,
                  //       size:24,
                  //     ),
                  //     onTap: (){},
                  //   ),
                  // ),
                  // Padding
                  // (
                  //   padding: const EdgeInsets.only(left:8,right:8),
                  //   child: InkWell
                  //   (
                  //     child: Icon
                  //     (
                  //       Icons.emoji_emotions,
                  //       color:Colors.green.shade100,
                  //       size:24,
                  //     ),
                  //     onTap: (){},
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),    
    );
  }
}