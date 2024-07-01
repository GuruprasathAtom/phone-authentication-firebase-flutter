import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ke/model/user_model.dart';
import 'package:flutter_ke/screens/otp_screen.dart';
import 'package:flutter_ke/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authprovider extends ChangeNotifier {
  bool _isSignIn = false;
  bool get isSignIn => _isSignIn;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _uid;
  String get uid => _uid!;
  Usermodel? _usermodel;
  Usermodel get usermodel => _usermodel!;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage =
      FirebaseStorage.instanceFor(bucket: 'gs://sigin-cf7cb.appspot.com');

  Authprovider() {
    checkSign();
  }

  void checkSign() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignIn = s.getBool("is_Signed") ?? false;
    notifyListeners();
  }

  Future setSigIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("is_sigin", true);
    _isLoading = true;
    notifyListeners();
  }

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (error) {
          throw Exception(error.message);
        },
        codeSent: (verificationId, forceResendingToken) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(verificationId: verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      showSnackerBar(context, e.message.toString());
    }
  }

  void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userotp,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userotp);
      User? user = (await _firebaseAuth.signInWithCredential(creds)).user;

      if (user != null) {
        _uid = user.uid;
        onSuccess();
        showSnackerBar(context, "Verified");
      }
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackerBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkExistingUser() async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection("users").doc(_uid).get();
    if (snapshot.exists) {
      print("User exists");
      return true;
    } else {
      print("New User");
      return false;
    }
  }

  void saveUserDataToFirebase({
    required BuildContext context,
    required Usermodel usermodel,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await storeFileToStorage("Usermodel/$_uid", usermodel).then((value) {
        usermodel.uid = value;
        usermodel.createdat = DateTime.now().millisecondsSinceEpoch.toString();
        usermodel.phonenumber = _firebaseAuth.currentUser!.phoneNumber!;
        usermodel.name = _firebaseAuth.currentUser!.displayName!;
      });
      _usermodel = usermodel;

      await _firebaseFirestore
          .collection("user")
          .doc(_uid)
          .set(usermodel.toMap())
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackerBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> storeFileToStorage(String ref, Usermodel usermodel) async {
    UploadTask uploadTask =
        _firebaseStorage.ref().child(ref).putString(usermodel as String);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future saveUserDataToSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString("user_model", jsonEncode(usermodel.toMap()));
  }
}
