import 'package:flutter/material.dart';
import '../data/flashcard_data.dart';

class AddFlashcardScreen extends StatefulWidget {
  @override
  _AddFlashcardScreenState createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  void _saveFlashcard() {
    if (_formKey.currentState!.validate()) {
      flashcards.add(
        Flashcard(
          subject: _subjectController.text.trim(),
          question: _questionController.text.trim(),
          answer: _answerController.text.trim(),
        ),
      );
      Navigator.pop(context); // Kembali ke halaman sebelumnya
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Flashcard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(labelText: 'Pelajaran'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _questionController,
                decoration: InputDecoration(labelText: 'Pertanyaan'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _answerController,
                decoration: InputDecoration(labelText: 'Jawaban'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveFlashcard,
                child: Text('Simpan Flashcard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
