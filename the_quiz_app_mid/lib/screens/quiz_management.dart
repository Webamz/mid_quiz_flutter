// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_quiz_app_mid/models/quiz_model.dart';
import 'package:the_quiz_app_mid/screens/login_page.dart';
import 'package:the_quiz_app_mid/screens/quiz_ops/create_quiz.dart';
import 'package:the_quiz_app_mid/screens/quiz_ops/edit_quiz.dart';
import 'package:the_quiz_app_mid/screens/admin_scores_page.dart'; // Import AdminScoresPage

class QuizManagementPage extends StatefulWidget {
  const QuizManagementPage({Key? key}) : super(key: key);

  @override
  _QuizManagementPageState createState() => _QuizManagementPageState();
}

class _QuizManagementPageState extends State<QuizManagementPage> {
  int _selectedIndex = 0;

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to login screen after sign out
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Implement logout functionality
              _signOut(context);
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildQuizzesList(), // Index 0 - Quiz Management Page
          const AdminScoresPage(), // Index 1 - Admin Scores Page
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Quizzes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.score),
            label: 'Scores',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateQuizPage()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildQuizzesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('quizzes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final List<Quiz> quizzes = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final String title = data['title'] ?? '';
          final String category = data['category'] ?? '';
          final List<Question> questions = []; // Initialize with an empty list
          return Quiz(
            id: doc.id,
            title: title,
            category: category,
            questions: questions,
          );
        }).toList();
        return ListView.builder(
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return ListTile(
              title: Text(quiz.title),
              subtitle: Text(quiz.category),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditQuizPage(
                      quizId: quiz.id,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
