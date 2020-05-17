// import 'package:chatapp/models/Message.dart';
// import 'package:chatapp/views/Sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// bool isLoading = false;

// class Sms extends StatefulWidget {
//   @override
//   _SmsState createState() => _SmsState();
// }

// class _SmsState extends State<Sms> {
// 	final ScrollController listScrollController = new ScrollController();
// 	static String sms ='';
// 	int nb = 95;
// 	final dbref = Firestore.instance;

// 	Future<FirebaseUser> uS ;
// 	String uiD;
// 	String emaiL;
// 	int i = 0;

// 	void addSms(sms) async {
// 		await dbref.collection("sms")
// 			.add({
// 				'src': 'ali',
// 				'des': 'hakim',
// 				'sms': sms,
// 				'date':nb--,
// 			});
// 	}

// 	@override
//   void initState() {
//     super.initState();
	
//   }
//   loggedIn(){
// 	  uS =  FirebaseAuth.instance.currentUser();
// 	  try{
// 	uS.then((v){
// 		setState(() {
// 		  uiD = v.uid;
// 		emaiL = v.email;
// 		i++;
// 		});
// 	});
// 	}catch(e){
// 		setState(() {
// 		  emaiL = "ER"+e.toString();
// 		  uiD = '';
		  
// 		});
// 	}
//   }

// 	@override
// 	Widget build(BuildContext context) {
// 		return Scaffold(
// 			appBar: new AppBar(
// 				centerTitle:true,
// 				title:Text("<$i>-$uiD$emaiL ",style:TextStyle(fontSize:7)),
// 				backgroundColor: Colors.deepPurple,
// 				actions: <Widget>[
// 					IconButton(icon: Icon(Icons.queue), onPressed: (){loggedIn();}),
// 				],
//         //leading: Icon(Icons.short_text,color:Colors.deepPurple),
// 			),
// 			body:Stack(
// 				children:<Widget>[
// 					Column(
// 						children:<Widget>[
// 							Expanded(child: _buildBody(context)),
// 							_messageInput(),
// 						],
// 					),
// 					loading(),
// 				],
// 			),
// 		);
// 	}

// 	Widget _buildBody(BuildContext context) {
// 		return StreamBuilder<QuerySnapshot>(
// 			stream: Firestore.instance.collection("Chats").document(user.uid).collection("Friends")
// 			.document('uid-amis').collection('Messages').orderBy('date',descending:false).snapshots(),
// 			builder: (context, snapshot) {
// 				if (!snapshot.hasData) {
// 					return Center(
// 						child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple))
// 					);
// 				}else{
// 					var data = snapshot.data.documents;
// 					return ListView.builder(
// 						scrollDirection: Axis.vertical,
// 						shrinkWrap: true,
// 						padding: const EdgeInsets.only(top: 5.0,left:3,right:3,bottom: 5),
// 						itemBuilder: (context, index) => _buildListItem(context, data[index]),
// 						itemCount: data.length,
// 						reverse: true,
// 					 	controller: listScrollController,
// 					);
// 				}
// 			},
// 		);
// 	}

// 	Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
// 		final record = Message.fromSnapshot(data);
// 		if(record.toMe){
// 			return _smsLeft(context,data);
// 		}else{
// 			return _smsRight(context,data);
// 		}		
// 	}

// 	Widget _smsRight(BuildContext context, DocumentSnapshot data) {
// 		final record = Message.fromSnapshot(data);
// 		return Container(
// 			margin: EdgeInsets.only(
// 					top: 8.0,
// 					bottom: 8.0,
// 					left: 80.0,
// 					),
// 			padding: EdgeInsets.fromLTRB(10, 8, 10, 3),
// 			width: MediaQuery.of(context).size.width * 0.75,
// 			decoration: BoxDecoration(
// 				color: Colors.lightBlue[100] ,
// 				borderRadius:  BorderRadius.all(Radius.circular(10.0)),
// 			),
// 			child: Column(
// 				crossAxisAlignment: CrossAxisAlignment.start,
// 				children: <Widget>[
// 					Text(
// 						record.message,
// 						style: TextStyle(
// 							fontSize: 15.0,
// 						),
// 					),
// 					SizedBox(height: 8.0),
// 					Row(
// 						children:<Widget>[
// 							Expanded(child: Container()),
// 							Text(
// 								"${record.date}",
// 								style: TextStyle(
// 								color: Colors.grey,
// 								fontSize: 10.0,
// 								fontWeight: FontWeight.w600,
// 								),
// 							),
// 						]
// 					),
// 				],
// 			),
// 		);
// 	}
// 	Widget _smsLeft(BuildContext context, DocumentSnapshot data) {
// 		final record = Message.fromSnapshot(data);
// 		return Container(
// 			margin: EdgeInsets.only(
// 					top: 8.0,
// 					bottom: 8.0,
// 					right: 80.0,
// 					),
// 			padding: EdgeInsets.fromLTRB(10, 8, 10, 3),
// 			width: MediaQuery.of(context).size.width * 0.75,
// 			decoration: BoxDecoration(
// 				color: Colors.yellow[100],
// 				borderRadius:  BorderRadius.all(Radius.circular(10.0)),
// 			),
// 			child: Column(
// 				crossAxisAlignment: CrossAxisAlignment.start,
// 				children: <Widget>[
// 					Text(
// 						record.message,
// 						style: TextStyle(
// 							fontSize: 15.0,
// 						),
// 					),
// 					SizedBox(height: 8.0),
// 					Row(
// 						children:<Widget>[
// 							Expanded(child: Container()),
// 							Text(
// 								"${record.date}",
// 								style: TextStyle(
// 								color: Colors.grey,
// 								fontSize: 10.0,
// 								fontWeight: FontWeight.w600,
// 								),
// 							),
// 						]
// 					),
// 				],
// 			),
// 		);
// 	}
	
// 	_messageInput() {
// 		return Container(
// 			padding: EdgeInsets.symmetric(horizontal: 8.0),
// 			height: 50.0,
// 			decoration: BoxDecoration(
// 				color: Colors.white12,
// 				// border: Border.all(color:Colors.deepPurple,width:1) ,
// 				// borderRadius:  BorderRadius.all(Radius.circular(33.0)),
// 			),
// 			child: Row(
// 				children: <Widget>[
// 					IconButton( //btn PHOTO*****************************
// 						icon: Icon(Icons.photo),
// 						iconSize: 25.0,
// 						color: Colors.deepPurple,
// 						onPressed: () {
// 							FirebaseAuth.instance.signOut();
// 							uS.then((v){
// 								uiD = v.uid;
// 								emaiL = v.email;
// 								i--;
// 							});
// 						},
// 					),
// 					Expanded(
// 						child: TextField( //input MSG*****************************
// 							textCapitalization: TextCapitalization.sentences,
// 							onChanged: (val){sms = val;},
// 							decoration: InputDecoration.collapsed(
// 								hintText: 'Send a message...',
// 							),
// 						),
// 					),
// 					IconButton( //btn SEND*****************************
// 						icon: Icon(Icons.send),
// 						iconSize: 25.0,
// 						color: Colors.deepPurple,
// 						onPressed: () {
// 							if(sms != '' && sms != null){
// 								addSms(sms);
// 								listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
// 								print("SMS:"+sms);
// 							}else{
// 								print("SMS null >|...|");
// 							}
// 						},
// 					),
// 				],
// 			),
// 		);
// 	}
// 	Widget loading() {
// 		return Positioned(
// 		child: isLoading
// 			? Container(
// 				child: Center(
// 					child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple)),
// 				),
// 				color: Colors.white.withOpacity(0.8),
// 				)
// 			: Container(),
// 		);
//   }
// }


// // return ListView(
// // 	scrollDirection: Axis.vertical, //************ Add it
// // 	shrinkWrap: true, //************
// // 	padding: const EdgeInsets.only(top: 20.0,left:6,right:6,),
// // 	children: snapshots.map((data) => _buildListItem(context, data)).toList(),
// // );