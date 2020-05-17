import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Team {
		String lastMessage;
		bool newMessage;
		String uid;
		String url;
		String name;
    List<String> members;
    List<String> notRead;

	Team.fromMap(Map<String, dynamic> map,uidX,newM)
		: assert(map['lastMessage'] != null),
		  assert(map['name'] != null),
		  lastMessage = "${DateFormat('d MMM y').format(DateTime.parse(map['lastMessage'].toDate().toString()))} at ${DateFormat().add_Hm().format(DateTime.parse(map['lastMessage'].toDate().toString()))}",
		  url = map['url'],
		  uid = uidX,
		  name = map['name'],
		  newMessage = newM,
      members = List.from(map['members']),
      notRead = List.from(map['notRead']);
      
	Team.fromSnapshot(DocumentSnapshot snapshot,uid,newM)
		: this.fromMap(snapshot.data,uid,newM);
}