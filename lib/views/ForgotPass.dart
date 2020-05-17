import 'dart:math';

import 'package:chatapp/views/Sign_in.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/services/Auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'Sms.dart';


class ForgotPass extends StatefulWidget {
	@override
	ForgotPassState createState() => ForgotPassState();
}

class ForgotPassState extends State<ForgotPass> {

	final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
	bool _autoValidate = false;
	Auth authSrv = Auth() ;
	bool move = false;
	String ui = "email";
	int _code;
	TextEditingController _passCtr = new TextEditingController();
	TextEditingController _pass2Ctr = new TextEditingController();
	TextEditingController _codeCtr = new TextEditingController();
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
				onWillPop: null,
			),
		);
	}
	Future<bool> onBackPress() {
		//Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Sms()));
		// exit(0);
		// return Future.value(false);
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
								child: ui == "email" ? _emailUI() : _newPassUI(),
								padding: EdgeInsets.fromLTRB(15, 15, 15, 20),
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
	Widget _newPassUI() {
		return new Column(
			children: <Widget>[
				new TextFormField(//code
					controller: _codeCtr,
					keyboardType: TextInputType.phone,
					validator: validateCode,
					style: new TextStyle( fontSize: 17),
					decoration: const InputDecoration(labelText: 'Code'),
					toolbarOptions: ToolbarOptions(
						copy: true, 
						cut: true, 
						selectAll: false, 
						paste: true
					),
				),
				new TextFormField(//pass
					controller: _passCtr,
					decoration: const InputDecoration(labelText: 'Password'),
					keyboardType: TextInputType.text,
					obscureText: true,
					validator: validatePass,
					style: new TextStyle( fontSize: 17),
				),
				new TextFormField(//confPass
					controller: _pass2Ctr,
					decoration: const InputDecoration(labelText: 'Conferm Password'),
					keyboardType: TextInputType.text,
					obscureText: true,
					validator: validatePass2,
					style: new TextStyle( fontSize: 17),
				),
				new SizedBox(
					height: 20.0,
				),
				new FutureBuilder(//btn
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
													"FINISH",
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
												var rep;
												if(_code.toString() == _codeCtr.text){
													rep = await _updatePass(_emailCtr.text,_passCtr.text);
													setState(() { move = false;});
													if(rep == "ok"){
														//Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Sms()));
													}else {
														print("Unknown error, try later.");
														showToast("Unknown error, try later.",false);
													}
												}else{
													setState(() { move = false;});
													print("your verification code is incorrect");
													showToast("your verification code is incorrect",false);
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
						Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Sign_in()));
					},
				),
			],
		);
	}
	Widget _emailUI() {
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
				new SizedBox(
					height: 30.0,
				),
				new Container(
					padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
					child: Text(
						"We will send your verification code to this email address.",
						style:TextStyle(
							color:Colors.black38,
							fontSize: 15,
						),
					),
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
													"SEND",
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
												var rep = await sendEmail(_emailCtr.text);
												//var rep = "ok";
												setState(() { move = false;});
												if(rep == "ok"){
													setState(() { ui = "pass";});
												}else if(rep == "cnx"){
													print("there is no connection.");
													showToast("there is no connection.",false);
												}else {
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
					padding: const EdgeInsets.all(10),
				),
				new Row(
					mainAxisAlignment : MainAxisAlignment.center,
					children: <Widget>[
						new InkWell(
							child: Text(
								"CANCEL",
								style:TextStyle(
									color:Colors.black38,
									fontSize: 16
								),
							),
							onTap: (){
								Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Sign_in()));
							},
						),
					]
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
	
	dynamic _updatePass(email,newPass)async{
		String emailX;
		String passX;
		String uidX;
		try{
			await Firestore.instance.collection("User")
			.where('email',isEqualTo:email)
			.getDocuments()
			.then((QuerySnapshot snapshot) {
				snapshot.documents.forEach((res) {
					var data = res.data;
					emailX = data["email"];
					passX = data["pass"];
					uidX = data["uid"];
				});
			});
			var res = await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailX, password: passX);
			var user = res.user;
			user.updatePassword(newPass);
			await Firestore.instance.collection("User")
			.document(uidX)
			.updateData({'pass': newPass});
			return "ok";
		}catch(er){
			return "other";
		}
	}
	
	dynamic sendEmail(email) async {
		final smtpServer = gmail(myEmail, myPass);
		_code = getCode();
		final message = Message()
			..from = Address(myEmail)
			..recipients.add(email)
			..subject = 'Reset your password'
			..text = 'your verification code is $_code';
		try {
			final sendReport = await send(message, smtpServer);
			print('Message sent: ' + sendReport.toString());
			return "ok";
		}on MailerException catch (_) {
			//print('ERmilExpt>:'+e.toString());
			return "no";
		}on SocketException catch(_){
			//print("ERsokt:"+er.toString());
			return "cnx";
		} catch(er){
			print("ERother>:"+er.toString());
			return "other";
		}
	} 

	int getCode(){
		var max = 9999;
		var min = 1000;
		Random rnd = new Random();
		return min + rnd.nextInt(max - min + 1 );
	}

	String validatePass(String value) {
		if (value.length < 8)
			return 'Password must be more than 8 charater';
		else
			return null;
	}

	String validatePass2(String value) {
		if (value != _passCtr.text)
			return 'Password not correct';
		else
			return null;
	}

	String validateCode(String value) {
		if (value.length != 4)
			return 'Code contain 4 numbers';
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