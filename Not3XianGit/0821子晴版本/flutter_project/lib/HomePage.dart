import 'package:flutter/material.dart';
import 'package:flutter_project/Login.dart';
import 'package:flutter_project/SignUp.dart';
class HomePage extends StatelessWidget 
{
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) 
  {
    Size screenSize=MediaQuery.of(context).size;
    double fontSize = screenSize.width * 0.1;
    return Scaffold
    (
      appBar: AppBar
      (
        title:Center
        (
          child: Text
          (
            "Not3首頁",
            style: TextStyle(color: Colors.white,fontSize: fontSize*0.6),
          )
        ),
        backgroundColor: Colors.green
      ),
      body:SafeArea
      (
        child:Container
        (
          padding:const EdgeInsets.all(16.0),
          child:Column
          (
            mainAxisAlignment: MainAxisAlignment.center,
            children: 
            [
              Row
              (
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                  [
                    Text("Welcome!!",style: TextStyle(color: Colors.black45,fontSize: fontSize,fontWeight: FontWeight.bold))
                  ],
              ),
              Row
              (
                mainAxisAlignment: MainAxisAlignment.center,
                children: 
                [
                  Container
                  (
                    alignment: Alignment.topCenter,
                    child:Image.asset('assets/images/Logo.png',width: screenSize.width*0.6,height: 300),
                  ),
                ],
              ),
              Row
              (
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: 
                [
                  Container
                  (
                    height: 60,
                    width:screenSize.width*0.3,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration
                    (
                      color:const Color.fromARGB(222, 37, 191, 10),borderRadius: BorderRadius.circular(10),
                    ),
                    child:TextButton
                    (
                      onPressed: ()
                      {
                        Navigator.push
                        (
                          context,MaterialPageRoute(builder:(context)=> const LoginPage())
                        );
                      },
                      child:Text
                      (
                        '登錄',
                        style: TextStyle(color: Colors.white, fontSize: fontSize*0.5)
                      ),
                    ),
                  ),
                  Container
                  (
                    height: 60,
                    width:screenSize.width*0.3,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration
                    (
                      color:const Color.fromARGB(222, 37, 191, 10),borderRadius: BorderRadius.circular(10),
                    ),
                    child:TextButton
                    (
                      onPressed: ()
                      {
                        Navigator.push
                        (
                          context,MaterialPageRoute(builder:(context)=> const SignUpPage())
                        );
                      },
                      child:Text
                      (
                        '註冊',
                        style: TextStyle(color: Colors.white, fontSize: fontSize*0.5)
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}