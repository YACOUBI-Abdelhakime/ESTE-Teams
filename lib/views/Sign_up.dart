import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:chatapp/views/Home.dart';
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
import 'Sign_in.dart';
import 'package:chatapp/main.dart';

final studentImg = CircleAvatar(
	radius: 60,
	backgroundImage: AssetImage('images/student.png'),
);

class Sign_up extends StatefulWidget {
	@override
	Sign_upState createState() => Sign_upState();
}

class Sign_upState extends State<Sign_up> {

	final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
	final GlobalKey<FormState> _formDKey = GlobalKey<FormState>();
	bool _autoValidate = false;
	bool move = false;
	Auth authSrv = Auth();
	Database db ;
	TextEditingController _passCtr = new TextEditingController();
	TextEditingController _pass2Ctr = new TextEditingController();
	TextEditingController _emailCtr = new TextEditingController();
	TextEditingController _nameCtr = new TextEditingController();
	TextEditingController _pnameCtr = new TextEditingController();
	TextEditingController _validEmlCtr = new TextEditingController();
	bool register = false;
	int _code;
	String _urlImg = null;
	static String _pathImg = null;
	File _image;
	String _branch = null;

	

	@override
	Widget build(BuildContext context) {
		return new Scaffold(
			body: WillPopScope(
				child: Container(
					height: 1000,
					decoration: new BoxDecoration(
						gradient: new LinearGradient(
							begin: Alignment.center,//.centerRight,
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
							Padding(padding: EdgeInsets.all(25.0)),
							_image == null ? 
							Container(
								child: studentImg,
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
								//onChanged: (val){_nameCtr.text = "${val[0].toUpperCase()}${val.substring(1)}";},
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
								//onChanged: (val){_pnameCtr.text = val.toUpperCase();},
							),
						),
					],
        		),
				new SizedBox(
					height: 10.0,
				),
				Container(
					child: _selectBranch(),
					padding: const EdgeInsets.fromLTRB(0, 0, 10,0),
				),
				new TextFormField(
					controller: _emailCtr,
					decoration: const InputDecoration(labelText: 'Email'),
					keyboardType: TextInputType.emailAddress,
					validator: validateEmail,
				),
				new TextFormField(
					controller: _passCtr,
					decoration: const InputDecoration(labelText: 'Password'),
					keyboardType: TextInputType.text,
					obscureText: true,
					validator: validatePass,
				),
				new TextFormField(
					controller: _pass2Ctr,
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
												if(_branch != null){
													setState(() { move = true;});
													var rep = await sendEmail(_emailCtr.text);
													if(rep == "ok"){
														dialog(context);
													}else if(rep == "cnx"){
														setState(() { move = false;});
														print("there is no connection.");
														showToast("there is no connection.",true);
													}else {
														setState(() { move = false;});
														print("Unknown error, try later.");
														showToast("Unknown error, try later.",true);
													}
												}else{
													print("Select branche plase.");
													showToast("Select branche plase.",true);
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
						Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Sign_in()));
					},
				),
			],
		);
	}

	dynamic sendEmail(email) async {
		final smtpServer = gmail(myEmail, myPass);
		_code = getCode();
		final message = Message()
			..from = Address(myEmail)
			..recipients.add(email)
			..subject = 'Email Validation'
			..html = "<h1 style='color : red;'>ESTE_TEAMS</h1><h3>Hello ${_pnameCtr.text},</h3><p>Your verification code is <span style='color: blue;'>$_code</span><br/><br/><B style='color: orange;'>welcome to ESTE_TEAMS.</B></p>";
		try {
			final sendReport = await send(message, smtpServer);
			print('Message sent:<$_code> ' + sendReport.toString());
			return "ok";
		}on MailerException catch (e) {
			print('ERmilExpt>:'+e.toString());
			return "no";
		}on SocketException catch(er){
			print("ERsokt:"+er.toString());
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

	dialog(context) {
		bool ok = false;
		Alert(
			context: context,
			title: "Validation Email",
			style :  AlertStyle(
				animationType: AnimationType.fromTop,
				isCloseButton: false,
				isOverlayTapDismiss: false,
				animationDuration: Duration(milliseconds: 400),
				alertBorder: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(20.0),
					side: BorderSide(
						color: Colors.deepPurple,
						width:2,
					),
				),
				titleStyle: TextStyle(
					color: Colors.deepPurple,
				),
			), 
			content: Container(
				child: Form(
					key: _formDKey,
					autovalidate: false,
					child: Column(
						children: <Widget>[
							new Padding(padding: const EdgeInsets.all(2)),
							new TextFormField(
								controller: _validEmlCtr,
								decoration: const InputDecoration(labelText: 'Code'),
								keyboardType: TextInputType.number,
								obscureText: false,
								validator: validateCode,
							),
							new Padding(padding: const EdgeInsets.all(7)),
							new Text(
								"We will send your validation code to this email address.",
								style: TextStyle(
									fontSize: 16,
									fontWeight: FontWeight.normal,
									color:Colors.black38,
								)
							),
						],
					),
				),
			),
			buttons: [
				DialogButton(
					child: Text(
						"CANCEL",
						style: TextStyle(color: Colors.white, fontSize: 20),
					),
					onPressed: (){
						_validEmlCtr.clear();
						ok = false;
						Navigator.of(context, rootNavigator: true).pop();
					},
					color: Colors.deepPurple[400],
				),
				DialogButton(
					child: Text(
						"Validate",
						style: TextStyle(color: Colors.white, fontSize: 20),
					),
					onPressed: (){
						if(_formDKey.currentState.validate()){
							ok = true;
							_validEmlCtr.clear();
							Navigator.of(context, rootNavigator: true).pop();
						}else{
							ok = false;
						}	
					},
					color: Colors.deepPurple[400],
				),
			],
		).show()
		.then((val) async {
			print("ok = $ok");
			if(ok){
				var rep = await authSrv.register(email : _emailCtr.text,pass : _passCtr.text ,
        		name : "${_nameCtr.text[0].toUpperCase()}${_nameCtr.text.substring(1).toLowerCase()}",pname : "${_pnameCtr.text.toUpperCase()}",branch : _branch , role : "student");
				
				if(rep == "ok"){
					if(_image != null){
						await uploadImg();
						Firestore.instance.collection("User")
						.document(user.uid)
						.updateData({
							"urlImg" : _urlImg,
						});
						user.setUrl(_urlImg);
					}
					setState(() { move = false;});
					Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Home()));
				}else if(rep == "FirebaseException"){//pas cnx
					print("there is no connection.");
					showToast("there is no connection.",true);
					setState(() { move = false;});
				}else if(rep == "ERROR_EMAIL_ALREADY_IN_USE"){
					print("The email address is already in use by another account.");
					showToast("The email address is already in use by another account.",true);
					setState(() { move = false;});
				}else if(rep == "other"){
					showToast("Unknown error, try later.",true);
					setState(() { move = false;});
				}
			}else{
				print("Cancel in then");
				setState(() { move = false;});
			}
		});	
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
		if (value != _passCtr.text)
			return 'Password not correct';
		else
			return null;
	}

	String validateCode(String value) {
		if (value != "$_code")
			return 'Code not correct.';
		else
			return null;
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