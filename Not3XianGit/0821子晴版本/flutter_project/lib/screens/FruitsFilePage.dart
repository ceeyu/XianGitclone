import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
  List<String?> fruitsName=[];
  List<String?> fruitsNumber=[];
  Map<String,Uint8List> rivImagesMap={};
  File? pptxFile;
  final _storage = const FlutterSecureStorage(); 
  @override
  void initState() 
  {
    super.initState();
    getPlantTotalFruitNumber();
    getNowPlantName().then((_)
    {
      getFruitInfoList();
      showFruitFile().then((_) => getFilePath());
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
      print('Get localPptxFilePath : $localPptxFilePath ');
    }
    return filePath;
  }
  Future<String?> getFruitNumber()async
  {
    // 從 flutter_secure_storage 取得 fruit_num
    String? fruitNumber = await _storage.read(key:'fruit_num');
    if (kDebugMode) 
    {
      print('Get Init FruitNumber : $fruitNumber ');
    }
    return fruitNumber;
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
  Future<Map<String,dynamic>?> getFruitInfoList()async
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
        return
        {
          'plantAllFruitsName':plantFruitsName,
          'plantAllFruitsNumber':plantFruitsNumber,
        };
      }
    }
    return null;
  }
  Future<void> showFruitFile()async
  {
    final savedAccessToken=await getAccessToken();
    final savedFruitNumber=await getPlantTotalFruitNumber();
    if(savedAccessToken!=null)
    {
      try
      {
        final fruitNum=int.parse(savedFruitNumber!);
        final maxIndex=min(fruitNum,fruitsName.length);
        for(int i=0;i<maxIndex;i++)
        {
          final plantname=fruitsName[i];
          final fruitnumber=fruitsNumber[i];
          final response=await http.post
          (
            Uri.parse('http://120.126.16.222/plants/show-file'),
            headers: <String,String>
            {
              'Authorization':'Bearer $savedAccessToken',
            },
            body: jsonEncode(<String,String>
            {
              'plant_name':plantname!,
              'fruit_num':fruitnumber!,
            }),
          );
          if (kDebugMode) 
          {
            print('每一項fruitname: $plantname；每一項fruitnumber: $fruitnumber');
          }
          if(response.statusCode>=200&&response.statusCode<405)
          {
            final fruitFileBytes=response.bodyBytes;
            setState(() 
            {
              rivImagesMap[plantname]=fruitFileBytes;
            });
            if(!kIsWeb)
            {
              final docDir = await getApplicationDocumentsDirectory();
              final pptxFilePath = '${docDir.path}/$plantname';
              final pptxFile = File(pptxFilePath);
              await pptxFile.writeAsBytes(fruitFileBytes);
              if(kDebugMode)
              {
                print('白板PPTX文件已保存在:$pptxFilePath');
                print('所取得的pptx: $pptxFile');
              }
              await _storage.write(key:'pptxFilePath',value: pptxFilePath);
              //await _storage.write(key:'pptxFilePath_$plantname',value: pptxFilePath);
            }
            if(kDebugMode)
            {
              print('showFruitFile所取得的檔案(所有): $fruitFileBytes');
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
  Future<void> openFileWithThirdPartyApp(String pptxfilePath) async 
  {
    final uri = Uri.file(pptxfilePath);
    final url='shareddocuments://${uri.path}';
    if (kDebugMode)
    {
      print('openFileWithThirdPartyApp的fileUrl: $url');
    }
    try
    {
      if (await canLaunchUrl(Uri.parse(url))) 
      {
        await launchUrl(Uri.parse(url));
      } 
      else 
      {
        throw 'Could not launch to 檔案';
      }
    }
    catch(error)
    {
      if (kDebugMode)
      {
        print('Error opening Files app: $error');
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
            child:fruitsName.isEmpty
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
                itemCount: fruitsName.length,
                itemBuilder: (context,index)
                {
                  final plantName=fruitsName[index];
                  final plantImageBytes = rivImagesMap[plantName];
                  return ElevatedButton
                  (
                    onPressed: ()async//這裡跳轉至打開檔案->第三方軟體開啟
                    {
                      final localFilePath = localPptxFilePath;
                      if (kDebugMode)
                      {
                        print('按下按鈕時localFilePath: $localFilePath');
                      }
                      openFileWithThirdPartyApp(localFilePath);
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
                                plantImageBytes!=null
                                  ?Image.asset
                                  (
                                    'assets/images/pptx.png',
                                    height:270,
                                    width:screenSize.width*0.7,
                                    fit:BoxFit.contain,
                                  )
                                  :const SizedBox(),
                                Align
                                (
                                  alignment: Alignment.center,
                                  child:Text
                                  (
                                    plantName!,
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