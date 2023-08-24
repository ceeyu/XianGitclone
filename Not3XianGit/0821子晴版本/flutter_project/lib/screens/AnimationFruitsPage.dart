//目前沒有在用的頁面
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
class AnimationFruitsPage extends StatefulWidget 
{
  const AnimationFruitsPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AnimationFruitsPageState createState() => _AnimationFruitsPageState();
}
class _AnimationFruitsPageState extends State<AnimationFruitsPage> 
{
  Artboard? _riveArtboard;
  // ignore: unused_field
  StateMachineController? _controller;
  SMIInput<double>? _progress;
  String plantButtonText = "";
  int _treeProgress = 0;
  final int _treeMaxProgress = 60; 
  final _storage = const FlutterSecureStorage(); 
  List<Map<String,dynamic>> plantFruitsList=[];
  List<dynamic> plantFruitsInfo=[];
  List<String> plantFruitsName=[];
  List<String> plantFruitsNumber=[];
  //Map<String,Uint8List> FruitFilesMap={};
  @override
  void initState() 
  {
    super.initState();
    plantButtonText = "Plant";
    showPlantFruitInfo();
    rootBundle.load('assets/tree_demo.riv').then
    (
      (data) async 
      {
        final file = RiveFile.import(data);
        final artboard = file.mainArtboard;
        var controller = StateMachineController.fromArtboard(artboard, 'Grow');
        if (controller != null) 
        {
          artboard.addController(controller);
          _progress = controller.findInput('input');
        }
        setState(() => _riveArtboard = artboard);
      },
    );
  }
  void _onPlantButtonPressed() // 按下Plant按鈕後，TreeProgress增加20，直到等於或超過60時重置為0
  {
    setState(() 
    {
      _treeProgress += 20; //增加級距
      if (_treeProgress > _treeMaxProgress) 
      {
        _treeProgress = 0;
      }
      _progress?.value = _treeProgress.toDouble();
    });
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
  Future<String?> getFruitNumber()async
  {
    // 從 flutter_secure_storage 取得 fruit_num
    String? fruitNumber = await _storage.read(key:'fruit_num');
    if (kDebugMode) 
    {
      print('FruitNumber : $fruitNumber ');
    }
    return fruitNumber;
  }
  Future<void> showPlantFruitInfo()async//要修按下的按鈕
  {
    final savedAccessToken=await getAccessToken();
    if(savedAccessToken!=null)
    {
      try
      {
        final response=await http.post
        (
          Uri.parse('http://120.126.16.222/plants/show-fruit-info'),
          headers: <String,String>
          {
            'Authorization':'Bearer $savedAccessToken',
          },
          body: jsonEncode(<String,String>
          {
            'plant_name':'資料夾一',//按下所選資料夾，目前寫死來測試
          }),
        );
        if(response.statusCode>=200&&response.statusCode<405)
        {
          final responseData=jsonDecode(response.body);
          
          if(responseData[0]['果實數量']!=null&&responseData[0]['fruit info']!=null)
          {
            plantFruitsList=List<Map<String,dynamic>>.from(responseData);
            plantFruitsInfo=plantFruitsList.map((item)=>item['fruit info']).toList();
            for(var item in plantFruitsInfo)
            {
              for(var fruitInfo in item)
              {
                var plantName=fruitInfo['plant_name'];
                var plantNumber=fruitInfo['fruit_num'];
                plantFruitsNumber.add(plantNumber.toString());
                plantFruitsName.add(plantName);
              }
            }
              if(kDebugMode)
              {
                print('showPlantFruitInfo回傳plantFruitsList :$plantFruitsList');
                print('取得資料夾裡檔案資料 :$plantFruitsInfo');
                print('取得資料夾裡檔案名稱 :$plantFruitsName');
                print('取得資料夾裡檔案ID(fruit_num) :$plantFruitsNumber');
                
              }
            final plantFruitNumber=responseData[0]['果實數量'];
            await _storage.write(key: 'fruit_num', value: plantFruitNumber);
            if (kDebugMode) 
            {
              print('取得資料夾裡檔案總數量 :$plantFruitNumber');
            }
          }
          else
          {
            final responseData=jsonDecode(response.body);
            final errorMessage=responseData[0]['error_message'];
            if (kDebugMode) 
            {
              print('ErrorMessage目前沒有資料夾及檔案: $errorMessage');
            }
          }
        }
        else
        {
          if(kDebugMode)
          {
            print('ShowPlantFruitInfo Error:請求失敗,$response,${response.statusCode}');
          }
        }
      }
      catch(error)
      {
        if(kDebugMode)
        {
          print('ShowPlantFruitInfo Catch Error:請求出錯,$error');
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
  Future<void> showFruitFile()async
  {
    final savedAccessToken=await getAccessToken();
    final savedFruitNumber=await getFruitNumber();
    if(savedAccessToken!=null)
    {
      try
      {
        final fruitNum=int.parse(savedFruitNumber!);
        final maxIndex=min(fruitNum,plantFruitsName.length);
        for(int i=0;i<maxIndex;i++)
        {
          final plantname=plantFruitsName[i];
          final fruitnumber=plantFruitsNumber[i];
          final response=await http.post
          (
            Uri.parse('http://120.126.16.222/plants/show-file'),
            headers: <String,String>
            {
              'Authorization':'Bearer $savedAccessToken',
            },
            body: jsonEncode(<String,String>
            {
              'plant_name':plantname,
              'fruit_num':fruitnumber,
            }),
          );
          print('plantname:$plantname;fruitnumber:$fruitnumber');
          if(response.statusCode>=200&&response.statusCode<405)
          {
            final responseData=response.bodyBytes;
            if(kDebugMode)
            {
              print('showFruitFile所取得的檔案(所有): $responseData');
            }
          }
          else
          {
            if(kDebugMode)
            {
              print('showFruitFile Error:請求失敗,$response,${response.statusCode}');
            }
          }
        }
      }
      catch(error)
      {
        if(kDebugMode)
        {
          print('showFruitFile Catch Error:請求出錯,$error');
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
  Widget build(BuildContext context) 
  {
    // ignore: unused_local_variable
    double treeWidth = MediaQuery.of(context).size.width - 40;
    return Scaffold
    (
      appBar: AppBar
      (
        title: const Center
        (
          child:Text
          (
            '檢視資料夾',
            style:TextStyle(color:Colors.white),
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 0.0, //陰影
      ),
      backgroundColor: Colors.white,
      body: Column
      (
        children: 
        [
          const Padding
          (
            padding: EdgeInsets.only(top: 60),
            child: Text
            (
              "您的樹與花朵",
              style: TextStyle
              (
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.normal
              ),
            ),
          ),
          ElevatedButton
          (
            onPressed: ()
            {
              showFruitFile();
            }, 
            child: const Text('TEST SHOW')
          ),
          Expanded
          (
            child: Center
            (
              child: _riveArtboard == null
                  ? const SizedBox()
                  : Rive(alignment: Alignment.center, artboard: _riveArtboard!),
            ),
          ),
          Padding
          (
            padding: const EdgeInsets.only(bottom: 10),
            child: Text
            (
              '$_treeProgress個檔案',
              style: const TextStyle
              (
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          const Padding
          (
            padding: EdgeInsets.only(bottom: 30),
            child: Text
            (
              "櫻花",
              style: TextStyle
              (
                color: Colors.black,
                fontSize: 40,
                fontWeight: FontWeight.normal
              ),
            ),
          ),
          Padding
          (
            padding: const EdgeInsets.only(bottom: 90),
            child: MaterialButton
            (
              height: 40.0,
              minWidth: 180.0,
              elevation: 8.0,
              shape: RoundedRectangleBorder
              (
                borderRadius: BorderRadius.circular(5.0),
              ),
              color: Colors.green,
              textColor: Colors.white,
              onPressed: _onPlantButtonPressed,
              splashColor: Colors.redAccent,
              child: Text(plantButtonText),
            ),
          ),
        ],
      ),
    );
  }
}