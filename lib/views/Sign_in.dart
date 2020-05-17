import 'dart:io';
import 'package:flutter/services.dart';
import 'package:chatapp/views/Home.dart';
import 'package:chatapp/views/Setting.dart';
import 'package:chatapp/views/Sign_up.dart';
import 'package:chatapp/services/Auth.dart';
import 'package:chatapp/views/admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Sms.dart';
import 'ForgotPass.dart';
import 'package:chatapp/models/User.dart';

User user = null;

final logo = CircleAvatar(
		backgroundImage: AssetImage('images/logo.png'),
		radius: 20,
	);

class Sign_in extends StatefulWidget {
	@override
	Sign_inState createState() => Sign_inState();
}

class Sign_inState extends State<Sign_in> {

	final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
	bool _autoValidate = false;
	bool move = false;
	Auth authSrv = Auth() ;
	TextEditingController _passCtr = new TextEditingController();
	TextEditingController _emailCtr = new TextEditingController();
	

@override
	Widget build(BuildContext context) {
		return new Scaffold(
			body: WillPopScope(
				child: Container(
					height: 1000,
					decoration: new BoxDecoration(
						gradient: new LinearGradient(
							begin: Alignment.center,
							end: new Alignment(1.0, 1.0),
							colors: [
								Colors.deepPurple[400],
								Colors.purple[300],
								Colors.blue,
							]
						)
					),
					child: _body(),
				), 
				onWillPop: onBackPress,
			)
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
							Padding(padding: EdgeInsets.all(40.0)),
							Container(
								child: logo ,
								width: 150,
								height: 150,
							),
							Padding(padding: EdgeInsets.all(20.0)),
							Container(
								child: _formUI(),
								padding: EdgeInsets.fromLTRB(15, 15, 15, 30),
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
	
	Widget _formUI() {
		return new Column(
			children: <Widget>[
				new TextFormField(
					controller: _emailCtr,
					keyboardType: TextInputType.emailAddress,
					validator: validateEmail,
					style: new TextStyle( fontSize: 17),
					decoration: const InputDecoration(labelText: 'Email'),
					toolbarOptions: ToolbarOptions(
						copy: true, 
						cut: true, 
						selectAll: false, 
						paste: true
					),
				),
				new TextFormField(
					controller: _passCtr,
					decoration: const InputDecoration(labelText: 'Password'),
					keyboardType: TextInputType.text,
					obscureText: true,
					validator: validatePass,
					style: new TextStyle( fontSize: 17),
				),
				new SizedBox(
					height: 30.0,
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
													"SIGN IN",
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
											if(_validateInputs()) {
												setState(() { move = true;});
												var rep = await authSrv.signIn(_emailCtr.text,_passCtr.text);
												setState(() { move = false;});
												print("REp = $rep");
												if(rep == "ok"){
													goHome();
												}else if(rep == "FirebaseException"){//pas cnx
													print("there is no connection.");
													showToast("there is no connection.",false);
												}else if(rep == "ERROR_WRONG_PASSWORD" || rep == "ERROR_USER_NOT_FOUND"){
													print("Could not sign in with those credentials.");
													showToast("Could not sign in with those credentials.",false);
												}else if(rep == "other"){
													print("Unknown error, try later.");
													showToast("Unknown error, try later.",false);
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
				new Row(
					mainAxisAlignment : MainAxisAlignment.center,
					children: <Widget>[
						new InkWell(
							child: Text(
								"Sign up",
								style:TextStyle(
									color:Colors.black38,
									fontSize: 16
								),
							),
							onTap: (){
								Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Sign_up()));
							},
						),
						new InkWell(
							child: Text(
								" | ",
								style:TextStyle(
									color:Colors.black38,
									fontSize: 16
								),
							),
						),
						new InkWell(
							child: Text(
								"Forgot Password?",
								style:TextStyle(
									color:Colors.black38,
									fontSize: 16
								),
							),
							onTap: (){
								Navigator.push(context, new MaterialPageRoute(builder: (context)=> new ForgotPass()));
							},
						),
					]
				),
			],
		);
	}

	goHome(){
		try{
			if(user.role == "admin"){
				Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Admin()));
			}else{
				Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Home()));
			}
		}catch(er){
			print("ERROR : "+er.toString());
			showToast("Unknown error, try agine.",false);
		}
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

	String validateEmail(String value) {
		Pattern pattern =
			r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
		RegExp regex = new RegExp(pattern);
		if (!regex.hasMatch(value))
			return 'Enter Valid Email';
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