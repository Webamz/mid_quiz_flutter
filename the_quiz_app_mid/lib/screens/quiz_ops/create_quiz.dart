// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_quiz_app_mid/models/quiz_model.dart';

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({super.key});

  @override
  _CreateQuizPageState createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _optionController1 = TextEditingController();
  final TextEditingController _optionController2 = TextEditingController();
  final TextEditingController _optionController3 = TextEditingController();
  final TextEditingController _optionController4 = TextEditingController();

  List<Question> _questions = [];
  bool _isOption1Correct = false;
  bool _isOption2Correct = false;
  bool _isOption3Correct = false;
  bool _isOption4Correct = false;

  void _addQuestion() {
    List<Option> options = [
      Option(text: _optionController1.text, isCorrect: _isOption1Correct),
      Option(text: _optionController2.text, isCorrect: _isOption2Correct),
      Option(text: _optionController3.text, isCorrect: _isOption3Correct),
      Option(text: _optionController4.text, isCorrect: _isOption4Correct),
    ];
    Question question = Question(
      question: _questionController.text,
      options: options,
      correctAnswerIndex: options.indexWhere((option) => option.isCorrect),
    );

    setState(() {
      _questions.add(question);
    });

    // Clear question and option fields
    _questionController.clear();
    _optionController1.clear();
    _optionController2.clear();
    _optionController3.clear();
    _optionController4.clear();
    _isOption1Correct = false;
    _isOption2Correct = false;
    _isOption3Correct = false;
    _isOption4Correct = false;
  }

  Future<void> _submitQuiz() async {
    Quiz quiz = Quiz(
      title: _titleController.text,
      category: _categoryController.text,
      questions: _questions,
      id: '',
    );

    // Submit quiz to Firestore
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('quizzes')
        .add(quiz.toJson());
    quiz.id = docRef.id; // Assign document ID as the quiz ID

    // Clear form fields
    _titleController.clear();
    _categoryController.clear();
    _questions = [];

    // Show success message or navigate to a different screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quiz submitted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quiz'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              TextField(
                controller: _optionController1,
                decoration: const InputDecoration(labelText: 'Option 1'),
              ),
              CheckboxListTile(
                title: const Text('Correct Answer'),
                value: _isOption1Correct,
                onChanged: (value) {
                  setState(() {
                    _isOption1Correct = value!;
                  });
                },
              ),
              TextField(
                controller: _optionController2,
                decoration: const InputDecoration(labelText: 'Option 2'),
              ),
              CheckboxListTile(
                title: const Text('Correct Answer'),
                value: _isOption2Correct,
                onChanged: (value) {
                  setState(() {
                    _isOption2Correct = value!;
                  });
                },
              ),
              TextField(
                controller: _optionController3,
                decoration: const InputDecoration(labelText: 'Option 3'),
              ),
              CheckboxListTile(
                title: const Text('Correct Answer'),
                value: _isOption3Correct,
                onChanged: (value) {
                  setState(() {
                    _isOption3Correct = value!;
                  });
                },
              ),
              TextField(
                controller: _optionController4,
                decoration: const InputDecoration(labelText: 'Option 4'),
              ),
              CheckboxListTile(
                title: const Text('Correct Answer'),
                value: _isOption4Correct,
                onChanged: (value) {
                  setState(() {
                    _isOption4Correct = value!;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addQuestion,
                child: const Text('Add Question'),
              ),
              ElevatedButton(
                onPressed: _submitQuiz,
                child: const Text('Submit Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
