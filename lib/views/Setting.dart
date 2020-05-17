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


class Setting extends StatefulWidget {
	@override
	SettingState createState() => SettingState();
}

class SettingState extends State<Setting> {

	final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
	final GlobalKey<FormState> _formDKey = GlobalKey<FormState>();
	bool _autoValidate = false;
	bool move = false;
	Auth authSrv = Auth();
	Database db ;
	TextEditingController _nameCtr = new TextEditingController();
	TextEditingController _pnameCtr = new TextEditingController();
	String _urlImg;
	File _image;
	String _branch ;
	bool _branchChanged = false,_nameChanged = false,_pnameChanged = false;

	

	@override
	Widget build(BuildContext context) {
		
		
		if(!_pnameChanged){
			_pnameCtr.text = user.pname;
		}
		if(!_nameChanged){
			_nameCtr.text = user.name;
		}
		if(!_branchChanged){
			_branch = user.branch;
		}
		return new Scaffold(
			appBar: AppBar(
				backgroundColor: Colors.deepPurple,
				centerTitle: true,
				title : Text(
					"SETTING",
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
					child: _body(),
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
		return new SingleChildScrollView(
			child: Center(
				child: new Form(
					key: _formKey,
					autovalidate: _autoValidate,
					child: Column(
						children: <Widget>[
							new Padding(padding: EdgeInsets.all(9.0)),
							new Container(
								height: 230,
								width: 230,
								child: Material(
									child: _image == null 
									? user.urlImg != null 
										? cachImg(user.urlImg ,5.0)
										: user.role == 'student'
											? stdImg
											: profImg
									: ClipOval(
										child: Image.file(
											_image,
											fit:BoxFit.cover,
											height: 130,
											width: 130,
										),
									),
									borderRadius: BorderRadius.all(Radius.circular(400.0)),
									clipBehavior: Clip.hardEdge,
								),
							),
							new Padding(padding: EdgeInsets.all(2.0)),
							new Row(
								mainAxisAlignment: MainAxisAlignment.center,
								children: <Widget>[
									new Container(
										height: 30,
										width: 60,
										color: Colors.yellow[100],
										child: new RaisedButton(
											child: Icon(Icons.camera_alt,color:Colors.deepPurple),
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
											child: Icon(Icons.image,color:Colors.deepPurple),
											color: Colors.white70,
											onPressed: ()async{
												await getImage(ImageSource.gallery);
											}
										),
									),
								],
							),
							new Padding(padding: EdgeInsets.all(3.0)),
							Container(
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
				),
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
				new Row(
					children: <Widget>[
						new Expanded(
							flex:1,
							child: new TextFormField(
								controller: _nameCtr,
								decoration: const InputDecoration(labelText: 'First Name'),
								keyboardType: TextInputType.text,
								obscureText: false,
								validator: validateName,
								onChanged: (val){_nameChanged = true;},
							),
						),
						new Padding(
							padding: const EdgeInsets.all(2),
						),
						new Expanded(
							flex:1,
							child: new TextFormField(
								controller: _pnameCtr,
								decoration: const InputDecoration(labelText: 'Last Name'),
								keyboardType: TextInputType.text,
								obscureText: false,
								validator: validateName,
								onChanged: (val){_pnameChanged = true;},
							),
						),
					],
        		),
				new SizedBox(
					height: 20.0,
				),
				user.role != 'prof' 
					?	Container(
							child: _selectBranch(),
							padding: const EdgeInsets.fromLTRB(0, 0, 10,0),
						)
					: 	Container(),
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
											"UPDATE",
											style:TextStyle(
												color:Colors.white,
												fontSize: 17
											),
										),
										onPressed: ()async{
											if(_validateInputs() ) {
												setState(() { move = true;});
												if(_image != null){ await uploadImg();}
												var nameU = "${_nameCtr.text[0].toUpperCase()}${_nameCtr.text.substring(1).toLowerCase()}";
												var pnameU = "${_pnameCtr.text.toUpperCase()}";
												setState(() {
													user = User(uid:user.uid, email: user.email, name: nameU, pname: pnameU, branch: _branch, role: user.role, urlImg: _image != null ?  _urlImg : user.urlImg);
												});
												Firestore.instance.collection("User").document(user.uid).updateData({
													'name' : user.name,
													'pname' : user.pname,
													'branch':user.branch,
													'urlImg' : user.urlImg,
												}); 
												setState(() { move = false;_pnameCtr.text = pnameU;_nameCtr.text = nameU;});
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
			_branchChanged = true;
          });
        },
        value: _branch,
		hint: Text(
			"select your branch"
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