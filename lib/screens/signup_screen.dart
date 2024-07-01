import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ke/model/user_model.dart';
import 'package:flutter_ke/project2/homee.dart';
import 'package:flutter_ke/provider/auth_provider.dart';
import 'package:flutter_ke/screens/home_screen.dart';
import 'package:provider/provider.dart';

import '../reuseage text/reusable_text.dart';
import '../utils/colour_utils.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();
  TextEditingController _phonenumberController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    emailController.dispose();
  }

  Country selecetedCountry = Country(
      phoneCode: "91",
      countryCode: "IN",
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: "India",
      example: "India",
      displayName: "India",
      displayNameNoCountryCode: "IN",
      e164Key: "");
  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<Authprovider>(context, listen: true).isLoading;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Signup",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: isLoading == true
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.purple,
              ),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                hexStringToColor("e8f269"),
                hexStringToColor("5099ef"),
                hexStringToColor("17e3cb")
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              child: SingleChildScrollView(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).size.height * 0.2, 20, 0),
                child: Column(
                  children: <Widget>[
                    reusableTextField("Enter Username", Icons.person_outline,
                        false, _userNameTextController),
                    const SizedBox(
                      height: 30,
                    ),
                    reusableTextField("Enter Email ID", Icons.mail_outline,
                        false, _emailTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _phonenumberController,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      onChanged: (value) {
                        setState(() {
                          _phonenumberController.text = value;
                        });
                      },
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                          hintText: "Enter your number",
                          filled: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          fillColor: Colors.white.withOpacity(0.3),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(
                                  width: 0, style: BorderStyle.none)),
                          prefixIcon: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                showCountryPicker(
                                  context: context,
                                  countryListTheme: const CountryListThemeData(
                                      bottomSheetHeight: 500),
                                  onSelect: (value) {
                                    setState(
                                      () {
                                        selecetedCountry = value;
                                      },
                                    );
                                  },
                                );
                              },
                              child: Text(
                                "${selecetedCountry.flagEmoji} + ${selecetedCountry.phoneCode}",
                                style: const TextStyle(
                                  fontSize: 19,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          suffixIcon: _phonenumberController.text.length > 9
                              ? Container(
                                  height: 30,
                                  width: 30,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green),
                                  child: const Icon(
                                    Icons.done,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                )
                              : null),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: _phonenumberController.text.length > 9
                          ? () => sendPhoneNumber()
                          : null,
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.black26;
                          }
                          return Colors.white;
                        }),
                      ),
                      child: const Text(
                        "Verify",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter password", Icons.lock_outline,
                        true, _passwordTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    signInsignUpButton(context, false, () {
                      FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: _emailTextController.text,
                              password: _passwordTextController.text)
                          .then((value) {
                        print("Created New account");
                        storeData();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                      }).onError((error, stackTrace) {
                        print("Error ${error.toString()}");
                      });
                    })
                  ],
                ),
              ))),
    );
  }

  void sendPhoneNumber() {
    final ap = Provider.of<Authprovider>(context, listen: false);
    String phoneNumber = _phonenumberController.text.trim();
    ap.signInWithPhone(context, "+${selecetedCountry.phoneCode}$phoneNumber");
  }

  void storeData() async {
    final ap = Provider.of<Authprovider>(context, listen: false);
    Usermodel usermodel = Usermodel(
      name: _userNameTextController.text.trim(),
      email: _emailTextController.text.trim(),
      createdat: "",
      phonenumber: _phonenumberController.text.trim(),
      uid: "",
    );
    if (_userNameTextController.text.isNotEmpty) {
      ap.saveUserDataToFirebase(
        context: context,
        usermodel: usermodel,
        onSuccess: () {
          ap.saveUserDataToSP().then(
                (value) => ap.setSigIn().then(
                      (value) => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                          (route) => false),
                    ),
              );
        },
      );
    } else {
      print("Please enter the username");
    }
  }
}
