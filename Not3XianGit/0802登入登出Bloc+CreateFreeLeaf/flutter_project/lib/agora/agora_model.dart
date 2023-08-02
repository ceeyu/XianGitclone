import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

final _storage = FlutterSecureStorage(); // 用於存儲 access_token
Future<String?> getAccessToken() async {
  // 從 flutter_secure_storage 取得 access_token
  String? accessToken = await _storage.read(key: 'access_token');
  print('Access Token: $accessToken');
  return accessToken;
}

Future<void> deleteAccessToken() async {
  // 從 flutter_secure_storage 刪除 access_token
  await _storage.delete(key: 'access_token');
}

// 定義LoginModel類，用於儲存API回傳的登入資訊
class LoginModel {
  final String uuid; // 房間UUID
  final String roomToken; // 房間令牌
  final String appIdentifier; // 應用程式識別碼

  const LoginModel({
    required this.roomToken,
    required this.appIdentifier,
    required this.uuid,
  });

  // 從JSON解析資料，並建立LoginModel物件
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      uuid: json['roomData']['uuid'], // 從回傳資料中獲取房間UUID
      roomToken: json['roomToken'], // 從回傳資料中獲取房間令牌
      appIdentifier: json['appIdentifier'], // 從回傳資料中獲取應用程式識別碼
    );
  }
}

// 定義用於登入的函式createLogin，傳入地區region作為參數
Future<List<LoginModel>> createLogin(String region) async {
  final response = await http.post
  (
    Uri.parse(
        'http://120.126.16.222/leafs/create-white-leaf'), // API的URL 0802修改
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $savedAccessToken',
    }, // 設置請求標頭
    body: jsonEncode(<String, String>{
      'region': 'cn-hz', // 將地區資訊轉換為JSON並包裝為請求主體
      'speaker_account': '',
      'manager_account': 'B0929003',
    }),
  );

  // 檢查響應碼，如果響應成功，則解析API回傳的資料
  if (response.statusCode >= 200 && response.statusCode < 300) {
    final responseData = jsonDecode(response.body);
    print(responseData);
  } else {
    // 如果響應碼不在200-299範圍內，拋出錯誤
    throw Exception('${response.reasonPhrase},${response.statusCode}');
  }
}
