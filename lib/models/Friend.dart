import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Friend {
	final String lastMessage;
	final String newMessage;
	final String uid;

	Friend.fromMap(Map<String, dynamic> map,)
		: assert(map['lastMessage'] != null),
		  assert(map['uid'] != null),
		  assert(map['newMessage'] != null),
		  lastMessage = "${DateFormat('d MMM y').format(DateTime.parse(map['lastMessage'].toDate().toString()))} at ${DateFormat().add_Hm().format(DateTime.parse(map['lastMessage'].toDate().toString()))}",
		  uid = map['uid'],
		  newMessage = map['newMessage'];
      
	Friend.fromSnapshot(DocumentSnapshot snapshot)
		: this.fromMap(snapshot.data,);
}