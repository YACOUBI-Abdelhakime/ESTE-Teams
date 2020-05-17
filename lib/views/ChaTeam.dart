import 'dart:async';
import 'dart:io';
import 'package:chatapp/models/Message.dart';
import 'package:chatapp/models/SmsTeam.dart';
import 'package:chatapp/views/FulImage.dart';
import 'package:chatapp/Wrapp.dart';
import 'package:chatapp/views/FulPdf.dart';
import 'package:chatapp/views/FulVideo.dart';
import 'package:chatapp/views/InfoTeam.dart';
import 'package:chatapp/views/Sign_in.dart';
import 'package:chatapp/views/Home.dart';
import 'package:chatapp/views/UpdateTeam.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_sound/flutter_sound_player.dart';
import 'package:flutter_sound/flutter_sound_recorder.dart';

bool upoadingFile = false;
String uidTeam;
String nameTeam;
String urlImgTeam;

class ChaTeam extends StatefulWidget {
	ChaTeam(String uid,String name,String urlImg){
		uidTeam = uid;
		nameTeam = name;
		urlImgTeam = urlImg;
	}
  @override
  ChaTeamState createState() => ChaTeamState();
}

class ChaTeamState extends State<ChaTeam> {

	final ScrollController listScrollController = new ScrollController();
	TextEditingController _messageCtr = new TextEditingController();
	bool isWriting = false;
	bool isRecorde = false;
	bool isLoading = false;
	Map<String, String> _paths;
	List<String> _doc = ['pdf'];
	FileType _pickType = FileType.any;
	String messageType;
	List<String> uidNotRead = [];
	FlutterSoundRecorder audioRecord ;
	FlutterSoundPlayer audioPlayer ;
	StreamSubscription recordSub;
	StreamSubscription playerSub;
	String pathRec;
	String urlPlaying;
	String timerAudio = '00:00';
	String timerRec = '00:00';
	String stateAudio = 'pause';
	bool move = false;
	bool isStopRec = false;
	String pathImg;
	List<String> tokens = [];
	List<String> members = [];
	List<Choice> choices = const <Choice>[
		const Choice(title: 'Infos', icon: Icons.info),
		const Choice(title: 'Settings', icon: Icons.settings),
	];


	void addSms(message,type) async {
		var date = DateTime.now().toUtc();
		tokens.clear();

		await Firestore.instance.collection("Teams").document(uidTeam).collection('Messages').add({
			'date' : date,
			'name' : user.pname +" "+ user.name,
			'sms' : message,
			'type':	type,
			'readed':'false',
			'from' : user.uid,
		});
		var doc = await Firestore.instance.collection("Teams").document(uidTeam).get();
		var list = List.from(doc.data['members']);
		members = List.from(doc.data['members']);
		list.remove(user.uid);
		await Firestore.instance.collection("Teams").document(uidTeam).updateData({
			'lastMessage' : date,
			'notRead' : list,
		});
		var users = await Firestore.instance.collection("User").where('uid',whereIn : list).getDocuments();
		users.documents.forEach((doc){
			var data = doc.data;
			var token = data['deviceToken'];
			if(token != null){
				tokens.add(token);
			}
		});
		var br = user.role != 'prof' ? user.branch: 'Prof';
		tokens.forEach((token){
			print("$token");
			sendFirebaseNotif('New group message','${user.pname} ${user.name} "$br"',token);
		});
		
	}

	@override
	void initState(){
		super.initState();
		initRecord();
	}
	@override
  	void dispose() {
    	audioRecord.release();
    	audioPlayer.release();
    	super.dispose();
  	}

	initRecord()async{
		audioRecord = await FlutterSoundRecorder().initialize();
		audioPlayer = await FlutterSoundPlayer().initialize();
	}

	_readMessage()async{
		//Change notRead --> Home
		var doc = await Firestore.instance.collection("Teams").document(uidTeam).get();
		var notRead = List.from(doc.data['notRead']);
		user != null ? notRead.remove(user.uid) : notRead.remove("WALO");
		await Firestore.instance.collection("Teams")
			.document(uidTeam ).updateData({
				'notRead':notRead,
			});

		uidNotRead.clear(); 
		//change Chat state
		await Firestore.instance.collection("Teams").document(uidTeam).collection('Messages')
		.where('readed',isEqualTo : 'false').getDocuments()
		.then((snapshot){
			snapshot.documents.forEach((doc){
				uidNotRead.add(doc.documentID);
			});
		});
		uidNotRead.forEach((smsId) async {
			await Firestore.instance.collection("Teams").document(uidTeam).collection('Messages').document(smsId)
			.updateData({
				'readed':'true',
			});
		});

	}
	
	@override
	Widget build(BuildContext context){
		_readMessage();
		return Scaffold(
			appBar: new AppBar(
				centerTitle:true,
				title: Text(
						"$nameTeam",
						style: TextStyle(
						fontFamily: "times new roman",
						fontWeight: FontWeight.bold,
						color: Colors.white,
					),
					),
				backgroundColor: Colors.deepPurple,
				actions: <Widget>[
					_menu(),
				],
			),
			body:WillPopScope(
				child: Stack(
					children:<Widget>[
						Container(
							color: Color.fromRGBO(230, 230, 230, 1.0),
							child: Column(
								children:<Widget>[
									Expanded(child: _buildBody(context)),
									upoadingFile ? uploadinMsessage() : Container(),
									_messageInput(),
								],
							),
						),
						loading(),
					],
				),
				onWillPop: null,
			)
		);
	}
	Future<bool> onBackPress() {
		Navigator.push(context, new MaterialPageRoute(builder: (context)=> new Home()));
		return Future.value(false);
	}

	dynamic _menu(){
		return PopupMenuButton<Choice>(
			onSelected: onItemMenuPress,
			itemBuilder: (BuildContext context) {
				return choices.map((Choice choice) {
					return PopupMenuItem<Choice>(
						value: choice,
						child: Row(
							children: <Widget>[
								Icon(
									choice.icon,
									color: Colors.deepPurple,
								),
									Container(
									width: 10.0,
								),
								Text(
									choice.title,
									style: TextStyle(color: Colors.black),
								),
							],
						)
					);
				}).toList();
			},
		);
	}
	Future<void> onItemMenuPress(Choice choice) async {
		 if (choice.title == 'Settings'){
			// Settigns
			Navigator.push(context, new MaterialPageRoute(builder: (context)=> new UpdateTeam()));
		}else{
			//GET MEMBERS
			var memb = await Firestore.instance.collection("Teams").document(uidTeam).get();
			members = List.from(memb.data['members']);
			Navigator.push(context, new MaterialPageRoute(builder: (context)=> new InfoTeam(members)));
		}
	}

	Widget _buildBody(BuildContext context) {
		return StreamBuilder<QuerySnapshot>(
			stream: Firestore.instance.collection("Teams").document(uidTeam)
			.collection('Messages').orderBy('date',descending:true).snapshots(),
			builder: (context, snapshot) {
				if (!snapshot.hasData) {
					return Center(
						child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple))
					);
				}else{
					var data = snapshot.data.documents;
					return ListView.builder(
						scrollDirection: Axis.vertical,
						shrinkWrap: true,
						padding: const EdgeInsets.only(top: 5.0,left:3,right:3,bottom: 5),
						itemBuilder: (context, index) => _buildListItem(context, data[index]),
						itemCount: data.length,
						reverse: true,
					 	controller: listScrollController,
					);
				}
			},
		);
	}
	Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
		final record = SmsTeam.fromSnapshot(data);
		if(record.toMe){
			if(record.type == 'text'){
				return _smsLeft(context,record);
			}else{
				return _fileLeft(context,record);
			}
		}else{
			if(record.type == 'text'){
				return _smsRight(context,record);
			}else{
				return _fileRight(context,record);
			}
		}		
	}

	Widget _fileRight(BuildContext context,record){
		return Container(
			margin: EdgeInsets.only(
					top: 8.0,
					bottom: 8.0,
					left: 80.0,
					),
			padding: EdgeInsets.fromLTRB(10, 8, 10, 3),
			width: MediaQuery.of(context).size.width * 0.75,
			height: record.type == 'image' 
			? null
			: (record.type != 'music' && record.type != 'audio') 
				? 140
				:80,
			decoration: BoxDecoration(
				color: Colors.lightBlue[100] ,
				borderRadius:  BorderRadius.all(Radius.circular(10.0)),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.center,
				mainAxisAlignment: MainAxisAlignment.center,
				children: <Widget>[
					(record.type != 'music' && record.type != 'audio' && record.type != 'image') ? new Text(
						record.message.split('?')[0].split('%2F').last,
					) : Container(),
					record.type == 'image'
						? InkWell(
							child: cachImg(record.message,4.0),
							onTap:(){Navigator.push( context, MaterialPageRoute(builder: (context) => FulImage(record.message)));},
						)
						: record.type == 'video'
							? InkWell(
								child: Icon(Icons.videocam,size:68,color:Colors.blue[800]),
								onTap:(){Navigator.push( context, MaterialPageRoute(builder: (context) => FulVideo(record.message)));}
							)
							: (record.type == 'music'||record.type == 'audio')
								?  audioContent(record)
								: record.type == 'doc'
									? InkWell(
										child: Icon(Icons.description,size:68,color:Colors.blue[800]),
										onTap:(){Navigator.push( context, MaterialPageRoute(builder: (context) => FulPdf(record.message)));},
									)
									: Container(),
					(record.type == 'music'||record.type == 'audio')?Container():SizedBox(height: 8.0),
					Row(
						children:<Widget>[ 
							Expanded(child: Container()),
							Text(
								"${record.date}",
								style: TextStyle(
								color: Colors.grey,
								fontSize: 10.0,
								fontWeight: FontWeight.w600,
								),
							),
							SizedBox(width: 4,),
						]
					),
				],
			),
		);
	}
	Widget _fileLeft(BuildContext context,record){
		return Container(
			margin: EdgeInsets.only(
					top: 8.0,
					bottom: 8.0,
					right: 83.0,
					),
			padding: EdgeInsets.fromLTRB(10, 8, 10, 3),
			width: MediaQuery.of(context).size.width * 0.75,
			height: record.type == 'image' 
			? null
			: (record.type != 'music' && record.type != 'audio') 
				? 140
				:80,
			decoration: BoxDecoration(
				color: Colors.yellow[100],
				borderRadius:  BorderRadius.all(Radius.circular(10.0)),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.center,
				mainAxisAlignment: MainAxisAlignment.center,
				children: <Widget>[
					(record.type != 'music' && record.type != 'audio') ? new Text(
						record.message.split('?')[0].split('%2F').last,
					) : Container(),
					record.type == 'image'
						? InkWell(
							child: cachImg(record.message,4.0),
							onTap:(){Navigator.push( context, MaterialPageRoute(builder: (context) => FulImage(record.message)));},
						)
						: record.type == 'video'
							? InkWell(
								child: Icon(Icons.videocam,size:68,color:Colors.blue[800]),
								onTap:(){Navigator.push( context, MaterialPageRoute(builder: (context) => FulVideo(record.message)));}
							)
							: (record.type == 'music'||record.type == 'audio')
								?  audioContent(record)
								: record.type == 'doc'
									? InkWell(
										child: Icon(Icons.description,size:68,color:Colors.blue[800]),
										onTap:(){Navigator.push( context, MaterialPageRoute(builder: (context) => FulPdf(record.message)));},
									)
									: Container(),
					(record.type == 'music'||record.type == 'audio')?Container():SizedBox(height: 8.0),
					Row(
						children:<Widget>[ 
							Expanded(child: Container()),
							Text(
								"${record.name}",
								style: TextStyle(
								color: Colors.blue[400],
								fontSize: 10.0,
								fontWeight: FontWeight.bold,
								),
							),
							Text(
								" on ${record.date}",
								style: TextStyle(
								color: Colors.grey,
								fontSize: 10.0,
								fontWeight: FontWeight.w600,
								),
							),
						]
					),
				],
			),
		);
	}

	audioContent(record){
		bool isMe = urlPlaying == record.message;
		bool dowload = isMe && move;
		bool isPaused = audioPlayer == null ? true :audioPlayer.isPaused;
		return Container(
			child: Row(
				children: <Widget>[
					Container(
						child: record.type == 'audio' 
							? Icon(Icons.mic,color:Colors.white,size: 30,)
							: Icon(Icons.music_note,color:Colors.white,size: 30),
						height: 40,
						width: 40,
						decoration: BoxDecoration(
							color:Colors.blue[800],
							borderRadius:  BorderRadius.all(Radius.circular(10.0)),
						),
					),
					isMe
						? isPaused 
							? iconResume()
							: iconPause()
						: iconPlay(record,dowload),
					SizedBox(width: 20,height: 0.0,),
					Text(
						isMe ? timerAudio : "00:00",
						style:TextStyle(
							fontWeight: FontWeight.bold,
							fontSize:20,
							fontFamily: 'times new roman'
						)
					),
				],
			),
		);
	}
	Widget iconPause(){
		return IconButton(
			icon: Icon(Icons.pause,size:38,color:Colors.blue[800]),
			onPressed: () async {
					String result = await audioPlayer.pausePlayer();
					print("RES : $result");
			},
		);
	}
	Widget iconResume(){
		return IconButton(
			icon: Icon(Icons.play_arrow,size:38,color:Colors.blue[800]),
			onPressed: () async {
					String result = await audioPlayer.resumePlayer();
					print("RES : $result");
			},
		);
	}
	Widget iconPlay(record,dowload){
		return IconButton(
			icon: dowload
				? Icon(Icons.file_download,size:38,color:Colors.blue[800])
				: Icon(Icons.play_arrow,size:38,color:Colors.blue[800]),
			onPressed: () async {
				try{
					//Test CNX
					Response res = await get("https://www.google.co.ma/webhp?hl=fr&sa=X&ved=0ahUKEwjao9qjgZjpAhUeBWMBHfqHCeYQPAgH"); 
					setState((){move = true; urlPlaying = record.message;});
					String result = await audioPlayer.startPlayer
					(
						record.message,
						whenFinished: ()
						{
							setState((){ urlPlaying =null;});
						},
					);
					setState((){move = false;});
					playerSub = audioPlayer.onPlayerStateChanged.listen((e) {
						if (e != null) {
							DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
							String txt = DateFormat('mm:ss:SS', 'en_US').format(date);
							String time = txt.substring(0, 5);
							setState((){ timerAudio = time; }); 
						}
					});
				}on PlatformException catch(e){
					showToast("There is no connection.",false);
				}on SocketException catch(e){
					showToast("There is no connection.",false);
				}catch(e){
					showToast("Unknown error, try agine.",false);
				}
			},
		);
	}

	Widget _smsRight(BuildContext context,record) {
		return Container(
			margin: EdgeInsets.only(
					top: 8.0,
					bottom: 8.0,
					left: 80.0,
					),
			padding: EdgeInsets.fromLTRB(10, 8, 10, 3),
			width: MediaQuery.of(context).size.width * 0.75,
			decoration: BoxDecoration(
				color: Colors.lightBlue[100] ,
				borderRadius:  BorderRadius.all(Radius.circular(10.0)),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					Text(
						record.message,
						style: TextStyle(
							fontSize: 15.0,
						),
					),
					SizedBox(height: 8.0),
					Row(
						children:<Widget>[
							Expanded(child: Container()),
							Text(
								"${record.date}",
								style: TextStyle(
								color: Colors.grey,
								fontSize: 10.0,
								fontWeight: FontWeight.w600,
								),
							),
							SizedBox(width: 4,),
						]
					),
				],
			),
		);
	}
	Widget _smsLeft(BuildContext context, record) { 
		return Container(
			margin: EdgeInsets.only(
					top: 8.0,
					bottom: 8.0,
					right: 82.0,
					),
			padding: EdgeInsets.fromLTRB(10, 8, 10, 3),
			width: MediaQuery.of(context).size.width * 0.75,
			decoration: BoxDecoration(
				color: Colors.yellow[100],
				borderRadius:  BorderRadius.all(Radius.circular(10.0)),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					Text(
						record.message,
						style: TextStyle(
							fontSize: 15.0,
						),
					),
					SizedBox(height: 8.0),
					Row(
						children:<Widget>[
							Expanded(child: Container()),
							Text(
								"${record.name}",
								style: TextStyle(
								color: Colors.blue[400],
								fontSize: 10.0,
								fontWeight: FontWeight.bold,
								),
							),
							Text(
								" on ${record.date}",
								style: TextStyle(
								color: Colors.grey,
								fontSize: 10.0,
								fontWeight: FontWeight.w600,
								),
							),
						]
					),
				],
			),
		);
	}

	Widget uploadinMsessage(){
		return Container(
			margin: EdgeInsets.only(
					top: 8.0,
					bottom: 8.0,
					left: 80.0,
					),
			padding: EdgeInsets.fromLTRB(10, 8, 10, 3),
			width: MediaQuery.of(context).size.width * 0.75,
			decoration: BoxDecoration(
				color: Colors.lightBlue[100] ,
				borderRadius:  BorderRadius.all(Radius.circular(10.0)),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					new  Center(
						child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800])),
					),
					SizedBox(height: 8.0),
					new Center(
						child: Text(
							"Uploading File",
							style: TextStyle(
								color: Colors.blue[800],
								fontSize: 20.0,
								fontWeight: FontWeight.bold
							),
						),
					),
				],
			),
		);
	}

	Widget _messageInput() {
		return Container(  
			padding: EdgeInsets.symmetric(horizontal: 8.0),
			height: 50.0,
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.all(Radius.circular(20.0)),
			),
			child: Row(
				children: <Widget>[
					IconButton( //btn ADD FILES*****************************
						icon:  Icon(Icons.attach_file) ,
						iconSize: 27.0,
						color: Colors.deepPurple,
						onPressed: () {dialog(context);},
					),
					Expanded(
						flex: 1,
						child: TextField( //input MSG*****************************
							controller: _messageCtr,
							textCapitalization: TextCapitalization.sentences,
							readOnly: isRecorde || isStopRec ? true : false,
							onChanged: (val){ 
								if(val == null || val == ''){
									setState(() { isWriting = false; });
								}else{
									setState(() { isWriting = true; }); 
								}
							},
							decoration: InputDecoration.collapsed(
								hintText: 'Send a message ...',
							),
						),
					),
					isRecorde 
						? timeRec()
						: isStopRec
							? deleteRec()
							: IconButton( //btn ADD PHOTO*****************************
								icon:  Icon(Icons.camera_alt) ,
								iconSize: 25.0,
								color: Colors.deepPurple,
								onPressed: () async{
									var image = await ImagePicker.pickImage(source: ImageSource.camera);
									if(image != null){
										pathImg = image.path; 
										uploadFiles("image");
									}
								},
							),
					_btnSend(),
				],
			),
		);
	}
	Widget _btnSend(){
		return Container(
			padding: isWriting ? EdgeInsets.fromLTRB(2, 0, 0,0) : null ,
			//margin: EdgeInsets.only(top:5,bottom:5),
			height: 42.0,
			width: 42,
			decoration: BoxDecoration(
				color: Colors.deepPurple,
				borderRadius: BorderRadius.all(Radius.circular(100.0)),
			),
			child: Center(
				child: isWriting
					? sendMessage()
					: isRecorde
						? stopRec()
						: isStopRec
							? sendRec()
							: startRec()
			),
		);
	}
	Widget startRec(){
		return IconButton( 
			icon: Icon(Icons.mic),
			iconSize: 25.0,
			color: Colors.white,
			onPressed: () async {
				setState(() { isRecorde = true; });
				pathRec = await audioRecord.startRecorder();
				recordSub = audioRecord.onRecorderStateChanged.listen((e) {
					if (e != null) {
						DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
						String txt = DateFormat('mm:ss:SS', 'en_US').format(date);
						String time = txt.substring(0, 5);
						setState((){ timerRec = time; }); 
					}
				});
				print('startRecorder: $pathRec');
			}
		);
	}
	Widget stopRec(){
		return IconButton( 
			icon: Icon(Icons.stop),
			iconSize: 25.0,
			color: Colors.white,
			onPressed: () async {
				String mes = await  audioRecord.stopRecorder();
				print('stop Recorder: $mes');
				//audioRecord.release();
				setState(() { isRecorde = false; isStopRec = true;});				
			},
		);
	}
	Widget deleteRec(){
		return IconButton( 
			icon: Icon(Icons.delete_forever),
			iconSize: 30.0,
			color: Colors.deepPurple,
			onPressed: () async {
				setState(() { isRecorde = false; isStopRec = false;});
			},
		);
	}
	Widget sendRec(){
		return IconButton( 
			icon: Icon(Icons.send),
			iconSize: 25.0,
			color: Colors.white,
			onPressed: () async {
				bool ext = await File(pathRec).exists();
				print("FILE EXIST = $ext");
				uploadFiles("audio");
				setState(() { isRecorde = false; isStopRec = false;});	
			},
		);
	}
	Widget sendMessage(){
		return IconButton( 
			icon: Icon(Icons.send),
			iconSize: 25.0,
			color: Colors.white,
			onPressed: () async {
				//+++++++++++++++SEND MESSAGE+++++++++++++++++
				addSms(_messageCtr.text,'text');
				setState(() { isWriting = false; });
				listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
				_messageCtr.clear();
				//remove focuse in Text Field
				FocusScopeNode currentFocus = FocusScope.of(context);
				if (!currentFocus.hasPrimaryFocus) {
					currentFocus.unfocus();
				}
			},
		);
	}
	Widget timeRec(){
		return Row(
			children: <Widget>[
				Text(
					timerRec,
					style: TextStyle(
						fontFamily: 'times new roman',
						fontWeight: FontWeight.bold,
					),
				),
				SizedBox(
					width: 5,
				),
			],
		);
	}

	Future<dynamic> getFile() async {
		try {
			_paths = null;
			_paths = await FilePicker.getMultiFilePath(
				type: _pickType, 
				allowedExtensions: _pickType != FileType.custom ? null : _doc,
			);
		}on PlatformException catch (e) {
			print("Problem>" + e.toString());
		}
		if (!mounted) return;
	}

	uploadFiles([type = "file"]) async {
		if(type == "file"){
			_paths.forEach((fileName, filePath) async {
				String fileN = fileName.split('/').last;
				String location = getLocation(fileN);
				await uploadOne(fileN, filePath,location);
			});
		}else if(type == "audio"){
			var date = DateTime.now().toUtc();
			setState(() { upoadingFile = true; });
			String fileN = pathRec.split('/').last;
			await uploadOne(fileN, pathRec,"Audios/$date",type); 
		}else{
			var date = DateTime.now().toUtc();
			setState(() { upoadingFile = true; });
			String fileN = pathImg.split('/').last;
			await uploadOne(fileN, pathImg,"Images/$date",type); 
		}
	}
 
	uploadOne(fileName, filePath,location,[type = "file"])async{
		String ext = fileName.toString().split('.').last;
		StorageReference storageRef = FirebaseStorage.instance.ref().child(location);
		final StorageUploadTask uploadTask = storageRef.putFile(
			File(filePath),
			StorageMetadata(
				contentType: type =="audio" ? 'audio/$ext':type =="file"?'$_pickType/$ext':'imagePicker/$ext',
			),
		);
		String url;
		await uploadTask.onComplete; 
		await storageRef.getDownloadURL().then((fileURL) { url = fileURL; });
		addSms(url,type!="file"? type : messageType);
		setState(() { upoadingFile = false; });
	}

	String getLocation(fileName){
		if(_pickType == FileType.image){
			messageType = 'image';
			return 'Images/'+fileName;
		}else if(_pickType == FileType.video){
			messageType = 'video';
			return 'Videos/'+fileName;
		}else if(_pickType == FileType.audio){
			messageType = 'music';
			return 'Musics/'+fileName;
		}else{
			messageType = 'doc';
			return 'Documents/'+fileName;
		}
	}
	
	Widget loading() {
		return Positioned(
			child: isLoading
				? Container(
					child: Center(
						child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple)),
					),
					color: Colors.white.withOpacity(0.8),
				  )
				: Container(),
		);
  	}

	dialog(context) {
		Alert(
			context: context,
			title: "",
			style :  AlertStyle(
				animationType: AnimationType.fromBottom,
				isCloseButton: false,
				isOverlayTapDismiss: true,
				animationDuration: Duration(milliseconds: 400),
				alertBorder: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(20.0),
					side: BorderSide(
						color: Colors.deepPurple,
						width:1,
					),
				),
				titleStyle: TextStyle(
					color: Colors.deepPurple,
				),
			),
			content: Container(
				child: Row(
					children: <Widget>[
						new Expanded(
							flex:1,
							child: new RaisedButton(
								color: Colors.orange,
								child: Icon(Icons.image,color: Colors.white,),
								onPressed: ()async{
									_pickType = FileType.image;
									await getFile();
									if(_paths != null){
										setState(() { upoadingFile = true; });
										uploadFiles();
									}
									Navigator.of(context, rootNavigator: true).pop();
								}
							),
						),
						new Padding(
							padding: const EdgeInsets.all(2),
						),
						new Expanded(
							flex:1,
							child: new RaisedButton(
								color: Colors.blue,
								child: Icon(Icons.videocam,color: Colors.white,),
								onPressed: ()async{
									_pickType = FileType.video;
									await getFile();
									if(_paths != null){
										setState(() { upoadingFile = true; });
										uploadFiles();
									}
									Navigator.of(context, rootNavigator: true).pop();
								}
							),
						),
						new Padding(
							padding: const EdgeInsets.all(2),
						),
						new Expanded(
							flex:1,
							child: new RaisedButton(
								color: Colors.green,
								child: Icon(Icons.library_music,color: Colors.white,),
								onPressed: ()async{
									_pickType = FileType.audio;
									await getFile();
									if(_paths != null){
										setState(() { upoadingFile = true; });
										uploadFiles();
									}
									Navigator.of(context, rootNavigator: true).pop();
								}
							),
						),
						new Padding(
							padding: const EdgeInsets.all(2),
						),
						new Expanded(
							flex:1,
							child: new RaisedButton(
								color: Colors.brown,
								child: Icon(Icons.description,color: Colors.white,),
								onPressed: ()async{
									_pickType = FileType.custom;
									await getFile();
									if(_paths != null){
										setState(() { upoadingFile = true; });
										uploadFiles();
									}
									Navigator.of(context, rootNavigator: true).pop();
								}
							),
						),
					],
				),
			),
			buttons: [
				DialogButton(
					child: Text(
						"CANCEL",
						style: TextStyle(color: Colors.black45, fontSize: 20),
					),
					onPressed: (){
						Navigator.of(context, rootNavigator: true).pop();
					},
					color: Colors.white,
				),
			],
		).show();
	}

	showToast(msg,top){
		Fluttertoast.showToast(
			msg: msg,
			toastLength: Toast.LENGTH_SHORT,
			gravity: top? ToastGravity.TOP : ToastGravity.BOTTOM,
		);
	}
}
class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}