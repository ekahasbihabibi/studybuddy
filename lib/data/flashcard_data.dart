class Flashcard {
  final String subject;
  final String question;
  final String answer;

  Flashcard({
    required this.subject,
    required this.question,
    required this.answer,
  });
}

final List<Flashcard> flashcards = [
  Flashcard(
    subject: "Matematika",
    question: "Rumus luas lingkaran?",
    answer: "π × r²",
  ),
  Flashcard(
    subject: "Bahasa Inggris",
    question: "What is the past tense of 'go'?",
    answer: "Went",
  ),
  Flashcard(
    subject: "Fisika",
    question: "Hukum Newton 1?",
    answer: "Benda akan tetap diam atau bergerak lurus beraturan jika tidak ada gaya yang bekerja.",
  ),
  Flashcard(
    subject: "Matematika",
    question: "Apa itu bilangan prima?",
    answer: "Bilangan yang hanya habis dibagi 1 dan dirinya sendiri.",
  ),
];
