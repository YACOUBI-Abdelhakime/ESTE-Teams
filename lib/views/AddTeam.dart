import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:chatapp/views/Home.dart';
import 'package:chatapp/views/Sign_up.dart';
import 'package:chatapp/services/Auth.dart';
import 'package:chatapp/services/Database.dart';
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

final teamImg = CircleAvatar(
	radius: 60,
	backgroundImage: AssetImage('images/team.png'),
);


class AddTeam extends StatefulWidget {
	@override
	AddTeamState createState() => AddTeamState();
}

class AddTeamState extends State<AddTeam> {

	final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
	bool _autoValidate = false;
	bool move = false;
	Auth authSrv = Auth();
	Database db ;
	TextEditingController _nameCtr = new TextEditingController();
	String _urlImg;
	File _image;
	String _branch ;
	

	

	@override
	Widget build(BuildContext context) {
		return new Scaffold(
			appBar: AppBar(
				backgroundColor: Colors.deepPurple,
				centerTitle: true,
				title : Text(
					"Create New Team",
					style: TextStyle(
						fontFamily: "times new roman",
						fontWeight: FontWeight.bold,
						color: Colors.white,
					),
				),
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
					child:new SingleChildScrollView(child: _body()),
				), 
				onWillPop: null,
			),
		);
	}
	Future<bool> onBackPress() {
		Navigator.push( context, MaterialPageRoute(builder: (context) => Home()));
		// exit(0);
		return Future.value(false);
	}
	Widget _body(){
		return new Form( 
			key :_formKey,
			autovalidate: _autoValidate,
			child: Column(
				// mainAxisAlignment: MainAxisAlignment.center,
				// crossAxisAlignment: CrossAxisAlignment.center,
				children: <Widget>[
					Padding(padding: EdgeInsets.all(25.0)),
					_image == null ? 
					Container(
						child: teamImg,
						width: 130,
						height: 130,
						decoration: BoxDecoration(
							borderRadius:BorderRadius.all(Radius.circular(70.0)),
							color : Colors.white,
						),
					)
					:ClipOval(
						child: Image.file(
							_image,
							fit:BoxFit.cover,
							height: 130,
							width: 130,
						),
					),
					new Padding(padding: EdgeInsets.all(5.0)),
					new Row(
						mainAxisAlignment: MainAxisAlignment.center,
						children: <Widget>[
							new Container(
								height: 30,
								width: 60,
								color: Colors.yellow[100],
								child: new RaisedButton(
									child: Icon(Icons.camera_alt,color:Colors.blue[600]),
									color: Colors.white70,
									onPressed: ()async{
										await getImage(ImageSource.camera);
									}
								),
							),
							new Padding(padding: EdgeInsets.all(2.0)),
							new Container(
								height: 30,
								width: 60,
								color: Colors.yellow[100],
								child: new RaisedButton(
									child: Icon(Icons.image,color:Colors.blue[600]),
									color: Colors.white70,
									onPressed: ()async{
										await getImage(ImageSource.gallery);
									}
								),
							),
						],
					),
					new Padding(padding: EdgeInsets.all(3.0)),
					new Container(
						child: _formUI(),
						padding: EdgeInsets.fromLTRB(15, 5, 15, 15),
						margin: EdgeInsets.all(10),
						decoration: BoxDecoration(
							color : Colors.white70,
							borderRadius: BorderRadius.all(Radius.circular(20.0)),
							boxShadow: [
								BoxShadow(
									color: Colors.black38,
									blurRadius: 30.0, // soften the shadow
									spreadRadius: 7.0, //extend the shadow
									offset: Offset(
										00.0, 
										3.0,
									),
								)
							],
						),
					), 
				],
			),
		);
	} 
	Future getImage(source) async {    
		await ImagePicker.pickImage(source: source).then((image) {    
			setState(() {    
			_image = image;    
			});  
		});    
	}
	Future uploadImg() async {
		try{
			StorageReference storageReference = FirebaseStorage.instance    
				.ref()
				.child('photos/${Path.basename(_image.path)}}');
			StorageUploadTask uploadTask = storageReference.putFile(_image);   
			await uploadTask.onComplete;    
			print('>>>File Uploaded'); 
			await storageReference.getDownloadURL().then((fileURL) {
				setState(() { _urlImg = fileURL; });
			});
		}catch(er){
			print("ER>: ${er.toString()}");
		}
	} 

	Widget _formUI() {
		return new Column(
			children: <Widget>[ 
				new TextFormField(
					controller: _nameCtr,
					decoration: const InputDecoration(labelText: 'Team Name'),
					keyboardType: TextInputType.text,
					obscureText: false,
					validator: validateName,
				),
				new SizedBox(
					height: 20.0,
				), 
				user.role =="prof"
					? new Container(
						child: _selectBranch(),
						padding: const EdgeInsets.fromLTRB(0, 0, 10,0),
					)
					: Container(),
				new SizedBox(
					height: 20.0,
				),
				new FutureBuilder(
					builder: (context, snapshot) {
						if (move) {
							return Center(
								child: new Container(
									width: 40,
									height: 40,
									child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.deepPurple[400])),
								),
							);
						} else {
							return Center(
								child : new Container( //btn
									width: 250,
									height: 50,
									decoration: new BoxDecoration(
										borderRadius: BorderRadius.circular(30.0),
										color: Colors.deepPurple[400],
									),
									child: new FlatButton(
										child : new Text(
											"CREATE",
											style:TextStyle(
												color:Colors.white,
												fontSize: 17
											),
										),
										onPressed: ()async{
											if(_validateInputs() ) {
												if(_branch != null && user.role == 'prof' || _branch == null && user.role != 'prof'){
													print("-------------$_branch");
													setState(() { move = true;});
													List<String> uids = await getMembers(_branch);
													List<String> notRead=[];
													notRead.addAll(uids);
													notRead.remove(user.uid);
													print("MEMBERS = $uids\n$notRead");
													if(_image != null){
														await uploadImg();
													}
													var date = DateTime.now().toUtc();
													var ref = await Firestore.instance.collection("Teams").add({
														'name' : _nameCtr.text,
														'lastMessage' : date,
														'url':_urlImg,
														'notRead' : notRead,
														'members' : uids,
													});
													ref.collection("Messages").add({
														'from' : user.uid,
														'sms' : "Welcome to ${_nameCtr.text} team.",
														'date' : date,
														'type' : 'text',
														'name' : "${_nameCtr.text}",
														'readed' : 'false',
													});
													setState(() { move = false;});
												}else{
													showToast("You have to select a branch", false);
												}
											}
										},
									),
								),
							);
						}
					},
				),
				new Padding(
					padding: const EdgeInsets.all(5),
				),
				new InkWell(
					child: Text(
						"CANCEL",
						style:TextStyle(
							color:Colors.black38,
							fontSize: 16
						),
					),
					onTap: (){
						Navigator.of(context, rootNavigator: true).pop();
					},
				),
			],
		);
	}
	Future<List<String>>getMembers(_branch) async {
		String branchU = _branch;
		List<String> members = [];
		if(user.role != "prof"){
			branchU = user.branch;
		}else{
			members.add(user.uid);
		}
		var docs =	await Firestore.instance.collection("User").where('branch' , isEqualTo:branchU).getDocuments();
		docs.documents.forEach((snapshot){
			var data = snapshot.data;
			members.add(data['uid']);
		});
		return members;
	}
	
	showToast(msg,top){
		Fluttertoast.showToast(
			msg: msg,
			toastLength: Toast.LENGTH_LONG,
			gravity: top? ToastGravity.TOP : ToastGravity.BOTTOM,
		);
	}

	String validateName(String value) {
		if (value.length < 3)
			return 'Enter Valid Name';
		else
			return null;
	}

	bool _validateInputs() {
		if (_formKey.currentState.validate()) {
			return true;
		} else {
			//    If data are not valid then start auto validation.
			setState(() {
			_autoValidate = true;
			});
			return false;
		}
	}

	DropdownButton _selectBranch() => DropdownButton<String>(
		underline:new Divider(
			height: 2.0, 
			indent: 1.0,
			color: Colors.black,
		),
		iconSize: 25,
		onChanged: (value) {
          setState(() {
            _branch = value;
          });
        },
        value: _branch,
		hint: Text(
			"Select the team branch"
		),
		isExpanded: true,
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
	);

}