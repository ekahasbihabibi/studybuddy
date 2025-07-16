import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import '../data/flashcard_data.dart';

class FlashcardScreen extends StatelessWidget {
  final String subject;

  const FlashcardScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final subjectCards = flashcards.where((f) => f.subject == subject).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Flashcard - $subject')),
      body: subjectCards.isEmpty
          ? Center(child: Text("Belum ada flashcard untuk $subject"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subjectCards.length,
        itemBuilder: (context, index) {
          final card = subjectCards[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: FlipCard(
              direction: FlipDirection.HORIZONTAL,
              front: _buildCard(card.question, isFront: true),
              back: _buildCard(card.answer, isFront: false),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(String text, {required bool isFront}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isFront ? Colors.indigo : Colors.green,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      height: 150,
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
