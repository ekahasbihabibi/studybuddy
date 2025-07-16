import 'package:flutter/material.dart';
import 'flashcard_screen.dart';

class FlashcardSubjectScreen extends StatelessWidget {
  final List<String> subjects = ["Matematika", "Bahasa Inggris", "Fisika"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pilih Pelajaran"),
      actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(context, '/add-flashcard');
          },
        ),
      ],
      ),
      body: ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(subjects[index]),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FlashcardScreen(subject: subjects[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
