import 'package:flutter/material.dart';

class NewContentScreen extends StatelessWidget {
  const NewContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Konten Terbaru')),
      body: Center(
        child: Text(
          'Konten terbaru akan muncul di sini.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
