// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_quiz_app_mid/models/quiz_model.dart';

class EditQuizPage extends StatefulWidget {
  final String quizId;

  const EditQuizPage({Key? key, required this.quizId}) : super(key: key);

  @override
  _EditQuizPageState createState() => _EditQuizPageState();
}

class _EditQuizPageState extends State<EditQuizPage> {
  Quiz? _quiz;
  late TextEditingController _titleController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _categoryController = TextEditingController();
    _fetchQuizData();
  }

  Future<void> _fetchQuizData() async {
    final quizDoc = await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(widget.quizId)
        .get();

    if (quizDoc.exists) {
      final quizData = quizDoc.data() as Map<String, dynamic>;
      setState(() {
        _quiz = Quiz.fromJson(quizData);
        _titleController.text = _quiz!.title;
        _categoryController.text = _quiz!.category;
      });
    } else {
      // Handle quiz not found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Quiz'),
        actions: [
          IconButton(
            onPressed: () {
              _deleteQuiz();
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: _quiz != null
          ? Padding(
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
                  const Text(
                    'Questions:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _quiz!.questions.length,
                      itemBuilder: (context, index) {
                        final question = _quiz!.questions[index];
                        return Card(
                          child: ListTile(
                            title: Text(question.question),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Options:'),
                                for (int i = 0;
                                    i < question.options.length;
                                    i++)
                                  ListTile(
                                    title: Text(question.options[i].text),
                                    leading: Radio<int>(
                                      value: i,
                                      groupValue: question.correctAnswerIndex,
                                      onChanged: (value) {
                                        setState(() {
                                          _quiz!.questions[index]
                                              .correctAnswerIndex = value!;
                                        });
                                      },
                                    ),
                                  ),
                              ],
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                _editQuestion(index);
                              },
                              icon: const Icon(Icons.edit),
                            ),
                            onTap: () {
                              _deleteQuestionConfirmation(context, index);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _addNewQuestion();
                    },
                    child: const Text('Add New Question'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      _updateQuiz();
                    },
                    child: const Text('Update Quiz'),
                  ),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Future<void> _updateQuiz() async {
    if (_quiz != null) {
      _quiz!.title = _titleController.text;
      _quiz!.category = _categoryController.text;

      try {
        await FirebaseFirestore.instance
            .collection('quizzes')
            .doc(widget.quizId)
            .update(_quiz!.toJson());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz updated successfully')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update quiz: $error')),
        );
      }
    }
  }

  Future<void> _deleteQuiz() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this quiz?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('quizzes')
                    .doc(widget.quizId)
                    .delete();
                Navigator.pop(context);
                Navigator.pop(context);
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete quiz: $error')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteQuestionConfirmation(
      BuildContext context, int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              _deleteQuestion(index);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewQuestion() async {
    final TextEditingController questionController = TextEditingController();
    final List<TextEditingController> optionControllers =
        List.generate(4, (_) => TextEditingController());

    final newQuestion = await showDialog<Question>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Question'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: questionController,
                  decoration: const InputDecoration(labelText: 'Question'),
                ),
                const SizedBox(height: 16.0),
                ...List.generate(
                  4,
                  (index) => TextFormField(
                    controller: optionControllers[index],
                    decoration:
                        InputDecoration(labelText: 'Option ${index + 1}'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final String questionText = questionController.text;
                final List<Option> options =
                    optionControllers.map((controller) {
                  return Option(text: controller.text, isCorrect: false);
                }).toList();

                final newQuestion = Question(
                    question: questionText,
                    options: options,
                    correctAnswerIndex: 0);
                Navigator.pop(context, newQuestion);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (newQuestion != null) {
      setState(() {
        _quiz!.questions.add(newQuestion);
      });
    }
  }

  Future<void> _deleteQuestion(int index) async {
    if (_quiz != null && _quiz!.questions.length > index) {
      setState(() {
        _quiz!.questions.removeAt(index);
      });
    }
  }

  void _editQuestion(int index) async {
    final newQuestion = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Question'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: _quiz!.questions[index].question,
                  decoration: const InputDecoration(labelText: 'Question'),
                  onChanged: (value) {
                    // Update the question text
                    _quiz!.questions[index].question = value;
                  },
                ),
                const SizedBox(height: 16.0),
                ..._quiz!.questions[index].options.map((option) {
                  return TextFormField(
                    initialValue: option.text,
                    decoration: const InputDecoration(labelText: 'Option'),
                    onChanged: (value) {
                      // Update the option text
                      option.text = value;
                    },
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context,
                    _quiz!.questions[index]); // Return the updated question
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newQuestion != null) {
      setState(() {
        _quiz!.questions[index] = newQuestion;
      });
    }
  }
}
