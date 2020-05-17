import 'dart:async';
import 'dart:convert';

import 'package:chatapp/views/Admin.dart';
import 'package:chatapp/views/Home.dart';
import 'package:chatapp/views/Sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'main.dart';
import 'models/User.dart';

loggedIn(BuildContext context) async {
		var uS = await FirebaseAuth.instance.currentUser();
		if(uS == null){
			Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Sign_in()));
		}else {
			var uidUser = uS.uid;

			DocumentSnapshot data = await Firestore.instance .collection('User').document(uidUser).get() ;
			String email = data['email'];
			String pass = data['pass'];
			String role = data['role']; 
			String branch = data['branch']; 
			String name = data['name']; 
			String pname = data['pname']; 
			String urlImg = data['urlImg'];
			user = User(uid: uidUser, email: email,pass: pass, name: name, pname: pname, branch: branch, role: role, urlImg: urlImg);
			if(role != "admin"){
				Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Home()));
			}else{
				Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Admin()));
			}
      
		}
	}

sendFirebaseNotif(title,body,token) async {
	if(token != null){
		await post(
			'https://fcm.googleapis.com/fcm/send',
			headers: <String, String>{
				'Content-Type': 'application/json',
				'Authorization': 'key=$serverToken',
			},
			body: jsonEncode(
				<String, dynamic>{
				'notification': <String, dynamic>{
					'title': title,
					'body': body,
				},
				'priority': 'high',
				'data': <String, dynamic>{
					'click_action': 'FLUTTER_NOTIFICATION_CLICK',
					'id': '1',
					'status': 'done'
				},
				'to': token,//resepteur
				},
			),
		);
	}
}


class Wrapp extends StatefulWidget {
  @override
  _WrappState createState() => _WrappState();
}

class _WrappState extends State<Wrapp> {

    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
	final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
	@override
	void initState() {
		super.initState();
		configLocalNotification();
		configFirebaseNotification();
		_firebaseMessaging.getToken().then((String token) {
			assert(token != null);
			userDevToken = token;
			print("TOKEN:$token");
			Timer(Duration(seconds: 1,), () {loggedIn(context);});
		});
	}
	void configLocalNotification() {
		var initializationSettingsAndroid =
			new AndroidInitializationSettings('logo');
		var initializationSettingsIOS = new IOSInitializationSettings();
		var initializationSettings = new InitializationSettings(
			initializationSettingsAndroid, initializationSettingsIOS);
		flutterLocalNotificationsPlugin.initialize(
			initializationSettings,
		);
	}
	configFirebaseNotification(){
		_firebaseMessaging.configure(
			onMessage: (Map<String, dynamic> message) async {
				print("onMessage: $message");
				showNotification(message['notification']);
			},
			onLaunch: (Map<String, dynamic> message) async {
				print("onLaunch: $message");
			},
			onResume: (Map<String, dynamic> message) async {
				print("onResume: $message");
			},
		);
	}
	void showNotification(message) async {
		var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
			'com.example.chatapp',
			'ESTE-Teams',
			'description ...',
			playSound: true,
			enableVibration: true,
			importance: Importance.Max,
			priority: Priority.High,
		);
		var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
		var platformChannelSpecifics = new NotificationDetails(
			androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
		await flutterLocalNotificationsPlugin.show(0,message['title'].toString(),
		message['body'].toString(), platformChannelSpecifics,
		);
	}


  	@override
	Widget build(BuildContext context) {
			
		return Scaffold(
			body: Container( 
				decoration: new BoxDecoration(
						gradient: new LinearGradient(
							begin: Alignment.center,
							end: new Alignment(1.0, 1.0),
							colors: [
								Colors.deepPurple[400],
								Colors.blue,
							]
						)
					),
				child: Column(
					children: <Widget>[
						SizedBox(height: 140,),
						Container(
							child: logo ,
							width: 120,
							height: 120,
						),
						Expanded(child: Container(),),
						Center(
							child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple)),
						),
						SizedBox(height: 60,),
						Text(
							"Created by",
							style: TextStyle(
								color: Colors.grey,
								fontFamily: "times new roman",
								fontSize: 15,
								fontWeight: FontWeight.bold,
							),
						),
						Text(
							"YACOUBI Abdelhakime",
							style: TextStyle(
								color: Colors.deepPurple,
								fontFamily: "times new roman",
								fontSize: 15,
								fontWeight: FontWeight.normal,
							),
						),
						SizedBox(height: 40,),
					],
				),
			),
		);
	}
}