import 'dart:async';

import 'package:chatapp/main.dart';
import 'package:chatapp/views/Sign_in.dart';
import 'package:chatapp/views/Sign_up.dart';
import 'package:chatapp/models/User.dart';
import 'package:chatapp/services/Database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';


class Auth {
	

	Future register({email,pass,name,pname,branch ,role}) async {
		try{
			FirebaseAuth _auth = FirebaseAuth.instance;
			AuthResult res = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
			String uid = res.user.uid;
			await Firestore.instance.collection("User")
				.document(uid).setData({
					'uid':uid,
					'email' : email,
					'pass':pass,
					'name' : name,
					'pname' : pname,
					'role': role,
					'branch':branch,
					'deviceToken' : userDevToken,
					'urlImg' : null,
				});
				user = User(uid: uid, email: email,name: name, pname: pname,branch : branch, role : role);
				return "ok";
		}on PlatformException catch(ex){
			return ex.code;//pas cnx or @ deja use
		}catch(ex){
			print("ER rg 2:");
			print(ex.toString());
			return "other";//other except
		}
	}

	Future signIn(emailX,passX) async {
		FirebaseAuth _auth = FirebaseAuth.instance;
		try{
			var res = await _auth.signInWithEmailAndPassword(email: emailX, password: passX);
			String uid = res.user.uid;
      		await Firestore.instance.collection("User").document(uid).updateData({
				'deviceToken' : userDevToken,
			});
			DocumentSnapshot data = await Firestore.instance .collection('User').document(uid).get() ;
			String email = data['email'];
			String pass = data['pass'];
			String role = data['role']; 
			String branch = data['branch']; 
			String name = data['name']; 
			String pname = data['pname']; 
			String urlImg = data['urlImg'];
			//print("1>>uid = $uid, email = $email, role = $role, branch = $branch, name = $name, pname = $pname, urlImg = $urlImg");
			user = User(uid:uid, email: email,pass:pass, name: name, pname: pname, branch: branch, role: role, urlImg: urlImg);
			//print("2>>email : ${user.email}, role : ${user.role}, branch : ${user.branch}, urlImg : ${user.urlImg}");
			//print(">>return OK");
			return "ok";
		}on PlatformException catch(ex){
			return ex.code;//pas cnx
		}catch(ex){
			print("ER <SignIn> "+ex.toString());
			return "other";
		}
	}

	Future<void> signOut() async {

		await Firestore.instance.collection("User").document(user.uid).updateData({
			'deviceToken' : null,
		});
		FirebaseAuth _auth = FirebaseAuth.instance;
		_auth.signOut();
		user = null;
	}
}