import 'dart:io';
import 'dart:math';
import 'package:chatapp/views/AddProf.dart';
import 'package:chatapp/views/Setting.dart';
import 'package:chatapp/views/Sign_up.dart';
import 'package:chatapp/services/Auth.dart';
import 'package:chatapp/services/Database.dart';
import 'package:chatapp/views/UpdatePass.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:path/path.dart' as Path;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'Sms.dart';
import 'ForgotPass.dart';
import 'Sign_in.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/models/User.dart';

var adminLogo = ClipOval(
	child: Image.asset(
		"images/admin.png",
		fit:BoxFit.cover,
		height: 25,
		width: 25,
	),
);

class Admin extends StatefulWidget {
	@override
	AdminState createState() => AdminState();
}

class AdminState extends State<Admin> {

	final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
	bool _autoValidate = false;
	bool move = false;
	Auth authSrv = Auth();
	TextEditingController _emailCtr = new TextEditingController();
	TextEditingController _nameCtr = new TextEditingController();
	TextEditingController _pnameCtr = new TextEditingController();
	List<Choice> choices = const <Choice>[
		const Choice(title: 'Change Password', icon: Icons.settings),
		const Choice(title: 'Log out', icon: Icons.exit_to_app),
	];


	@override
	Widget build(BuildContext context) {
		return new Scaffold(
			appBar: AppBar(
				title: Text(
					"ADMIN",
					style: TextStyle(
						fontFamily: "times new roman",
						fontWeight: FontWeight.bold
					),
				),
				centerTitle: true,
				backgroundColor: Colors.deepPurple,
				leading: Container(),
				actions: <Widget>[
					_menu(),
				],
			),
			body: WillPopScope(
				child: Container(
					height: 1000,
					decoration: new BoxDecoration(
						gradient: new LinearGradient(
							begin: Alignment.center,//.centerRight,
							end: new Alignment(1.0, 1.0),
							colors: [
								Colors.blue,
								Colors.purple[300],
								Colors.deepPurple,
								Colors.deepPurple,
							]
						)
					),
					child: _body(),
				), 
				onWillPop: onBackPress,
			),
		);
	}
	Future<bool> onBackPress() {
		//Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Sms()));
		exit(0);
		return Future.value(false);
	}
	Widget _body(){
		return new SingleChildScrollView(
			child: Center(
				child: new Form(
					key: _formKey,
					autovalidate: _autoValidate,
					child: Column(
						children: <Widget>[
							Padding(padding: EdgeInsets.all(25.0)),
							Container(
								child: adminLogo,
								width: 130,
								height: 130,
								decoration: BoxDecoration(
									borderRadius:BorderRadius.all(Radius.circular(70.0)),
									color : Colors.white,
								),
							),
							new Padding(padding: EdgeInsets.all(30.0)),
							Container(
								child: Column(
									children:<Widget>[
										new Container( //btn add prof
											width: 250,
											height: 50,
											decoration: new BoxDecoration(
												borderRadius: BorderRadius.circular(30.0),
												color: Colors.deepPurple[400],
											),
											child: new FlatButton(
												child : new Row( 
													children: <Widget>[
														new Text(
															"ADD PROF",
															style:TextStyle(
																color:Colors.white,
																fontSize: 17
															),
														),
														new Icon(
															Icons.navigate_next,
															size: 30,
															color: Colors.white,
														),
													],
													mainAxisAlignment: MainAxisAlignment.center,
												),
												onPressed: (){
													Navigator.push(context, new MaterialPageRoute(builder: (context)=> new AddProf()));
												},
											),
										),
									]
								),
							),
						],
					),
				),
			),
		);
	}
	dynamic _menu(){
		return PopupMenuButton<Choice>(
			onSelected: onItemMenuPress,
			itemBuilder: (BuildContext context) {
				return choices.map((Choice choice) {
					return PopupMenuItem<Choice>(
						value: choice,
						child: Row(
							children: <Widget>[
								Icon(
									choice.icon,
									color: Colors.deepPurple,
								),
									Container(
									width: 10.0,
								),
								Text(
									choice.title,
									style: TextStyle(color: Colors.black),
								),
							],
						)
					);
				}).toList();
			},
		);
	}
	void onItemMenuPress(Choice choice) {
		if (choice.title == 'Log out') {
			authSrv.signOut();
			Navigator.push( context, MaterialPageRoute(builder: (context) => Sign_in()));
		} else {
			// Settigns
			Navigator.push( context, MaterialPageRoute(builder: (context) => UpdatePass()));
		}
	}
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}