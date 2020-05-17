import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';


String url;

class FulImage extends StatefulWidget {

	FulImage(String urL){
		url = urL;
	}

	@override
	FulImageState createState() => FulImageState();
}

class FulImageState extends State<FulImage> {

	@override
	Widget build(BuildContext context) {
		return new Scaffold(
			appBar: AppBar(
				backgroundColor: Colors.black,
				centerTitle: true,
				title : Text(
					"${url.split('?')[0].split('%2F').last}",
					style: TextStyle(
						color: Colors.black,
					),
				),
			),
			body: WillPopScope(
				child: PhotoView(
					imageProvider: NetworkImage(url),
					loadFailedChild: Center(
						child: Column(
							mainAxisAlignment: MainAxisAlignment.center,
							children: <Widget>[
								Icon(Icons.perm_scan_wifi,size: 43,color: Colors.red,),
								Text(
									"There is no connexion",
									style: TextStyle(
										color: Colors.red,
										fontWeight: FontWeight.bold,
										fontSize: 26,
									),
								)
							],
						),
					),
					enableRotation:true,
				), 
				onWillPop: null,
			),
		);
	}
}