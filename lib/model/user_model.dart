class Usermodel {
  String name;
  final String email;
  String createdat;
  String phonenumber;
  String uid;

  Usermodel({
    required this.name,
    required this.email,
    required this.createdat,
    required this.phonenumber,
    required this.uid,
  });
  factory Usermodel.fromMap(Map<String, dynamic> map) {
    return Usermodel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      createdat: map['createdat'] ?? '',
      phonenumber: map['phonenumber'] ?? '',
      uid: map['uid'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "createdat": createdat,
      "phonenumber": phonenumber,
      "uid": uid,
    };
  }
}
