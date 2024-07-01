import 'package:flutter/material.dart';

class LargeImageScreen extends StatelessWidget {
  final String imageUrl;

  const LargeImageScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Large Image'),
      ),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}
