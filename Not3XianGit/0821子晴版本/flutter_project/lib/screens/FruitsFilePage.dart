import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:open_file/open_file.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
class FruitsFilePage extends StatefulWidget 
{
  const FruitsFilePage({Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  FruitsFilePageState createState() =>FruitsFilePageState();
}
class FruitsFilePageState extends State<FruitsFilePage> 
{
  String plantButtonText = "";
  String treeFileNumber = "";
  String treeName = "";
  String treeTypeName = "";
  String localPptxFilePath="";
  String? plantname="";String? fruitnumber="";
  List<String?> fruitsName=[];
  List<String?> fruitsNumber=[];
  List<Map<String,dynamic>> fileInfo=[];
  Map<String,Uint8List> rivImagesMap={};
  File? pptxFile;
  final _storage = const FlutterSecureStorage(); 
  @override
  void initState() 
  {
    super.initState();
    getPlantTotalFruitNumber();
    getNowPlantName();
    getOneFruitInfoList();
  }
  Future<String?> getNowPlantName()async
  {
    // 從 flutter_secure_storage 取得 plant name
    String? nowPlantName = await _storage.read(key:'pressedPlantName');
    setState(() 
    {
      treeName=nowPlantName!;
    });
    if (kDebugMode) 
    {
      print('Get Init nowTreeName : $treeName');
    }
    return nowPlantName;
  }
  Future<String?> getPlantTotalFruitNumber()async
  {
    // 從 flutter_secure_storage 取得plant total fruit number
    String? totalFruitNumber = await _storage.read(key:'total_fruit_num');
    treeFileNumber=totalFruitNumber!;
    if (kDebugMode) 
    {
      print('Get Init totalFruitNumber : $treeFileNumber');
    }
    return totalFruitNumber;
  }
  Future<String?> getPressedFileName()async
  {
    // 從 flutter_secure_storage 取得按下果實按鈕的FileName
    String? buttonPressedFileName = await _storage.read(key:'pressedFileName');
    if (kDebugMode) 
    {
      print('Get getPressedFileName: $buttonPressedFileName');
    }
    return buttonPressedFileName;
  }
  Future<String?> getPressedFileNumber()async
  {
    // 從 flutter_secure_storage 取得按下果實按鈕的FileNumber
    String? buttonPressedFileNumber = await _storage.read(key:'pressedFileNumber');
    if (kDebugMode) 
    {
      print('Get getPressedFileNumber: $buttonPressedFileNumber');
    }
    return buttonPressedFileNumber;
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
  Future<String?> getFilePath()async
  {
    // 從 flutter_secure_storage 取得 pptxFilePath
    String? filePath = await _storage.read(key:'pptxFilePath');
    setState(() 
    {
      localPptxFilePath=filePath!;
    });
    if (kDebugMode) 
    {
      print('Get localPptxFilePath : $localPptxFilePath');
    }
    return filePath;
  }
  Future<List<Map<String,dynamic>>?> getOneFruitInfoList()async
  {
    final fruitInfoList=await _storage.read(key:'list_fruit_info');
    if(fruitInfoList!=null)
    {
      final data=jsonDecode(fruitInfoList);
      if(data is Map<String,dynamic>)
      {
        final List<String?> plantFruitsName=data['saved_fruits_name']?.cast<String>();
        final List<String?> plantFruitsNumber=data['saved_fruits_num']?.cast<String>();
        fruitsName=plantFruitsName;
        fruitsNumber=plantFruitsNumber;
        if (kDebugMode) 
        {
          print('Get List Of FruitsName : $fruitsName');
          print('Get List Of FruitsNumber : $fruitsNumber');
        }
        setState(() 
        {
          for(int i=0;i<plantFruitsName.length;i++)
          {
            fileInfo.add
            (
              {
                'plantAllFruitsName':plantFruitsName[i]??'',
                'plantAllFruitsNumber':plantFruitsNumber[i]??'',
              }
            );
          }
          if (kDebugMode) 
          {
            print('取得對應的List Of FruitsName && FruitsNumber : $fileInfo');
          }
        });
        return fileInfo;
      }
    }
    return null;
  }
  Future<void> showFruitFile()async
  {
    final savedAccessToken=await getAccessToken();
    final savedFileName=await getPressedFileName();
    final savedPlantName=await getNowPlantName();
    final savedFileNumber=await getPressedFileNumber();
    if(savedAccessToken!=null)
    {
      try
      {
        final response=await http.post
        (
          Uri.parse('http://120.126.16.222/plants/show-file'),
          headers: <String,String>
          {
            'Authorization':'Bearer $savedAccessToken',
          },
          body: jsonEncode(<String,String>
          {
            'plant_name':savedPlantName!,
            'fruit_num':savedFileNumber!,
          }),
        );
        if (kDebugMode) 
        {
          print('提供給show-file的PlantName: $savedPlantName；FruitNumber: $savedFileNumber');
        }
        if(response.statusCode>=200&&response.statusCode<405)
        {
          final fruitFileBytes=response.bodyBytes;
          final responseData=response.body;
          if(kDebugMode)
          {
            print('showFruitFile所取得的檔案(文件數據): $fruitFileBytes');
            print('showFruitFile所取得的檔案(文件): $responseData');
          }
          if(!kIsWeb)
          {
            final docDir = await getApplicationDocumentsDirectory();
            final pptxFilePath = '${docDir.path}/$savedFileName';
            final pptxFile = File(pptxFilePath);
            await pptxFile.writeAsBytes(fruitFileBytes);
            if(kDebugMode)
            {
              print('白板PPTX文件已保存在:$pptxFilePath');
              //print('所取得的pptx: $pptxFile');
            }
            await _storage.write(key:'pptxFilePath',value: pptxFilePath);
            //打開檔案
            final result=await OpenFile.open(pptxFilePath);
            if(result.type!=ResultType.done)
            {
              if(kDebugMode)
              {
                print('無法打開白板PPTX文件!');
              }
            }
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
    Size screenSize=MediaQuery.of(context).size;
    double fontSize = screenSize.width * 0.05;
    return Scaffold
    (
      appBar: AppBar
      (
        title: Center
        (
          child:Text
          (
            '檢視$treeName的果實',
            style:const TextStyle(color:Colors.white),
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
          const SizedBox(height:30),
          Padding
          (
            padding: const EdgeInsets.all(0),
            child: Center
            (
              child:Text
              (
                '共有$treeFileNumber個果實(從左至右按照時間順序擺放)',
                style: const TextStyle
                (
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          const SizedBox(height:50),
          Expanded
          (
            child:fileInfo.isEmpty
              ?Center
              (
                child: Column
                (
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: 
                  [
                    Text
                    (
                      '請去創建或加入會議來增加您的果實',
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
                itemCount: fileInfo.length,
                itemBuilder: (context,index)
                {
                  final item=fileInfo[index];
                  final plantAllFruitsName = item['plantAllFruitsName'];
                  final plantAllFruitsNumber = item['plantAllFruitsNumber'];
                  return ElevatedButton
                  (
                    onPressed: ()async//這裡跳轉至打開檔案->第三方軟體開啟
                    {
                      if(kDebugMode)
                      {
                        print('按下第$plantAllFruitsNumber個按鈕取得的值,FruitFileName:$plantAllFruitsName,FruitFileNumber:$plantAllFruitsNumber');
                      }
                      await _storage.write(key: 'pressedFileName', value: plantAllFruitsName);
                      await _storage.write(key: 'pressedFileNumber', value: plantAllFruitsNumber);
                      await showFruitFile().then((_) => getFilePath());
                      // final localFilePath = localPptxFilePath;
                      // openFileWithThirdPartyApp(localFilePath);
                      // if (kDebugMode)
                      // {
                      //   print('按下按鈕時localFilePath: $localFilePath');
                      // }
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
                              alignment: Alignment.center,
                              children: 
                              [
                                Image.asset
                                (
                                  'assets/images/pptx.png',
                                  height:270,
                                  width:screenSize.width*0.7,
                                  fit:BoxFit.contain,
                                ),
                                Align
                                (
                                  alignment: Alignment.center,
                                  child:Text
                                  (
                                    plantAllFruitsName!,
                                    style: TextStyle
                                    (
                                      fontSize: fontSize*0.4,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w500,
                                    ),
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
    );
  }
}