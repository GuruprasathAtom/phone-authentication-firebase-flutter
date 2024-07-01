import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ke/screens/signin_screen.dart';
import 'package:flutter_ke/screens/userinformation_screen.dart';
import 'package:flutter_ke/utils/colour_utils.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _imageUrls = [
    'https://firebasestorage.googleapis.com/v0/b/sigin-cf7cb.appspot.com/o/guru%2FEPK%202%2020190601_213851.jpg?alt=media&token=46b28f97-c86f-40f6-b644-951e4a1d7146',
    'https://firebasestorage.googleapis.com/v0/b/sigin-cf7cb.appspot.com/o/guru%2FIMG_20180105_160233224.jpg?alt=media&token=0c853187-3287-49a1-a849-525a365ca659',
    'https://firebasestorage.googleapis.com/v0/b/sigin-cf7cb.appspot.com/o/guru%2FIMG_20180108_205416_469.jpg?alt=media&token=8ee605c1-b8f2-4d22-994b-85f12b428256',
    'https://firebasestorage.googleapis.com/v0/b/sigin-cf7cb.appspot.com/o/guru%2FIMG_20180128_180102_201.jpg?alt=media&token=9360ed09-45f0-4d96-af19-1a37d6bd45c6'
  ];

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      final fileName = file.path.split('guru/').last;

      final Reference storageReference =
          FirebaseStorage.instance.ref().child('images/$fileName');

      final UploadTask uploadTask = storageReference.putFile(file);

      await uploadTask.whenComplete(() async {
        final url = await storageReference.getDownloadURL();
        setState(() {
          _imageUrls.add(url);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          hexStringToColor("eae8e9"),
          hexStringToColor("9f0e8c"),
          hexStringToColor("510b77")
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
          ),
          itemCount: _imageUrls.length, // Number of images
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LargeImageScreen(imageUrl: _imageUrls[index]),
                  ),
                );
              },
              child: Image.network(
                _imageUrls[index],
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _uploadImage();
        },
        child: Icon(Icons.upload),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          height: 56.0,
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut().then((value) {
                  print("Signed out");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SiginScreen()),
                  );
                });
              },
              child: const Text('Logout'),
            ),
          ),
        ),
      ),
    );
  }
}
