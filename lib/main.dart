import 'package:chatapp/Wrapp.dart';
import 'package:flutter/material.dart';


final String myEmail = "hakim.199911@gmail.com";
final String myPass = "0628942060ycbh";
final String urlApp = 'www.google.com';//apk url in github
final String serverToken = 'AAAAXq6HW7Y:APA91bHpgF36fkoCP-bkNmI0egWAvdMrpPTuTHK5K0IXOrIFRN9Yw8eya7hb-BdKLdf9ywIAANffBizr-eZER_xgBSX16STsevED-eh5J8Bz0EPRhJpjqbo8JvpCFZJVLQE4aAropy6h';
String userDevToken;



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
      debugShowCheckedModeBanner: false,
			home: Wrapp(),
    		title: 'ESTE TEAMS',
			theme: ThemeData( 
				primaryColor : Colors.deepPurple,
			),
		);
	}
}