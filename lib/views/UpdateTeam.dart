import 'dart:async';
import 'dart:io'; 
import 'package:chatapp/views/AddTeam.dart';
import 'package:chatapp/views/ChaTeam.dart';
import 'package:chatapp/views/Home.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:path/path.dart' as Path; 
import 'Sign_in.dart'; 
import 'package:chatapp/models/User.dart';


class UpdateTeam extends StatefulWidget {
	@override
	UpdateTeamState createState() => UpdateTeamState();
}

class UpdateTeamState extends State<UpdateTeam> {

	final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
	bool _autoValidate = false;
	bool move = false;
	TextEditingController _nameCtr = new TextEditingController();
	String _urlImg;
	File _image;
	bool _nameChanged = false;

	

	@override
	Widget build(BuildContext context) {
		if(!_nameChanged){
			_nameCtr.text = nameTeam;
		}
		return new Scaffold(
			appBar: AppBar(
				backgroundColor: Colors.deepPurple,
				centerTitle: true,
				title : Text(
					"TEAM SETTING",
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
									? urlImgTeam != null 
										? cachImg(urlImgTeam ,5.0)
										: teamImg
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
				new TextFormField(
					controller: _nameCtr,
					decoration: const InputDecoration(labelText: 'Team Name'),
					keyboardType: TextInputType.text,
					obscureText: false,
					validator: validateName,
					onChanged: (val){_nameChanged = true;},
				),
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
												if(_image != null || _nameCtr.text != nameTeam){
													setState(() { move = true;});
													var nameT = _nameCtr.text;
													if(_image != null){ 
														await uploadImg();
														await Firestore.instance.collection("Teams").document(uidTeam).updateData({
															'url' : _urlImg,
														});
													}
													if(_nameCtr.text != nameTeam){
														await Firestore.instance.collection("Teams").document(uidTeam).updateData({
															'name' : nameT,
														});
													}
													setState(() { move = false;});
													Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Home()));
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
						// Navigator.push(context, new MaterialPageRoute(builder: (context)=>  Home()));
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

}