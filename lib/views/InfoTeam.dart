import 'dart:async';
import 'dart:io';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/Wrapp.dart';
import 'package:chatapp/models/Friend.dart';
import 'package:chatapp/models/Message.dart';
import 'package:chatapp/models/Team.dart';
import 'package:chatapp/models/User.dart';
import 'package:chatapp/services/Auth.dart';
import 'package:chatapp/views/AddTeam.dart';
import 'package:chatapp/views/Admin.dart';
import 'package:chatapp/views/ChaTeam.dart';
import 'package:chatapp/views/Chat.dart';
import 'package:chatapp/views/FulImage.dart';
import 'package:chatapp/views/Home.dart';
import 'package:chatapp/views/Search.dart';
import 'package:chatapp/views/Setting.dart';
import 'package:chatapp/views/Sign_in.dart';
import 'package:chatapp/views/Sign_up.dart';
import 'package:chatapp/views/UpdatePass.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


List<String> members = [];
class InfoTeam extends StatefulWidget {
	InfoTeam(member){
		members = member;
	}
	@override
	InfoTeamState createState() => InfoTeamState();
}

class InfoTeamState extends State<InfoTeam> {
	final ScrollController listScrollController = new ScrollController();

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				//titleSpacing: -45.0,
				title: Text(
					"$nameTeam",
					style: TextStyle(
						fontFamily: "times new roman",
						fontWeight: FontWeight.bold,
						color: Colors.white,
					),
				),
				centerTitle: true,
				elevation: 0,
				backgroundColor : Colors.deepPurple,
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
								Colors.deepPurple[400],
							]
						)
					),
					child: _body(),
				), 
				onWillPop: null,
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
				child:new Column(
						children: <Widget>[
							new Padding(padding: EdgeInsets.all(9.0)),
							new Container(
								height: 230,
								width: 230,
								child: Material(
									child: urlImgTeam != null 
										? cachImg(urlImgTeam ,5.0)
										: teamImg,
									borderRadius: BorderRadius.all(Radius.circular(400.0)),
									clipBehavior: Clip.hardEdge,
								),
							),
							new Padding(padding: EdgeInsets.all(4.0)), 
							_members(context),
						],
					),
			),
		);
	}

	Widget _members(BuildContext context){
		return StreamBuilder<QuerySnapshot>(
			stream: Firestore.instance.collection("User").where('uid',whereIn: members).orderBy('pname',descending : false).snapshots(),
			builder: (context, snapshot) {
				if (!snapshot.hasData) {
					return Center(
						child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple))
					);
				}else{
					var data = snapshot.data.documents;
					//print("length=${data.length}");
					return ListView.builder(
						scrollDirection: Axis.vertical,
						shrinkWrap: true,
						padding: const EdgeInsets.only(top: 5.0,left:3,right:3,bottom: 5),
						itemBuilder: (context, index) => _itemMember(context, data[index]),
						itemCount: data.length,
						reverse: false,
					 	controller: listScrollController,
					);
				}
			},
		);
	}
	Widget _itemMember(context,DocumentSnapshot data,){
		var us = data.data;
		var name = us["name"];
		var pname = us["pname"];
		var branch = us["branch"];
		var url =us['urlImg'];
		var role =us['role'];
		var uid =us['uid'];
		var token =us['deviceToken'];

		return Container(
			margin: EdgeInsets.only(top: 4.0,left:3,right:3,bottom: 4),
			padding: EdgeInsets.all(0),
			decoration: BoxDecoration(
				//color: Colors.greenAccent[100].withOpacity(0.65),
				color: Colors.greenAccent[100].withOpacity(0.65),
				borderRadius:  BorderRadius.all(Radius.circular(3.0)),
			),
			child : ListTile(
				leading: InkWell(
					onTap: (){
						if(url!=null){
							Navigator.push(context, new MaterialPageRoute(builder: (context)=> new FulImage(url)));
						}else{
							showToast("There is no image",false);
						}
					},
					child: Container(
						height: 56,
						width: 56,
						child: Material(
							child: url != null 
								? cachImg(url,2.0)
								: role == 'student'
									? stdImg
									: profImg,
							borderRadius: BorderRadius.all(Radius.circular(50.0)),
							clipBehavior: Clip.hardEdge,
						),
					),
				),
				title: Text("$pname $name",style: TextStyle(fontWeight: FontWeight.bold)),
				subtitle: role == "student" ?
					Text("\"$branch\"")
					: Text("\"Professor\""),
				trailing: IconButton(
					icon: Icon(
						Icons.message,
						color: Colors.black38,
					),
					onPressed : (){
						Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Chat(uid,name,pname,branch,url,token)));
					}
				),
				onTap: (){
					Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Chat(uid,name,pname,branch,url,token)));
				},
			),
		);
	}
	showToast(msg,top){
		Fluttertoast.showToast(
			msg: msg,
			toastLength: Toast.LENGTH_LONG,
			gravity: top? ToastGravity.TOP : ToastGravity.BOTTOM,
		);
	}
} 