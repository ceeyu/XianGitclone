import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/screens/ChatingPage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
class ChatPage extends StatefulWidget 
{
  const ChatPage({super.key});
  @override
  //ignore: library_private_types_in_public_api
  _ChatPageState createState()=>_ChatPageState();
}
class _ChatPageState extends State<ChatPage>
{
  final TextEditingController _enterfirstnameController=TextEditingController();
  final _storage = const FlutterSecureStorage(); // 用於存儲 access_token
  String? firstName;
  String? account;
  String? avatarFileName;
  Uint8List? avatarImageBytes;
  List<dynamic> searchResults=[];
  List<dynamic> searchAccounts=[];
  List<dynamic> senderFirstName=[];
  List<dynamic> receiverFirstName=[];
  List<dynamic> sendTime=[];
  List<dynamic> chatData=[];
  static String? selectedResult;
  String? selectedAccount;
  Future<String?> getAccessToken()async
  {
    String? accessToken = await _storage.read(key:'access_token');
    return accessToken;
  }
  Future<void> deleteAccessToken() async 
  {
    await _storage.delete(key: 'access_token');
  }
  Future<void> searchName(String firstName)async
  {
    final savedAccessToken=await getAccessToken();
    final searchFirstName =_enterfirstnameController.text;
    if(savedAccessToken!=null&&searchFirstName.isNotEmpty)
    {
      try 
      {
        final response = await http.post
        (
          Uri.parse('http://120.126.16.222/gardeners/search'),
          headers: <String, String>
          {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $savedAccessToken',
          },
          body: jsonEncode(<String, String>
          {
            'enter_firstname': searchFirstName,
          }),
        );
        if (response.statusCode >= 200&&response.statusCode<405) 
        {
          final  userInfo = json.decode(response.body);
          if(userInfo.isNotEmpty)
          {
            if(userInfo[0]['error_message']=='搜尋不到資料')
            {
              setState(() 
              {
                searchResults = userInfo.map((item) => item['error_message']).toList();
                searchAccounts=userInfo.map((item)=>item['error_message']).toList();
                selectedResult=searchResults.isNotEmpty?searchResults[0]:'搜尋不到資料';
                selectedAccount = searchAccounts.isNotEmpty ? searchAccounts[0] :'搜尋不到資料';
              });
              // ignore: use_build_context_synchronously
              showDialog
              (
                context: context,
                builder: (BuildContext context) 
                {
                  return AlertDialog
                  (
                    title: const Text('搜尋結果'),
                    content: Text(userInfo[0]['error_message']),
                    actions: <Widget>
                    [
                      ElevatedButton
                      (
                        child: const Text('重新搜尋'),
                        onPressed: () 
                        {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
            else
            {
              setState(() 
              {
                searchResults = userInfo.map((item) => item['first_names']).toList();
                searchAccounts=userInfo.map((item)=>item['account']).toList();
                selectedResult=searchResults.isNotEmpty?searchResults[0]:'搜尋不到資料';
                selectedAccount = searchAccounts.isNotEmpty ? searchAccounts[0] :'搜尋不到資料';
              });
            }
          }
        } 
      } 
      catch (e) 
      {
        if(kDebugMode)
        {
          print('Error:firstname_search請求出錯,$e');
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
  Future<void> showChatData()async
  {
    final savedAccessToken=await getAccessToken();
    if(savedAccessToken!=null&&selectedAccount!=null)
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
            'other_account':selectedAccount!,
          }),
        );
        if(response.statusCode>=200&&response.statusCode<300)
        {
          final responseData=jsonDecode(response.body);
          senderFirstName = responseData.map((item) => item['sender_firstname']).toList();
          receiverFirstName=responseData.map((item) => item['receiver_firstname']).toList();
          sendTime=responseData.map((item) => item['send_time']).toList();
          chatData=responseData.map((item) => item['chat_data']).toList();
        }
        else
        {
          if(kDebugMode)
          {
            print('showChatData Error:請求失敗\n$response\nStatusCode: ${response.statusCode}');
          }
        }
      }
      catch(error)
      {
        if(kDebugMode)
        {
          print('showChatData Catch Error: $error');
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
      body:SingleChildScrollView
      (
        physics: const BouncingScrollPhysics(),
        child:Container
        (
          padding:const EdgeInsets.all(16.0),
          child:Column
          (
            mainAxisAlignment: MainAxisAlignment.start,
            children: 
            [
              Row
              (
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                [
                  Column
                  (
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                    [
                      Column
                      (
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: 
                        [
                          SizedBox
                          (
                            width: screenSize.width*0.5,
                            height:100,
                            child:Padding
                            (
                              padding:const EdgeInsets.only(top:35,left:5),
                              child:TextField
                              (
                                controller:_enterfirstnameController,
                                onSubmitted: (value)
                                {
                                  searchName(value);
                                },
                                decoration:InputDecoration
                                (
                                  hintText:  "搜尋名字",
                                  hintStyle: TextStyle(color:Colors.grey.shade600),
                                  prefixIcon: Icon(Icons.search,color:Colors.grey.shade600,size:50),
                                  suffixIcon:IconButton
                                  (
                                    onPressed: ()
                                    {
                                      _enterfirstnameController.clear();
                                    },
                                    icon: const Icon(Icons.clear),
                                  ),
                                  filled:true,
                                  fillColor: Colors.grey.shade100,
                                  contentPadding: const EdgeInsets.all(20),
                                  enabledBorder: OutlineInputBorder
                                  (
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(color:Colors.grey.shade100)
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column
                  (
                    children: <Widget>
                    [
                      SizedBox
                      (
                        width: screenSize.width*0.2,
                        height: screenSize.height*0.07,
                        child:Padding
                        (
                          padding:const EdgeInsets.only(top:25,left:20),
                          child:MaterialButton
                          (
                            onPressed: ()
                            {
                              setState(()
                              {
                                searchName(_enterfirstnameController.text);
                              });
                            },
                            color:const Color.fromARGB(255,0,158,71),
                            child: Text('搜尋',style:TextStyle(color:Colors.white,fontSize: fontSize*0.7))
                          ),
                        ),

                      ),
                    ],
                  ),
                ],
              ),
              if(searchResults.isNotEmpty)
              Row
              (
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                [
                  SizedBox
                  (
                    width: screenSize.width*0.4,
                    height:screenSize.height*0.07,
                    child:DropdownButtonHideUnderline
                    (
                      child:DropdownButton<String>
                      (
                        borderRadius: BorderRadius.circular(20),
                        value:selectedResult, 
                        isExpanded: true,
                        onChanged: (newValue)
                        {
                          setState(() 
                          {
                            selectedResult=newValue;
                            selectedAccount=searchAccounts[searchResults.indexOf(newValue)];
                          });
                        }, 
                        items: searchResults.map<DropdownMenuItem<String>>((dynamic value)
                        {
                          return DropdownMenuItem
                          (
                            value:value,
                            child: Center
                            (
                              child:Text
                              (
                                value!,
                                style: TextStyle
                                (
                                  fontSize: fontSize*0.7,
                                ),
                              ),
                            ),
                          );
                        },).toList(),
                      ),
                    ),
                  ),
                  const Column(children:[SizedBox(width: 20,),],),
                  Column
                  (
                    children: <Widget>
                    [
                      SizedBox
                      (
                        width: screenSize.width*0.25,
                        height: screenSize.height*0.07,
                        child:Padding
                        (
                          padding:const EdgeInsets.only(top:25,left:40),
                          child:MaterialButton
                          (
                            onPressed: ()async
                            {
                              final savedAccessToken = await getAccessToken();
                              // ignore: unrelated_type_equality_checks
                              if (savedAccessToken != null) 
                              {
                                try 
                                {
                                  if(selectedResult=='搜尋不到資料')
                                  {
                                    // ignore: use_build_context_synchronously
                                    showDialog
                                    (
                                      context: context,
                                      builder: (BuildContext context) 
                                      {
                                        return AlertDialog
                                        (
                                          title: const Text('搜尋結果'),
                                          content: const Text('搜尋不到資料'),
                                          actions: <Widget>
                                          [
                                            ElevatedButton
                                            (
                                              child: const Text('確定'),
                                              onPressed: () 
                                              {
                                                Navigator.of(context).pop();
                                              }
                                            ),
                                          ],
                                        );
                                      }
                                    );
                                  }
                                  else
                                  {
                                    await showChatData();
                                    // ignore: use_build_context_synchronously
                                    Navigator.push
                                    (
                                      context,
                                      MaterialPageRoute
                                      (
                                        builder: (context)=>ChatingPage
                                        (
                                          selectedName: selectedResult,
                                          selectedAccount: selectedAccount,//seach得到的account
                                        ),
                                      ),
                                    );
                                  }
                                } 
                                catch (error) 
                                {
                                  if (kDebugMode) 
                                  {
                                    print('Catch Error: $error');
                                  }
                                }
                              }                          
                            },
                            color:const Color.fromARGB(255,0,158,71),
                            child:Text('交流',style:TextStyle(color:Colors.white,fontSize: fontSize*0.7))
                          ),
                        ),

                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 100),
              Center
              (
                child: Column
                (
                  children: 
                  [
                    Text
                    (
                      '請搜尋其他使用者進行交流',
                      style: TextStyle
                      (
                        fontSize: fontSize,
                        color: Colors.blueGrey,
                      ),
                    ),
                    Image.asset('assets/images/StartFruits_2.png',width: screenSize.width * 0.5,height: screenSize.width * 0.5),                      
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}