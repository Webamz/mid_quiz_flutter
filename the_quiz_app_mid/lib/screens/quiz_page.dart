// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_quiz_app_mid/screens/quiz_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizPage extends StatelessWidget {
  final String quizId;
  final String title;
  final String category;

  const QuizPage({
    Key? key,
    required this.quizId,
    required this.title,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz - $title'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Title: $title',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Category: $category',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _startQuiz(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Start Quiz',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startQuiz(BuildContext context) async {
    final List<Map<String, dynamic>> questions = await _fetchQuestions();

    // Store the user information
    await _storeUser();

    // Navigate to the quiz screen passing the questions
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizScreen(quizId: quizId,questions: questions),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchQuestions() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizId)
          .get();

      final List<Map<String, dynamic>> questions =
          (querySnapshot.data()?['questions'] as List<dynamic>)
              .cast<Map<String, dynamic>>()
              .toList();

      return questions;
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  Future<void> _storeUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await prefs.setString('user_id', user.uid);
        await prefs.setString('user_email', user.email.toString());
        // You can store additional user information as needed
      }
    } catch (e) {
      print('Error storing user information: $e');
    }
  }
}
