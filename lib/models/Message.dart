import 'package:chatapp/Wrapp.dart';
import 'package:chatapp/views/Chat.dart';
import 'package:chatapp/views/Sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Message {
	final String message;
	final String date;
	final String type;
	final bool readed;
	final bool toMe;

	Message.fromMap(Map<String, dynamic> map,)
		: assert(map['message'] != null),
		  assert(map['to'] != null),
		  assert(map['date'] != null),
		  assert(map['type'] != null),
		  assert(map['readed'] != null),
		  message = map['message'],
		  type = map['type'],
		  readed = map['readed']=='true'? true:false,
		  date ="${DateFormat('d MMM y').format(DateTime.parse(map['date'].toDate().toString()))} at ${DateFormat().add_Hm().format(DateTime.parse(map['date'].toDate().toString()))}",
		  toMe = map['to'] == 'me'?true:false;

	Message.fromSnapshot(DocumentSnapshot snapshot)
		: this.fromMap(snapshot.data,);

    static void addSms(message,type) async {
		var date = DateTime.now().toUtc();
	//add sms to my collection----------------------------------------------------------------------------------
		await Firestore.instance.collection("Chats").document(user.uid)
			.collection("Friends").document(uidFriend).collection('Messages').add({
				'date' : date,
				'message' : message,
				'type':	type,
				'readed':'false',
				'to' : 'hem',
			});
		// update lastMessage
		await Firestore.instance.collection("Chats").document(user.uid)
			.collection("Friends").document(uidFriend).updateData({
				'lastMessage' : date,
				'newMessage' : 'false',
			});
	//add friend collection-----------------------------------------------------------------------------
		await Firestore.instance.collection("Chats").document(uidFriend)
		.collection("Friends").document(user.uid).setData(
			{
			'uid' : user.uid,
			'name' : "${user.pname} ${user.name} ${user.branch}",
			'lastMessage' : date,
			'newMessage' : 'true',
			},
			merge: true,
		);
	//add sms to a friend collection-----------------------------------------------------------------------------
		await Firestore.instance.collection("Chats").document(uidFriend)
			.collection("Friends").document(user.uid).collection('Messages').add({
				'date' : date,
				'message' : message,
				'type':	type,
				'readed': 'false',
				'to' : 'me',
			});
			var br = user.role != 'prof' ? user.branch: 'Prof';
			sendFirebaseNotif('New chat message','${user.pname} ${user.name} "$br"',tokenFriend);
	}
}