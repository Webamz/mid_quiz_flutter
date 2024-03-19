class Quiz {
  String id;
  String title;
  String category;
  List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.category,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    final String id = json['id'] ?? '';
    final String title = json['title'] ?? '';
    final String category = json['category'] ?? '';

    final List<dynamic> questionsData = json['questions'] ?? [];
    final List<Question> questions = questionsData.map((questionJson) {
      if (questionJson is Map<String, dynamic>) {
        return Question.fromJson(questionJson);
      } else {
        throw ArgumentError('Invalid question JSON format');
      }
    }).toList();

    return Quiz(
      id: id,
      title: title,
      category: category,
      questions: questions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'questions': questions.map((question) => question.toJson()).toList(),
    };
  }
}

class Question {
  String question;
  List<Option> options;
  int correctAnswerIndex;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final String question = json['question'] ?? '';
    final List<dynamic> optionsData = json['options'] ?? [];
    final List<Option> options = optionsData.map((optionJson) {
      if (optionJson is String) {
        return Option(
            text: optionJson,
            isCorrect: false); // Assuming default isCorrect value
      } else if (optionJson is Map<String, dynamic>) {
        return Option.fromJson(optionJson);
      } else {
        throw ArgumentError('Invalid option JSON format');
      }
    }).toList();

    final int correctAnswerIndex = json['correctAnswerIndex'] ?? -1;

    return Question(
      question: question,
      options: options,
      correctAnswerIndex: correctAnswerIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options.map((option) => option.text).toList(),
      'correctAnswerIndex': correctAnswerIndex,
    };
  }
}

class Option {
  String text;
  bool isCorrect;

  Option({required this.text, required this.isCorrect});

  factory Option.fromJson(Map<String, dynamic> json) {
    final String text = json['text'] ?? '';
    final bool isCorrect = json['isCorrect'] ?? false;

    return Option(text: text, isCorrect: isCorrect);
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isCorrect': isCorrect,
    };
  }
}
