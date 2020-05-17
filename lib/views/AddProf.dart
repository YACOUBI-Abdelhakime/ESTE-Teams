import 'dart:io';
import 'dart:math';
import 'package:chatapp/services/Auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'Admin.dart';
import 'package:chatapp/main.dart';


class AddProf extends StatefulWidget {
	@override
	AddProfState createState() => AddProfState();
}

class AddProfState extends State<AddProf> {

	final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
	bool _autoValidate = false;
	bool move = false;
	Auth authSrv = Auth();
	TextEditingController _emailCtr = new TextEditingController();
	TextEditingController _nameCtr = new TextEditingController();
	TextEditingController _pnameCtr = new TextEditingController();



	@override
	Widget build(BuildContext context) {
		return new  Scaffold(
			appBar: AppBar(
				title: Text(
					"REGISTER A PROFESSOR",
					style: TextStyle(
						fontFamily: "times new roman",
						fontWeight: FontWeight.bold
					),
				),
				centerTitle: true,
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
								//Colors.deepPurple[400],
								Colors.deepPurple,
								Colors.deepPurple,	
							]
						)
					),
					child: _body(),
				), 
				onWillPop: null
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
							),
						),
					],
        		),
				new TextFormField(
					controller: _emailCtr,
					decoration: const InputDecoration(labelText: 'Email'),
					keyboardType: TextInputType.emailAddress,
					validator: validateEmail,
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
													"REGISTER",
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
												var code = getCode();
												String passProf = _pnameCtr.text+_nameCtr.text+"$code";
												var rep = await authSrv.register(email:_emailCtr.text,pass : passProf,name : "${_nameCtr.text[0].toUpperCase()}${_nameCtr.text.substring(1)}",pname : "${_pnameCtr.text.toUpperCase()}",role: "prof");
				
												if(rep == "ok"){
													sendEmail(_emailCtr.text,passProf);
													showToast("The professor is added.",false);
													_emailCtr.clear();
													_nameCtr.clear();
													_pnameCtr.clear();
													setState(() { move = false;});
													//Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Sms()));
												}else if(rep == "FirebaseException"){//pas cnx
													print("There is no connection.");
													showToast("there is no connection.",false);
													setState(() { move = false;});
												}else if(rep == "ERROR_EMAIL_ALREADY_IN_USE"){
													print("The email address is already in use by another account.");
													_emailCtr.clear();
													showToast("The email address is already in use by another account.",false);
													setState(() { move = false;});
												}else if(rep == "other"){
													showToast("Unknown error, try later.",false);
													setState(() { move = false;});
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
					padding: const EdgeInsets.all(3),
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
						Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Admin()));
					},
				),
			],
		);
	}

	dynamic sendEmail(email,pass) async {
		final smtpServer = gmail(myEmail, myPass);

		final message = Message()
			..from = Address(myEmail)
			..recipients.add(email)
			..subject = 'New Account in ESTE_CHAT'
			..html = "<h2>Hello ${_pnameCtr.text},</h2><p>The admine of <B style='color : red;'>ESTE_TEAMS</B>  is create an account for you:<br/>login: <B style='color : green;'>$email</B><br/>password: <B style='color : green;'>$pass</B><br/><br/>Download the ESTE_TEAMS application with this link: <a href=$urlApp style='color:blue;'><B>here</B></a><br/><br/>Finally please change your password for better security<br/><br/><B style='color: orange;'>welcome to ESTE_TEAMS.</B></p>";
			
		try {
			final sendReport = await send(message, smtpServer);
			print('Message sent:<$pass> ' + sendReport.toString());
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
		var max = 99;
		var min = 10;
		Random rnd = new Random();
		return min + rnd.nextInt(max - min + 1 );
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