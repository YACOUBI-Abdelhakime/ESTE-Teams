import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';


String url;

class FulPdf extends StatefulWidget {

	FulPdf(String urL){
		url = urL;
	}

	@override
	FulPdfState createState() => FulPdfState();
}

class FulPdfState extends State<FulPdf> {
	PDFDocument doc = PDFDocument();
	bool _isLoading = true;

	@override
  	void initState() {
		  super.initState();
		  getDoc();
	}

	getDoc() async {
		doc = await PDFDocument.fromURL(url);
		setState(() { _isLoading =false; });
	}

  	@override
  	Widget build(BuildContext context) {
		  //getDoc(); 
		  
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
				child: _isLoading
					? Center(child: CircularProgressIndicator())
					: PDFViewer(document: doc, showPicker: false,),
			),
		);
  	}
}