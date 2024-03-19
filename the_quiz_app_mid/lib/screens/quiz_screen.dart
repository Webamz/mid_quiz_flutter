// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_quiz_app_mid/screens/home_page.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;
  final List<Map<String, dynamic>> questions;

  const QuizScreen({
    Key? key,
    required this.quizId,
    required this.questions,
  }) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  List<int?> _selectedOptions =
      List.filled(4, null); // Change the size according to your needs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}/${widget.questions.length}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              widget.questions[_currentQuestionIndex]['question'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Column(
              children: _buildOptions(
                  widget.questions[_currentQuestionIndex]['options']),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed:
                      _currentQuestionIndex > 0 ? _previousQuestion : null,
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _nextQuestion();
                  },
                  child: Text(
                    _currentQuestionIndex < widget.questions.length - 1
                        ? 'Next'
                        : 'Submit',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptions(List<dynamic> options) {
    return options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      return Row(
        children: [
          Radio<int?>(
            value: index,
            groupValue: _selectedOptions[_currentQuestionIndex],
            onChanged: (value) {
              setState(() {
                _selectedOptions[_currentQuestionIndex] = value;
              });
            },
          ),
          Text(option),
        ],
      );
    }).toList();
  }

  void _previousQuestion() {
    setState(() {
      if (_currentQuestionIndex > 0) {
        _currentQuestionIndex--;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < widget.questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _calculateScore();
        _showResultDialog();
      }
    });
  }

  void _calculateScore() {
    for (int i = 0; i < widget.questions.length; i++) {
      if (_selectedOptions[i] != null &&
          _selectedOptions[i] == widget.questions[i]['correctAnswerIndex']) {
        _score++;
      }
    }
  }

  void _showResultDialog() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Get quiz title using quizId
        final DocumentSnapshot quizSnapshot = await FirebaseFirestore.instance
            .collection('quizzes')
            .doc(widget.quizId)
            .get();

        final String quizTitle = quizSnapshot.get('title');

        // Format the timestamp
        final String formattedTimestamp =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

        // Construct a map to store the quiz result
        final Map<String, dynamic> quizResult = {
          'userId': user.email,
          'quizId': widget.quizId,
          'quizTitle': quizTitle,
          'score': _score,
          'totalQuestions': widget.questions.length,
          'timestamp': formattedTimestamp,
        };

        // Store the user's score and quiz title locally
        // final String userId = user.email.toString(); // Get the user ID
        // await prefs.setString('$userId-quiz_title', quizTitle);
        // await prefs.setInt('$userId-user_score', _score);

        // await prefs.setString('$userId-timestamp', formattedTimestamp);

        // Get the existing quiz scores list from SharedPreferences
      final String userId = user.email!; // Get the user ID
      final String? existingScoresString = prefs.getString('$userId-quiz_scores');
      List<Map<String, dynamic>> existingScores = [];
      if (existingScoresString != null && existingScoresString.isNotEmpty) {
        existingScores = List<Map<String, dynamic>>.from(
            json.decode(existingScoresString));
      }

      // Add the current quiz result to the existing quiz scores list
      existingScores.add(quizResult);

      // Save the updated quiz scores list to SharedPreferences
      await prefs.setString(
          '$userId-quiz_scores', json.encode(existingScores));

        // Add the quiz result to Firestore
        await FirebaseFirestore.instance
            .collection('quiz_results')
            .add(quizResult);

        // Show the result dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Quiz Completed'),
              content: Text('Your score: $_score/${widget.questions.length}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    _resetQuiz();
                  },
                  child: const Text('Redo Quiz'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  },
                  child: const Text('Home Page'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        print('Error storing quiz result in Firestore: $e');
        // Handle error
      }
    }
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedOptions = List.filled(
          4, null); // Reset selected options, change the size as needed
    });
  }
}
