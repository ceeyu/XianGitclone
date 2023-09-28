// ignore_for_file: unnecessary_null_comparison
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  int treeFileNumber = 0;
  String treeName = "";
  String treeTypeName = "";
  String returnPlantType="";
  final _storage = const FlutterSecureStorage(); 
  @override
  void initState() 
  {
    super.initState();
    getPlantTotalFruitNumber();
    getNowPlantName();
    getPlantType().then((_) => choosePlantImage());
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
  Future<String?> getPlantType()async
  {
    // 從 flutter_secure_storage 取得 plant image name
    String? treeType = await _storage.read(key:'show_plant_type');
    setState(() 
    {
      treeTypeName=treeType!;
    });
    if (kDebugMode) 
    {
      print('Get Init selectedPlantType : $treeType');
    }
    return treeType;
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
    String? totalFruitNumber = (await _storage.read(key:'total_fruit_num'));
    if (totalFruitNumber != null) 
    {
      treeFileNumber = int.tryParse(totalFruitNumber)!;
      if (treeFileNumber == null) 
      {
        if (kDebugMode) 
        {
          print('Error: Unable to parse totalFruitNumber as int');
        }
      } 
      else 
      {
        if (kDebugMode) 
        {
          print('Get Init totalFruitNumber : $treeFileNumber');
        }
      }
    }
    return totalFruitNumber;
  }
  Future<Image?> choosePlantImage() async 
  {
    Size screenSize = MediaQuery.of(context).size;
    final imagePaths = 
    {
      "櫻花": 
      [
        'assets/plantImages/pink_1.png',
        'assets/plantImages/pink_1_1.png',
        'assets/plantImages/pink_1_2.png',
        'assets/plantImages/pink_2.png',
        'assets/plantImages/pink_2_1.png',
        'assets/plantImages/pink_3.png',
        'assets/plantImages/pink_3_1.png',
        'assets/plantImages/pink_4.png',
        'assets/plantImages/pink_5.png',
      ],
      "綠樹": 
      [
        'assets/plantImages/green_1.png',
        'assets/plantImages/green_1.png',
        'assets/plantImages/green_1.png',
        'assets/plantImages/green_2.png',
        'assets/plantImages/green_2.png',
        'assets/plantImages/green_2.png',
        'assets/plantImages/green_3.png',
        'assets/plantImages/green_3.png',
        'assets/plantImages/green_4.png',
      ],
      "向日葵": 
      [
        'assets/plantImages/yellow_1.png',
        'assets/plantImages/yellow_1.png',
        'assets/plantImages/yellow_1.png',
        'assets/plantImages/yellow_2.png',
        'assets/plantImages/yellow_2.png',
        'assets/plantImages/yellow_2.png',
        'assets/plantImages/yellow_3.png',
        'assets/plantImages/yellow_3.png',
        'assets/plantImages/yellow_4.png',
      ],
      "牡丹花": 
      [
        'assets/plantImages/pink_1.png',
        'assets/plantImages/pink_1_1.png',
        'assets/plantImages/pink_1_2.png',
        'assets/plantImages/pink_2.png',
        'assets/plantImages/pink_2_1.png',
        'assets/plantImages/pink_3.png',
        'assets/plantImages/pink_3_1.png',
        'assets/plantImages/pink_4.png',
        'assets/plantImages/pink_5.png',
      ],
      "茉莉花": 
      [
        'assets/plantImages/pink_1.png',
        'assets/plantImages/pink_1_1.png',
        'assets/plantImages/pink_1_2.png',
        'assets/plantImages/pink_2.png',
        'assets/plantImages/pink_2_1.png',
        'assets/plantImages/pink_3.png',
        'assets/plantImages/pink_3_1.png',
        'assets/plantImages/pink_4.png',
        'assets/plantImages/pink_5.png',
      ],
      "金盞草": 
      [
        'assets/plantImages/yellow_1.png',
        'assets/plantImages/yellow_1.png',
        'assets/plantImages/yellow_1.png',
        'assets/plantImages/yellow_2.png',
        'assets/plantImages/yellow_2.png',
        'assets/plantImages/yellow_2.png',
        'assets/plantImages/yellow_3.png',
        'assets/plantImages/yellow_3.png',
        'assets/plantImages/yellow_4.png',
      ],
    };
    if (treeTypeName != null && imagePaths.containsKey(treeTypeName)) 
    {
      final paths = imagePaths[treeTypeName];
      if (paths != null) 
      {
        int index = (treeFileNumber>=0&&treeFileNumber < 5)
            ? 0
              :(treeFileNumber>=5&&treeFileNumber<8)
                ? 1
                : (treeFileNumber>=8&&treeFileNumber<10)
                  ? 2
                  : (treeFileNumber>=10&&treeFileNumber<13)
                    ? 3
                    : (treeFileNumber>=13&&treeFileNumber<15)
                      ? 4
                      : (treeFileNumber>=15&&treeFileNumber<21)
                        ? 5
                        : (treeFileNumber>=21&&treeFileNumber<25)
                          ? 6
                          : (treeFileNumber>=25&&treeFileNumber<50)
                              ? 7
                              : 8;
        if (index <= paths.length) 
        {
          return Image.asset
          (
            paths[index],
            width: screenSize.width * 0.5,
            height: 200,
          );
        }
      }
    }
    return null;
  }
  @override
  Widget build(BuildContext context) 
  {
    // ignore: unused_local_variable
    double treeWidth = MediaQuery.of(context).size.width - 40;
    //Size screenSize=MediaQuery.of(context).size;
    //double fontSize = screenSize.width * 0.05;
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
        elevation: 0.0,
        leading:IconButton
        (
          icon: const Icon(Icons.arrow_back_ios,color: Colors.white,),
          onPressed: ()
          {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Column
      (
        children: 
        [
          Padding
          (
            padding: const EdgeInsets.only(top: 60),
            child:Text
            (
              treeName,
              style:const TextStyle
              (
                color: Colors.black,
                fontSize: 50,
                fontWeight: FontWeight.normal
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded
          (
            child: FutureBuilder<Image?>
            (
              future: choosePlantImage(),
              builder: (context, snapshot) 
              {
                if (snapshot.connectionState == ConnectionState.waiting) 
                {
                  return const CircularProgressIndicator();
                } 
                else if (snapshot.hasError) 
                {
                  return Text('植物圖出現錯誤: ${snapshot.error}');
                } 
                else if (snapshot.hasData) 
                {
                  return LayoutBuilder
                  (
                    builder: ((context, constraints) 
                    {
                      final image=snapshot.data;
                      final imageHeight=image?.height?.toDouble()?? 0.0;
                      final imageWidth=image?.width?.toDouble()??1.0;
                      final buttonHeight = constraints.maxWidth * (imageHeight/imageWidth);
                      return Center
                      (
                          child:ElevatedButton
                          (
                            style: ElevatedButton.styleFrom
                            (
                              elevation: 0.0,
                              fixedSize: Size.fromHeight(buttonHeight),
                            ),
                            onPressed: () 
                            {
                              Navigator.push
                              (
                                context,
                                MaterialPageRoute(builder: (_) => const FruitsFilePage()),
                              );
                            },
                            child: Transform.scale
                            (
                              scale:2.5,
                              child:snapshot.data!, 
                            ),
                          ),
                      );
                    }),
                  );
                } 
                else 
                {
                  return const Text('没有plantImages可用');
                }
              },
            ),
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