import 'dart:io';
import 'dart:math';
import 'package:chatapp/views/Admin.dart';
import 'package:chatapp/views/Home.dart';
import 'package:chatapp/views/Sign_up.dart';
import 'package:chatapp/services/Auth.dart';
import 'package:chatapp/services/Database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

/*final studentImg = CircleAvatar(
	radius: 60,
	backgroundImage: AssetImage('images/student.png'),
);*/

class UpdatePass extends StatefulWidget {
	@override
	UpdatePassState createState() => UpdatePassState();
}

class UpdatePassState extends State<UpdatePass> {

	final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
	bool _autoValidate = false;
	bool move = false;
	Auth authSrv = Auth();
	Database db ;
	TextEditingController _newPassCtr = new TextEditingController();
	TextEditingController _confPassCtr = new TextEditingController();
	TextEditingController _oldePassCtr = new TextEditingController();
	bool register = false;

	

	@override
	Widget build(BuildContext context) {
		return new Scaffold(
			appBar: AppBar(
				centerTitle: true,
				title: Text("CHANGE PASSWORD"),
				backgroundColor: Colors.deepPurple,
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
				onWillPop: onBackPress,
			),
		);
	}
	Future<bool> onBackPress() {
		Navigator.push(context, new MaterialPageRoute(builder: (context)=> user.role !='admin'? new Home() : new Admin()));
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
							new Padding(padding: EdgeInsets.all(25.0)),
							new Container(
								height: 130,
								width: 130,
								child: Material(
									child: user.urlImg != null
										? cachImg(user.urlImg ,5.0)
										: user.role == 'student'
											? stdImg
											: user.role == 'prof'
												? profImg
												: adminLogo,
									borderRadius: BorderRadius.all(Radius.circular(400.0)),
									clipBehavior: Clip.hardEdge,
								),
							),
							new Padding(padding: EdgeInsets.all(20.0)),
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
							//new Expanded(flex:1 ,child: Container(),),
						],
					),
				),
			),
		);
	}
	Widget _formUI() {
		return new Column(
			children: <Widget>[
				new TextFormField(
					controller: _oldePassCtr,
					decoration: const InputDecoration(labelText: 'Olde Password'),
					keyboardType: TextInputType.text,
					obscureText: true,
					validator: validatePass,
				),
				new TextFormField(
					controller: _newPassCtr,
					decoration: const InputDecoration(labelText: 'New Password'),
					keyboardType: TextInputType.text,
					obscureText: true,
					validator: validatePass,
				),
				new TextFormField(
					controller: _confPassCtr,
					decoration: const InputDecoration(labelText: 'Conferm Password'),
					keyboardType: TextInputType.text,
					obscureText: true,
					validator: validatePass2,
				),
				new SizedBox(
					height: 15.0,
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
										child : new Row( 
											children: <Widget>[
												new Text(
													"UPDATE",
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
										onPressed: ()async{
											if(_validateInputs() ) {
												setState(() { move = true;});
												if(user.pass == _oldePassCtr.text){
													var userX = await FirebaseAuth.instance.currentUser();
													userX.updatePassword(_newPassCtr.text);
													await Firestore.instance.collection("User")
													.document(user.uid)
													.updateData({'pass': _newPassCtr.text});
													user.setPass(_newPassCtr.text);
													_oldePassCtr.clear();
													_newPassCtr.clear();
													_confPassCtr.clear();
													//remove focuse in Text Fields
													FocusScopeNode currentFocus = FocusScope.of(context);
													if (!currentFocus.hasPrimaryFocus) {
														currentFocus.unfocus();
													}
													setState(() { _autoValidate = false; });
													showToast("The password is changed.",false);
												}else{
													showToast("Olde password is not correct.",false);
												}
												setState(() { move = false;});										
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
						Navigator.push(context, new MaterialPageRoute(builder: (context)=> user.role !='admin'? Home(): Admin()));
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

	String validatePass(String value) {
		if (value.length < 8)
			return 'Password must be more than 8 charater';
		else
			return null;
	}

	String validatePass2(String value) {
		if (value != _newPassCtr.text)
			return 'Password not correct';
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
}