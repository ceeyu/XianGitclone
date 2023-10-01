import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/HomePage.dart';
import 'package:flutter_project/MyPage.dart';
import 'package:flutter_project/Repository/LoginBloc_Repo.dart';
import 'package:flutter_project/SignUp.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class LoginPage extends StatefulWidget
{
  const LoginPage({Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage>
{
  final TextEditingController _accountcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  Future<List<dynamic>>? _futureLogin;
  final LoginRepository _loginRepository=LoginRepository();
  bool _showSignUpButton=false;
  final _storage =const FlutterSecureStorage();
  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title:const Center(child:Text("登入",style: TextStyle(color: Colors.white))),
        backgroundColor: Colors.green,
      ),
      body:Container
      (
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        child:Column
        (
          children: <Widget>
          [
            Row
            (
              mainAxisAlignment: MainAxisAlignment.start,
              children:<Widget>
              [
                IconButton
                (
                  tooltip: '返回首頁',
                  icon:const Icon(Icons.arrow_circle_left_outlined,size:30),
                  onPressed: (){Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=>const HomePage()));},
                ),
              ],
            ),
            Expanded
            (
              child:Center
              (
                child:(_futureLogin==null) 
                ? buildColumn()
                :buildFutureBuilder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> saveAccessToken(String accessToken) async
  {
    await _storage.write(key: 'access_token', value: accessToken);
  }
  void login() async
  {
    final account=_accountcontroller.text;
    final password=_passwordcontroller.text;
    await _storage.write(key:'savedLoginPassword',value:password);
    setState(() 
    {
      _futureLogin=_loginRepository.login(account,password);
    });
  }
  Center buildColumn()
  {
    return Center
    (
      child:Column
      (
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget> 
        [
          Align
          (
            alignment: Alignment.center,
            child:SizedBox
            (
              width: 300,
              height: 80,
              child:TextFormField
              (
                controller: _accountcontroller,
                decoration: const InputDecoration
                (
                  hintText: 'Enter Account',
                  labelText: "帳號",
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            ),
          ),
          Align
          (
            child:SizedBox
            (
              width: 300,
              height: 80,
              child:TextFormField
              (
                controller: _passwordcontroller,
                obscureText: true,
                decoration: const InputDecoration
                (
                  hintText: 'Enter Password',
                  labelText: "密碼",
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          Align
          (
            child:SizedBox
            (
              width: 150,
              height: 48,
              child: ElevatedButton
              (
                style:ElevatedButton.styleFrom
                (
                  backgroundColor: const Color.fromARGB(255, 204, 189, 247),
                  foregroundColor: Colors.white,//TextColor
                  textStyle: const TextStyle
                  (
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  )
                ),
                onPressed: login,
                child: const Text('登入'),
              ),
            ),
          ),
          if(_showSignUpButton)
              SizedBox
              (
                width: 150,
                height: 48,
                child:ElevatedButton
                (
                  style: ElevatedButton.styleFrom
                  (
                    backgroundColor: const Color.fromARGB(255, 241, 219, 169),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle
                    (
                      fontWeight: FontWeight.bold,
                      fontSize:14,
                    ),
                  ),
                  onPressed: ()
                  {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=>const SignUpPage()));
                  },
                  child: const Text("註冊"),
                ),
              ),

        ],
      ),
    );
  }
  FutureBuilder<List<dynamic>> buildFutureBuilder()
  {
    return FutureBuilder<List<dynamic>>
    (
      future: _futureLogin,
      builder: (context, snapshot)
      {
        if (snapshot.connectionState == ConnectionState.waiting) 
        {
          return const CircularProgressIndicator();
        } 
        else if (snapshot.hasData) 
        {
          final data=snapshot.data!;
          if(data.isNotEmpty && data[0]['access_token']!=null)
          {
            saveAccessToken(data[0]['access_token']);
            final errorMessage=data[0]['error_message'];
            if(errorMessage==null)
            {
              WidgetsBinding.instance.addPostFrameCallback((_) 
              {
                Navigator.of(context).pushReplacement
                (
                  MaterialPageRoute(builder: (_) => const MyPage1()),
                );
              });
            }
            return Container();
          }
          else
          {
            String errorMessage=data[0]['error_message'];
            if(errorMessage=="Account error")
            {
              WidgetsBinding.instance.addPostFrameCallback((_) 
              { 
                _showErrorAlert("Please try again or go to Sign Up");
              });
            }
            else if(errorMessage=="Password error")
            {
              WidgetsBinding.instance.addPostFrameCallback((_) 
              { 
                _showErrorAlert("Invalid Password");
              });
            }
            else if(errorMessage=="Already logged in, do not log in again")
            {
              WidgetsBinding.instance.addPostFrameCallback((_) 
              { 
                _showErrorAlert("Already logged in, do not log in again");
              });
            }
            return Container();
          }
 
        }
        else if (snapshot.hasError) 
        {
          return Text('${snapshot.error}');
        } 
        else 
        {
          return const Text('No data available');
        }
      } 
    );
  }
  Future<void> _showErrorAlert(String message)async
  {
    String showMessage="";
    if(message=="Please try again or go to Sign Up")
    {
      showMessage="您還沒註冊或填錯帳號，請重新嘗試登入";
    }
    else if(message=="Invalid Password")
    {
      showMessage="密碼錯誤";
    }
    await showDialog
    (
      context: context, 
      builder: (context)=>AlertDialog
      (
        title: const Text("登入失敗"),
        content: Text(showMessage),
        actions: <Widget>
        [
          ElevatedButton
          (
            onPressed: ()
            {
              _accountcontroller.clear();
              _passwordcontroller.clear();
              setState(() 
              {
                _futureLogin=null;
                _showSignUpButton=true;
              });
              Navigator.of(context).pop();
            }, 
            child: const Text("重來"),
          ),
          if(message=="Please try again or go to Sign Up")
            ElevatedButton
            (
              onPressed: ()
              {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(_)=>const SignUpPage()));
                Navigator.of(context).pop();
              }, 
              child: const Text("註冊"),
            ),
        ],
      ),
    );
  }
}