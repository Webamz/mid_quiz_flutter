import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoresPage extends StatefulWidget {
  const ScoresPage({Key? key}) : super(key: key);

  @override
  _ScoresPageState createState() => _ScoresPageState();
}

class _ScoresPageState extends State<ScoresPage> {
  List<Map<String, dynamic>> _userScores = [];

  @override
  void initState() {
    super.initState();
    _retrieveUserScores();
  }

  Future<void> _retrieveUserScores() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final User? user = FirebaseAuth.instance.currentUser;
      final String? userId = user?.email; // Get the user ID

      if (userId != null) {
        final String? scoresString = prefs.getString('$userId-quiz_scores');
        if (scoresString != null) {
          final List<dynamic> scoresList = await Future<List<dynamic>>.value(
              json.decode(scoresString) as List<dynamic>? ?? []);
          setState(() {
            _userScores = List<Map<String, dynamic>>.from(
              scoresList.map((e) => Map<String, dynamic>.from(e)),
            );
          });
        }
      }
    } catch (e) {
      print('Error retrieving user scores: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Scores'),
      ),
      body: _userScores.isEmpty
          ? const Center(
              child: Text('No scores available.'),
            )
          : ListView.builder(
              itemCount: _userScores.length,
              itemBuilder: (context, index) {
                final score = _userScores[index];
                final quizTitle = score['quizTitle'];
                final userScore = score['score'];
                final timestamp = score['timestamp'];

                return ListTile(
                  title: Text(quizTitle),
                  subtitle: Text(
                    'Score: $userScore\nTimestamp: $timestamp',
                  ),
                );
              },
            ),
    );
  }
}
