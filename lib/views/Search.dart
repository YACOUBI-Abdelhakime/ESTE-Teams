import 'dart:async';
import 'package:chatapp/views/Chat.dart';
import 'package:chatapp/views/Home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Sign_in.dart';


class Search extends StatefulWidget {
	@override
	SearchState createState() => SearchState();
}

class SearchState extends State<Search> {
	String _searchStr = '' ;
	int resLenght;
	final ScrollController listScrollController = new ScrollController();

	@override
	Widget build(BuildContext context) {
		return new Scaffold(
			appBar: AppBar(
				title:Container(
					height: 40,
					padding: EdgeInsets.only(left:5,right:3),
					decoration: BoxDecoration(
						color: Colors.grey[200],
						borderRadius: BorderRadius.circular(32),
					),
					child:  new TextFormField(
						style: new TextStyle( 
							color: Colors.black, 
							fontSize: 17, 
							fontWeight: FontWeight.normal, 
						),
						decoration: new InputDecoration(
							hintText: 'Search ...',
							hintStyle: new TextStyle(
								color: Colors.black, 
								fontWeight: FontWeight.bold, 
								fontSize: 17
							),
						),
						keyboardType: TextInputType.text,
						onChanged: (val){
							setState((){_searchStr = val;});
						},
					),
				),
				actions: <Widget>[
					new IconButton(
						icon: Icon(Icons.search), 
						onPressed: (){
							FocusScopeNode currentFocus = FocusScope.of(context);
				            if (!currentFocus.hasPrimaryFocus) {
					            currentFocus.unfocus();
				            }
						}
					),
				],
			),
			body: WillPopScope(
				child: Container(
					child: _search(context) ,
				), 
				onWillPop: onBackPress,
			)
		);
	}
	Future<bool> onBackPress() {
		Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Home()));
		//exit(0);
		return Future.value(false);
	}
	Widget _search(BuildContext context) {
		return StreamBuilder<QuerySnapshot>(
			stream: Firestore.instance.collection("User").where('pname',isGreaterThanOrEqualTo: _searchStr.toUpperCase()).where('pname',isLessThanOrEqualTo: _searchStr.toUpperCase()+'Z').snapshots(),
			builder: (context, snapshot) {
				if (!snapshot.hasData) {
					return Center(
						child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple))
					);
				}else{
					var data = snapshot.data.documents;
					print("length=${data.length}");
					//setState(() { resLenght =  data.length;});
					if(resLenght == 0){
                        return Container();
					}else{
					    return ListView.builder(
						    scrollDirection: Axis.vertical,
						    shrinkWrap: true,
						    padding: const EdgeInsets.all(0),
						    itemBuilder: (context, index) => _itemSearch(context, data[index]),
						    itemCount: data.length,
						    reverse: false,
					 	    controller: listScrollController,
					    );
					}
				}
			},
		);
	}
	Widget _itemSearch(context,DocumentSnapshot data,){
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
				margin: EdgeInsets.only(top: 5.0,left:3,right:3,bottom: 5),
				padding: EdgeInsets.all(0),
				decoration: BoxDecoration(
					color: Colors.greenAccent[100].withOpacity(0.65),
					borderRadius:  BorderRadius.all(Radius.circular(3.0)),
				),
				child : ListTile(
					leading: Container(
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
							//:  stdImg : profImg,
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
			//setState(() { --resLenght;});
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
	
	showToast(msg,top){
		Fluttertoast.showToast(
			msg: msg,
			toastLength: Toast.LENGTH_LONG,
			gravity: top? ToastGravity.TOP : ToastGravity.BOTTOM,
		);
	}
}