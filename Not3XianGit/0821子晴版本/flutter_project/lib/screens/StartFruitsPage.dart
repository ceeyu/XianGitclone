import 'dart:convert';
import 'dart:math';
import 'package:flutter_project/HomePage.dart';
import 'package:flutter_project/screens/AnimationFruitsPage.dart';
import 'package:flutter_project/screens/OpenFruitsPage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class StartFruitsPage extends StatefulWidget 
{
  const StartFruitsPage({super.key});
  @override
  //ignore: library_private_types_in_public_api
  _StartFruitsPageState createState()=>_StartFruitsPageState();
}
class _StartFruitsPageState extends State<StartFruitsPage>
{
  int pageIndex=0;
  List<Widget> pageItem=[];
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
  Map<String,Uint8List> plantImagesMap={};
  List<dynamic> plantNameList=[];
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
  Future<String?> getPlantNumber()async
  {
    // 從 flutter_secure_storage 取得 plant_num
    String? plantNumber = await _storage.read(key:'plant_num');
    if (kDebugMode) 
    {
      print('PlantNumber : $plantNumber ');
    }
    return plantNumber;
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
  Future<void> showAllPlant()async
  {
    final savedAccessToken=await getAccessToken();
    if(savedAccessToken!=null)
    {
      try
      {
        final response=await http.post
        (
          Uri.parse('http://120.126.16.222/plants/show-all-plants'),
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
          final responseData=jsonDecode(response.body);
          if(kDebugMode)
          {
            print('ShowAllPlant API :$responseData');
          }
          if(responseData[0]['plant_name']!=null&&responseData[0]['plant_num']!=null)
          {
            plantNameList=List<dynamic>.from(responseData[0]['plant_name']);
            final plantNumber=responseData[0]['plant_num'];
            await _storage.write(key: 'plant_num', value: plantNumber);
            if(kDebugMode)
            {
              print('取得所有資料夾名稱 :$plantNameList');
              print('取得資料夾總數量 :$plantNumber');
            }
          }
          else
          {
            final responseData=jsonDecode(response.body);
            final errorMessage=responseData[0]['error_message'];
            if (kDebugMode) 
            {
              print('ErrorMessage目前沒有樹: $errorMessage');
            }
          }
        }
        else
        {
          if(kDebugMode)
          {
            print('Error:請求失敗,$response,${response.statusCode}');
          }
        }
      }
      catch(error)
      {
        if(kDebugMode)
        {
          print('Error:請求出錯,$error');
        }
      }
    }
    else 
    {
      if(kDebugMode)
      {
        print('沒有保存的access_token');
      }
    }      
  } 
  Future<void> showPlantPicture()async
  {
    final savedAccessToken=await getAccessToken();
    final savedPlantNumber=await getPlantNumber();
    if(savedAccessToken!=null&&savedPlantNumber!=null)
    {
      try
      {
        final plantNumber=int.parse(savedPlantNumber);
        final maxIndex=min(plantNumber,plantNameList.length);
        for(int i=0;i<maxIndex;i++)
        {
          final plantname=plantNameList[i];
          if(kDebugMode)
          {
            print('for loop plantname:$plantname');
          }
          final response=await http.post
          (
            Uri.parse('http://120.126.16.222/plants/show-plant-picture'),
            headers: <String,String>
            {
              'Authorization':'Bearer $savedAccessToken',
            },
            body: jsonEncode(<String,String>
            {
              'plant_name':plantname,
            }),
          );
          if(response.statusCode>=200&&response.statusCode<405)
          {
            final plantImageBytes = response.bodyBytes;
            setState(() 
            {
              plantImagesMap[plantname]=plantImageBytes;
            });
          }
          else
          {
            if(kDebugMode)
            {
              print('Error:請求失敗,$response,${response.statusCode}');
            }
          }
        }
      }
      catch(error)
      {
        if(kDebugMode)
        {
          print('Error:請求出錯,$error');
        }
      }
    }
    else 
    {
      if(kDebugMode)
      {
        print('沒有保存的access_token');
      }
    } 
  } 
  @override
  void initState()
  {
    super.initState();
    getUserInfo();
    showAllPlant().then((value) => showPlantPicture());
  }
  @override
  Widget build(BuildContext context) 
  {
    Size screenSize=MediaQuery.of(context).size;
    double fontSize = screenSize.width * 0.05;
    return Scaffold
    (
      body:Column
      (
        mainAxisAlignment:MainAxisAlignment.center,
        children:
        [
          Center
          (
            child:plantNameList.isNotEmpty
              ?Center
              (
                child:Column
                (
                  children: 
                  [
                    const SizedBox(height: 10),
                    Text
                    (
                      "目前已有的資料夾",
                      style: TextStyle
                      (
                        color: Colors.black45,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 10),
                  ],
                ),
              )
              :const SizedBox(),
          ),
          Expanded
          (
            child:plantNameList.isEmpty
              ?Center
              (
                child: Column
                (
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: 
                  [
                    Image.asset('assets/images/StartFruits_2.png',width: screenSize.width*0.5,height: 150),
                    Text
                    (
                      '請按右下角的按鈕創建資料夾',
                      style:TextStyle
                      (
                        fontSize: fontSize,
                        color: Colors.black45,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
              :GridView.builder
              (
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount
                (
                  crossAxisCount: 3,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 30,
                ),
                itemCount: plantNameList.length,
                itemBuilder: (context,index)
                {
                  final plantName=plantNameList[index];
                  final plantImageBytes = plantImagesMap[plantName];
                  return ElevatedButton
                  (
                    onPressed: ()//這裡跳轉至打開不同資料夾裡的頁面
                    {
                      // setState(() 
                      // {
                      // });
                      Navigator.push
                      (
                        context,MaterialPageRoute(builder:(_)=> const AnimationFruitsPage())
                      );
                    },
                    style: ElevatedButton.styleFrom
                    (
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(30),
                    ),
                    child:SizedBox
                    (
                      width: double.infinity,
                      height: double.infinity,
                      child:Column
                      (
                        children: 
                        [
                          Expanded
                          (
                            child:Stack
                            (
                              alignment: Alignment.bottomCenter,
                              children: 
                              [
                                plantImageBytes!=null
                                  ?Image.memory
                                  (
                                    plantImageBytes,
                                    height:270,
                                    width:screenSize.width*0.7,
                                    fit:BoxFit.contain,//校外
                                  )
                                  :const SizedBox(),
                                Text
                                (
                                  plantName,
                                  style: TextStyle
                                  (
                                    fontSize: fontSize*0.7,
                                    color: Colors.black45,
                                    fontWeight: FontWeight.w500,
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
              ),
          ),
        ],
      ),
      floatingActionButton:FloatingActionButton
      (
        backgroundColor: Colors.green,
        shape:const CircleBorder(),
        onPressed: ()
        {
          Navigator.push
          (
            context,MaterialPageRoute(builder:(_)=> const OpenFruitsPage())
          );
        },
        tooltip: '創建資料夾',
        child:const Icon
        (
          Icons.add,
          color: Colors.white,
        ),
      ), 
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
