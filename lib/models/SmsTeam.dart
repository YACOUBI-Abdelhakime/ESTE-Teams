import 'package:chatapp/views/Sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SmsTeam {
	final String message; 
	final String date;
	final String type;
	final bool readed;
	final String name;
	final bool toMe;

	SmsTeam.fromMap(Map<String, dynamic> map,)
		: assert(map['sms'] != null),
		  assert(map['from'] != null),
		  assert(map['date'] != null),
		  assert(map['type'] != null),
		  assert(map['name'] != null),
		  assert(map['readed'] != null),
		  message = map['sms'],
		  name = map['name'],
		  type = map['type'],
		  readed = map['readed']=='true'? true:false,
		  date ="${DateFormat('d MMM y').format(DateTime.parse(map['date'].toDate().toString()))} at ${DateFormat().add_Hm().format(DateTime.parse(map['date'].toDate().toString()))}",
		  toMe = map['from'] != user.uid?true:false;

	SmsTeam.fromSnapshot(DocumentSnapshot snapshot)
		: this.fromMap(snapshot.data,);
}