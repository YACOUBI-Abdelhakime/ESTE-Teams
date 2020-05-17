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

final stdImg = Container(
	child: studentImg,
	decoration: BoxDecoration(
		borderRadius:BorderRadius.all(Radius.circular(70.0)),
		color : Colors.white,
	),
);
final profImg = Container(
	child: CircleAvatar(
		//radius: 60,
		backgroundImage: AssetImage('images/prof.png'),
	),
	decoration: BoxDecoration(
		borderRadius:BorderRadius.all(Radius.circular(70.0)),
		color : Colors.white,
	),
);
cachImg(url,double widthScrol){
	return CachedNetworkImage(
		placeholder: (context, url) => Container(
			child: CircularProgressIndicator(
				strokeWidth: widthScrol,
				valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
			),
			// width: 50.0,
			// height: 50.0,
			padding: EdgeInsets.all(15.0),
		),
		imageUrl: url ,
		color: null,
		fit: BoxFit.cover,
	);
}


class Home extends StatefulWidget {
	@override
	HomeState createState() => HomeState();
}

class HomeState extends State<Home> {

	int _index = 0;
	Auth _auth = Auth();
	String _branch;
	TextEditingController _teamNameCtr = new TextEditingController();
	PageController _pageController  = PageController();
	final ScrollController listScrollController = new ScrollController();
	List<Choice> choices = const <Choice>[
		const Choice(title: 'Change Password', icon: Icons.lock_outline),
		const Choice(title: 'Settings', icon: Icons.settings),
		const Choice(title: 'Log out', icon: Icons.exit_to_app),
		
	];

	@override
	void dispose() {
		_pageController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				titleSpacing: -45.0,
				title: Text(
					"ESTE Teams",
					style: TextStyle(
						fontFamily: "times new roman",
						fontWeight: FontWeight.bold,
						color: Colors.white,
					),
				),
				leading:Icon(Icons.home,color:Colors.deepPurple),
				centerTitle: false,
				elevation: 0,
				backgroundColor : Colors.deepPurple,
				actions: <Widget>[
					new IconButton(
						icon: Icon(Icons.search), 
						onPressed: (){
							//sendFirebaseNotif('New group message','${user.pname} ${user.name} #',"dInBRbQ0SHaTCM66Zaka3f:APA91bF7ICLoYyjChOcxWiZjC4VVVUZUQ7UsKIxNu7rZ2DiZ2Z8R63uLm4bCN9mMKCYYFX-ohqcP26LoybLRXW7H9VvmaU4rNz-JoJoJZ6tk6PEpmA4lQVE-WO1D09DdylW_Sd_OaWCS");
							Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Search()));
						}
					),
					_menu(),
				],
			),
			body: WillPopScope(
				child: Container(
					//color: Colors.blue[200],
					child: Column(
						children: <Widget>[
							BottomNavyBar(
								mainAxisAlignment : MainAxisAlignment.spaceAround,
								containerHeight : 50,
								animationDuration : const Duration(milliseconds: 300),
								backgroundColor :Colors.deepPurple,
								selectedIndex: _index,
								onItemSelected: (index){_switchPage(index);},
								items: <BottomNavyBarItem>[
									BottomNavyBarItem(
										title: Text('    Chats'),
										activeColor : Colors.greenAccent,
										inactiveColor : Colors.greenAccent,
										icon: Icon(Icons.question_answer)
									),
									BottomNavyBarItem(
										title: Text('    Teams'),
										activeColor : Colors.greenAccent,
										inactiveColor :  Colors.greenAccent,
										icon: Icon( Icons.supervised_user_circle ),
									),
									BottomNavyBarItem(
										title: Text('    Friends'),
										activeColor : Colors.greenAccent,
										inactiveColor :  Colors.greenAccent,
										icon: Icon( Icons.person_add ),
									),
								],
							),
							Expanded(//SingleChildScrollView
								child:SizedBox.expand(
									child: PageView(
										controller: _pageController,
										onPageChanged: (index) {
											setState(() => _index = index);
										},
										children: <Widget>[
											//CHATS
											_chats(context),
											//TEAMS
											_teams(context),
											//FRIENDS
											_friends(context),
										],
									),
								), 
							)
						],
					), 
				),
				onWillPop: onBackPress,
			),
			floatingActionButton: _index == 1 ? FloatingActionButton(
				child: Icon(Icons.group_add,size: 30,),
				tooltip:"Add new team",
				backgroundColor: Colors.deepPurple,
				onPressed: (){
					//Navigator.push(context, new MaterialPageRoute(builder: (context)=> new ChaTeam("AQCKj8BHpjIItyBxMY9n","NAME 100",null)));
					Navigator.push(context, new MaterialPageRoute(builder: (context)=> new AddTeam()));
				}
			) 
			: null,
		);
	}
	Future<bool> onBackPress() {
		//Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Sms()));
		exit(0);
		return Future.value(false);
	}
	_switchPage(index) {
		setState(() => _index = index);
		_pageController.animateToPage(index, duration:Duration(milliseconds: 500), curve: Curves.easeOut);
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
			_auth.signOut();
			Navigator.push( context, MaterialPageRoute(builder: (context) => Sign_in()));
		}else if (choice.title == 'Settings'){
			// Settigns
			Navigator.push( context, MaterialPageRoute(builder: (context) => Setting()));
		} else {
			// Change password
			Navigator.push( context, MaterialPageRoute(builder: (context) => UpdatePass()));
		}
	}

	Widget _friends(BuildContext context) {
		return StreamBuilder<QuerySnapshot>(
			stream: Firestore.instance.collection("User").orderBy('role',descending : false).orderBy('branch',descending : false).orderBy('pname',descending : false).snapshots(),
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
						padding: const  EdgeInsets.only(top: 5.0,left:3,right:3,bottom: 5),
						itemBuilder: (context, index) => _itemFriend(context, data[index]),
						itemCount: data.length,
						reverse: false,
					 	controller: listScrollController,
					);
				}
			},
		);
	}
	Widget _itemFriend(context,DocumentSnapshot data,){
		var us = data.data;
		var name = us["name"];
		var pname = us["pname"];
		var branch = us["branch"];
		var url =us['urlImg'];
		var role =us['role'];
		var uid =us['uid'];
		var token =us['deviceToken'];

		if(role != 'admin' && uid != user.uid){
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
					title: role == "student" ? 
						Text("$pname $name",style: TextStyle(fontWeight: FontWeight.bold))
						: Text("$pname $name",style: TextStyle(fontWeight: FontWeight.bold)),
					subtitle: role == "student" ?
						Text("\"$branch\"")
						: Text("\"Professor\""),
					trailing: IconButton(
						icon: Icon(
							Icons.message,
							color: Colors.black38,
						),
						onPressed : (){
							_createChat(uid,name,pname,branch);
							Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Chat(uid,name,pname,branch,url,token)));
						}
					),
					onTap: (){
						_createChat(uid,name,pname,branch);
						Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Chat(uid,name,pname,branch,url,token)));
					},
				),
			);
		}else{
			return Container();
		}
	}
	_createChat(uidF,nameF,pnameF,branchF){

		Firestore.instance.collection("Chats").document(user.uid)
			.collection("Friends").document(uidF).setData(
				{
				'uid' : uidF,
				'name' : "$pnameF $nameF $branchF",
				},
				merge: true,
			);
	}

	Widget _teams(BuildContext context){
		return StreamBuilder<QuerySnapshot>(
			stream: Firestore.instance.collection("Teams")/*.where('members',arrayContains:user.uid)*/.orderBy('lastMessage',descending : true).snapshots(),
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
						itemBuilder: (context, index) => _itemTeam(context, data[index]),
						itemCount: data.length,
						reverse: false,
					 	controller: listScrollController,
					);
				}
			},
		);
	}
	Widget _itemTeam(context,DocumentSnapshot data,){
		var uidTeam = data.documentID;
		var notRead = List.from(data['notRead']);
		var membs = List.from(data['members']);
		var newMessage = notRead.contains(user.uid);
		final team = Team.fromSnapshot(data,uidTeam,newMessage);
		
			if(membs.contains(user.uid)){
				return Container(
					margin: EdgeInsets.only(top: 4.0,left:3,right:3,bottom: 4),
					padding: EdgeInsets.all(0),
					//width: MediaQuery.of(context).size.width * 0.75,
					decoration: BoxDecoration(
						//color: Colors.greenAccent[100].withOpacity(0.65),
						color: Colors.greenAccent[100].withOpacity(0.65),
						borderRadius:  BorderRadius.all(Radius.circular(3.0)),
					),
					child : ListTile(
						leading: InkWell(
							onTap: (){
								if(team.url!=null){
									Navigator.push(context, new MaterialPageRoute(builder: (context)=> new FulImage(team.url)));
								}else{
									showToast("There is no image",false);
								}
							},
							child: Container(
								height: 56,
								width: 56,
								child: Material(
									child: team.url != null 
										? cachImg(team.url,2.0)
										:  teamImg,//team Image*********************************************
									borderRadius: BorderRadius.all(Radius.circular(50.0)),
									clipBehavior: Clip.hardEdge,
								),
							),
						),
						title: Text("${team.name}",style: TextStyle(fontWeight: FontWeight.bold)),
						subtitle: Row(children: <Widget>[Expanded(child: Container()),Text("${team.lastMessage}")],),
						trailing: !team.newMessage ? 
							null : 
							Icon(
								Icons.notifications_active,
								size: 20,
								color: Colors.red
							),
						onTap: (){
							print("uidPressed = ${team.uid}");
							Navigator.push(context, new MaterialPageRoute(builder: (context)=> new ChaTeam(team.uid,team.name,team.url)));
						},
					),
				);
			}else{
				return Container();
			}
	}

	Widget _chats(BuildContext context) {
		return StreamBuilder<QuerySnapshot>(
			stream: Firestore.instance.collection("Chats").document(user.uid)
			.collection("Friends").orderBy('lastMessage',descending : true).snapshots(),
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
						itemBuilder: (context, index) => _buildListChats(context, data[index]),
						itemCount: data.length,
						reverse: false,
					 	controller: listScrollController,
					);
				}
			},
		);
	}
	Widget _buildListChats(BuildContext context, DocumentSnapshot data) {
		final friend = Friend.fromSnapshot(data);
		return StreamBuilder<QuerySnapshot>(
			stream: Firestore.instance .collection('User').snapshots(),
			builder: (context, snapshot) {
				if (!snapshot.hasData) {
					return Container();
				}else{
					var data = snapshot.data.documents;
					return ListView.builder(
						scrollDirection: Axis.vertical,
						shrinkWrap: true,
						padding: const EdgeInsets.only(top: 4.0,left:3,right:3,bottom: 4),
						itemBuilder: (context, index){
							//print("DATA<$index>${data[index]}");
							return _itemChat(context, data[index],friend.uid,index,friend.lastMessage,friend.newMessage);
						},
						itemCount: data.length,
						reverse: false,
					 	controller: listScrollController,
					);
				}
			},
		);
	}
	Widget _itemChat(context,DocumentSnapshot data,uidx,i,lastUpdate,newMessage){
		var us = data.data;
		var name = us["name"];
		var pname = us["pname"];
		var branch = us["branch"];
		var url =us['urlImg'];
		var uid = us["uid"];
		var token = us["deviceToken"];
		if(uid == uidx){
			return Container(
				margin: EdgeInsets.all(0),
				padding: EdgeInsets.all(0),
				//width: MediaQuery.of(context).size.width * 0.75,
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
									: us['role'] == 'student'
										? stdImg
										: profImg,
								borderRadius: BorderRadius.all(Radius.circular(50.0)),
								clipBehavior: Clip.hardEdge,
							),
						),
					),
					title: us['role'] == "student" ? 
						Text("$pname $name \"$branch\"",style: TextStyle(fontWeight: FontWeight.bold))
						: Text("$pname $name \"Prof\"",style: TextStyle(fontWeight: FontWeight.bold)),
					subtitle: Row(children: <Widget>[Expanded(child: Container()),Text("$lastUpdate")],),
					trailing: newMessage=='false' ? 
						null : 
						Icon(
							Icons.notifications_active,
							size: 20,
							color: Colors.red
						),
					onTap: (){
						print("uidPressed = $uid");
						Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Chat(uid,name,pname,branch,url,token)));
					},
				),
			);
		}
		return Container();
	}
	
	String validateName(String value) {
		if (value.length < 3)
			return 'Enter Valid Name';
		else
			return null;
	}
	showToast(msg,top){
		Fluttertoast.showToast(
			msg: msg,
			toastLength: Toast.LENGTH_LONG,
			gravity: top? ToastGravity.TOP : ToastGravity.BOTTOM,
		);
	}
	
	DropdownButton _selectBranch() => DropdownButton<String>(
		underline:new Divider(
			height: 2.0, 
			indent: 1.0,
			color: Colors.black,
		),
		iconSize: 25,
        items: [
			DropdownMenuItem(
				value: "GI1",
				child: Row(
					children: <Widget>[
						Icon(Icons.fiber_manual_record,color: Colors.black54),
						new Padding(padding: const EdgeInsets.all(5),),
						Text(
							"GI1",
							style:TextStyle(
								fontWeight: FontWeight.bold,
							),
						),
					],
				)
			),
			DropdownMenuItem(
				value: "ER1",
				child: Row(
					children: <Widget>[
						Icon(Icons.fiber_manual_record,color: Colors.black54),
						new Padding(padding: const EdgeInsets.all(5),),
						Text(
							"ER1",
							style:TextStyle(
								fontWeight: FontWeight.bold,
							),
						),
					],
				)
			),
			DropdownMenuItem(
				value: "TM1",
				child: Row(
					children: <Widget>[
						Icon(Icons.fiber_manual_record,color: Colors.black54),
						new Padding(padding: const EdgeInsets.all(5),),
						Text(
							"TM1",
							style:TextStyle(
								fontWeight: FontWeight.bold,
							),
						),
					],
				)
			),
			DropdownMenuItem(
				value: "GODT1",
				child: Row(
					children: <Widget>[
						Icon(Icons.fiber_manual_record,color: Colors.black54),
						new Padding(padding: const EdgeInsets.all(5),),
						Text(
							"GODT1",
							style:TextStyle(
								fontWeight: FontWeight.bold,
							),
						),
					],
				)
			),
			DropdownMenuItem(
				value: "GI2",
				child: Row(
					children: <Widget>[
						Icon(Icons.fiber_manual_record,color: Colors.black54),
						new Padding(padding: const EdgeInsets.all(5),),
						Text(
							"GI2",
							style:TextStyle(
								fontWeight: FontWeight.bold,
							),
						),
					],
				)
			),
			DropdownMenuItem(
				value: "ER2",
				child: Row(
					children: <Widget>[
						Icon(Icons.fiber_manual_record,color: Colors.black54),
						new Padding(padding: const EdgeInsets.all(5),),
						Text(
							"ER2",
							style:TextStyle(
								fontWeight: FontWeight.bold,
							),
						),
					],
				)
			),
			DropdownMenuItem(
				value: "TM2",
				child: Row(
					children: <Widget>[
						Icon(Icons.fiber_manual_record,color: Colors.black54),
						new Padding(padding: const EdgeInsets.all(5),),
						Text(
							"TM2",
							style:TextStyle(
								fontWeight: FontWeight.bold,
							),
						),
					],
				)
			),
			DropdownMenuItem(
				value: "GODT2",
				child: Row(
					children: <Widget>[
						Icon(Icons.fiber_manual_record,color: Colors.black54),
						new Padding(padding: const EdgeInsets.all(5),),
						Text(
							"GODT2",
							style:TextStyle(
								fontWeight: FontWeight.bold,
							),
						),
					],
				)
			),
			DropdownMenuItem(
				value: "ISIL",
				child: Row(
					children: <Widget>[
						Icon(Icons.fiber_manual_record,color: Colors.black54),
						new Padding(padding: const EdgeInsets.all(5),),
						Text(
							"ISIL",
							style:TextStyle(
								fontWeight: FontWeight.bold,
							),
						),
					],
				)
			),
			DropdownMenuItem(
				value: "ERDD",
				child: Row(
					children: <Widget>[
						Icon(Icons.fiber_manual_record,color: Colors.black54),
						new Padding(padding: const EdgeInsets.all(5),),
						Text(
							"ERDD",
							style:TextStyle(
								fontWeight: FontWeight.bold,
							),
						),
					],
				)
			),
			DropdownMenuItem(
				value: "MGE",
				child: Row(
					children: <Widget>[
						Icon(Icons.fiber_manual_record,color: Colors.black54),
						new Padding(padding: const EdgeInsets.all(5),),
						Text(
							"MGE",
							style:TextStyle(
								fontWeight: FontWeight.bold,
							),
						),
					],
				)
			),
			DropdownMenuItem(
				value: "MBF",
				child: Row(
					children: <Widget>[
						Icon(Icons.fiber_manual_record,color: Colors.black54),
						new Padding(padding: const EdgeInsets.all(5),),
						Text(
							"MBF",
							style:TextStyle(
								fontWeight: FontWeight.bold,
							),
						),
					],
				)
			),
			DropdownMenuItem(
				value: "MT",
				child: Row(
					children: <Widget>[
						Icon(Icons.fiber_manual_record,color: Colors.black54),
						new Padding(padding: const EdgeInsets.all(5),),
						Text(
							"MT",
							style:TextStyle(
								fontWeight: FontWeight.bold,
							),
						),
					],
				)
			),
        ],
        onChanged: (value) {
          setState(() {
            _branch = value;
			print("branch : $_branch");
          });
        },
        value: _branch,
		hint: Text(
			"select your branch"
		),
		isExpanded: true,
	);
}
class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}