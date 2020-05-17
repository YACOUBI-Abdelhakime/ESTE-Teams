import 'package:flutter/material.dart';
import 'package:cached_video_player/cached_video_player.dart';


String url;

class FulVideo extends StatefulWidget {

	FulVideo(String urL){
		url = urL;
	}

	@override
	FulVideoState createState() => FulVideoState();
}

class FulVideoState extends State<FulVideo> {
	CachedVideoPlayerController controller;
	bool isPlaying = true;

  	@override
  	void initState() {
    	controller = CachedVideoPlayerController.network(url);
		controller.initialize().then((_) {
			setState(() {});
			controller.setLooping(false);
			controller.setVolume(1.0);
			controller.play();
		});    	
    	super.initState();
  	}
 
  	@override
  	void dispose() {
    	controller.dispose();
    	super.dispose();
  	}
 
  	@override
  	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: Colors.black,
				centerTitle: true,
				title : Text(
					"${url.split('?')[0].split('%2F').last}",
				),
			),
			body: Container(
				color: Colors.black,
				child: Column(
					children: <Widget>[
						Expanded(
							child: new InkWell(
								child: Center(
									child: controller.value != null && controller.value.initialized
										? AspectRatio(
											child: CachedVideoPlayer(controller),
											aspectRatio: controller.value.aspectRatio,
											)
										: Center(
											child: CircularProgressIndicator(
												strokeWidth: 4,
												valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
											),
											)),
								onTap:(){
									setState(() {
										if (controller.value.isPlaying) {
											isPlaying = false;
											controller.pause();
										} else {
											isPlaying = true;
											controller.play();
										}
									});
								}
							), 
						),
						SizedBox(height: 5,),
						Row(
							mainAxisAlignment: MainAxisAlignment.center,
							children: <Widget>[
								Container(
									height: 30,
									width: 55,
									child:RaisedButton(
										child: Icon(Icons.replay_5),
										onPressed: () async {
											var pos = await controller.position;
											int secPos = pos.inSeconds;
											controller.seekTo(Duration(seconds: secPos-5));
										}
									),
								),
								SizedBox(width: 5,),
								Container(
									height: 30,
									width: 55,
									//color: Colors.white,
									child:RaisedButton(
										//color: Colors.transparent,
										child: Icon(Icons.settings_backup_restore),
										onPressed: (){controller.seekTo(Duration(milliseconds: 0));}
									),
								),
								SizedBox(width: 5,), 
								Container(
									height: 30,
									width: 55,
									//color: Colors.white,
									child: RaisedButton(
										child: isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
										onPressed: (){
											setState(() {
												if (controller.value.isPlaying) {
													isPlaying = false;
													controller.pause();
												} else {
													isPlaying = true;
													controller.play();
												}
											});
										}
									),
								),
								SizedBox(width: 5,),
								Container(
									height: 30,
									width: 55,
									//color: Colors.white,
									child:RaisedButton(
										//color: Colors.transparent,
										child: Icon(Icons.forward_5),
										onPressed: () async {
											var pos = await controller.position;
											int secPos = pos.inSeconds;
											controller.seekTo(Duration(seconds: secPos+5));
										}
									),
								),
							],
						),
						SizedBox(height: 5,),
					],
				),
			),
		);
  	}
}