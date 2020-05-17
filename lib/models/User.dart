

class User {
	String name;
	String pname;
	String email;
	String pass;
	String uid;
	String branch;
	String role;
	String urlImg;


	User({this.uid,this.email,this.pass,this.name,this.pname,this.branch,this.role, this.urlImg});
	setUrl(String urlImg){
		this.urlImg = urlImg;
  	}

	setPass(String pass){
		this.pass = pass;
  	}


  
}