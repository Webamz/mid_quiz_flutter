import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminScoresPage extends StatelessWidget {
  const AdminScoresPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Scores'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('quiz_results').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userScores = snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Quiz Title')),
                DataColumn(label: Text('User Email')),
                DataColumn(label: Text('Score')),
                DataColumn(label: Text('Timestamp')),
              ],
              rows: userScores.map((userScore) {
                final userScoreData = userScore.data() as Map<String, dynamic>;
                final quizTitle = userScoreData['quizTitle'] ?? '';
                final userEmail = userScoreData['userId'] ?? '';
                final score = userScoreData['score'] ?? '';
                dynamic timestamp = userScoreData['timestamp'];
                if (timestamp is String) {
                  // Parse the string timestamp into a DateTime object
                  final dateTime = DateTime.tryParse(timestamp);
                  if (dateTime != null) {
                    timestamp =
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
                  } else {
                    timestamp = ''; // Set to empty string if parsing fails
                  }
                } else if (timestamp is Timestamp) {
                  // Format the Timestamp object
                  timestamp = DateFormat('yyyy-MM-dd HH:mm:ss')
                      .format(timestamp.toDate());
                } else {
                  timestamp =
                      ''; // Set to empty string if not a string or Timestamp
                }

                return DataRow(
                  cells: [
                    DataCell(Text(quizTitle)),
                    DataCell(Text(userEmail)),
                    DataCell(Text(score.toString())),
                    DataCell(Text(timestamp.toString())),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
