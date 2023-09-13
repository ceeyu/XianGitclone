//import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_project/screens/FruitsFilePage.dart';
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
  String treeFileNumber = "";
  String treeName = "";
  String treeTypeName = "";
  ByteData? plantRivImage;
  final int _treeMaxProgress = 60; 
  final _storage = const FlutterSecureStorage(); 
  @override
  void initState() 
  {
    super.initState();
    getPlantTotalFruitNumber();
    getPlantType();
    getNowPlantName();
    plantButtonText = "Plant";
    showRivFile().then((_)
    {
      setState(() 
      {
       _riveArtboard=RiveFile.import(plantRivImage!).mainArtboard;
      });
    });
    // rootBundle.load('assets/tree_demo.riv').then
    // (
    //   (data) async 
    //   {
    //     final file = RiveFile.import(data);
    //     final artboard = file.mainArtboard;
    //     var controller = StateMachineController.fromArtboard(artboard, 'Grow');
    //     if (controller != null) 
    //     {
    //       artboard.addController(controller);
    //       _progress = controller.findInput('input');
    //     }
    //     setState(() => _riveArtboard = artboard);
    //   },
    // );
  }
  void _onPlantButtonPressed()
  {
    int treeProgress=0;
    treeProgress=treeFileNumber as int;
    if (kDebugMode) 
    {
      print('Get TreeProgress: $treeProgress');
    }
    setState(() 
    {
      treeProgress += 20; //增加級距
      if (treeProgress > _treeMaxProgress) 
      {
        treeProgress = 0;
      }
      _progress?.value = treeProgress.toDouble();
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
      print('Init FruitNumber : $fruitNumber ');
    }
    return fruitNumber;
  }
  Future<String?> getPlantType()async//要修改成plant的種類->加API？
  {
    // 從 flutter_secure_storage 取得 plant image name
    String? treeType = await _storage.read(key:'selectedPlantImage');
    treeTypeName=treeType!;
    if (kDebugMode) 
    {
      print('Get Init selectedPlantImage : $treeType');
    }
    return treeType;
  }
  Future<String?> getNowPlantName()async
  {
    // 從 flutter_secure_storage 取得 plant name
    String? nowPlantName = await _storage.read(key:'pressedPlantName');
    treeName=nowPlantName!;
    if (kDebugMode) 
    {
      print('Get Init nowTreeName : $treeName');
    }
    return nowPlantName;
  }
  Future<String?> getPlantTotalFruitNumber()async
  {
    // 從 flutter_secure_storage 取得plant total fruit number
    String? totalFruitNumber = (await _storage.read(key:'total_fruit_num'));
    treeFileNumber=totalFruitNumber!;
    if (kDebugMode) 
    {
      print('Get Init totalFruitNumber : $treeFileNumber');
    }
    return totalFruitNumber;
  }
  Future<void> showRivFile()async
  {
    final savedAccessToken=await getAccessToken();
    final savedPressedPlantName=await getNowPlantName();
    if(savedAccessToken!=null)
    {
      try
      {
          if(kDebugMode)
          {
            print('showRivFile所按下的plantname:$savedPressedPlantName');
          }
          final response=await http.post
          (
            Uri.parse('http://120.126.16.222/plants/show-riv'),
            headers: <String,String>
            {
              'Authorization':'Bearer $savedAccessToken',
              'Content-Type':'application/octet-stream',
            },
            body: jsonEncode(<String,String>
            {
              'plant_name':savedPressedPlantName!,
            }),
          );
          if(response.statusCode>=200&&response.statusCode<405)
          {
            final plantRivImageBytes = response.bodyBytes;
            plantRivImage=ByteData.sublistView(Uint8List.fromList(plantRivImageBytes));
            if(kDebugMode)
            {
              print('show-riv請求成功：$plantRivImageBytes');
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
          Padding
          (
            padding: const EdgeInsets.only(top: 60),
            child: Text
            (
              treeName,
              style:const TextStyle
              (
                color: Colors.black,
                fontSize: 40,
                fontWeight: FontWeight.normal
              ),
            ),
          ),
          const SizedBox(height: 30),
          Expanded
          (
            child:ElevatedButton
            (
              style: ElevatedButton.styleFrom
              (
                elevation: 0.0, 
              ),
              onPressed: ()
              {
                //_onPlantButtonPressed();
                Navigator.push
                (
                  context,MaterialPageRoute(builder:(_)=> const FruitsFilePage())
                );

              }, 
              child: _riveArtboard == null
                    ? const SizedBox()
                     : Rive(artboard: _riveArtboard!),//alignment: Alignment.center, 
            )
          ),
          Padding
          (
            padding: const EdgeInsets.only(bottom: 10),
            child: Text
            (
              '目前這棵植物共有$treeFileNumber個果實',
              style: const TextStyle
              (
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          Padding
          (
            padding: const EdgeInsets.only(bottom: 250),
            child: Text
            (
              '植物種類為$treeTypeName',
              style: const TextStyle
              (
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }
}