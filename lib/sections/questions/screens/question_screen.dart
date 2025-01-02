import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/sections/questions/widgets/answer_tile.dart';
import 'package:quiz_app/shared/alerts/my_message.dart';
import 'package:quiz_app/shared/constants/sizes.dart';
import 'package:quiz_app/shared/widgets/my_progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/text_styles.dart';
import '../../quizzes/screens/quizzes_screen.dart';
import '../../services/api_services.dart';

class QuestionScreen extends StatefulWidget {
  final int quizId;
  const QuestionScreen({
    super.key,
    required this.quizId,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final ApiServices _apiServices = ApiServices();
  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _answers = [];
  bool _isLoading = true;
  String? _token;
  int _currentQuestionIndex = 0;
  int? selectedAnswer; // Track the selected answer
  bool isAnswerSelected = false; // Track if an answer is selected

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchQuestions();
  }

  void _loadTokenAndFetchQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');

    if (_token != null) {
      try {
        final questions = await _apiServices
            .fetchQuestions(_token!, widget.quizId)
            .timeout(const Duration(seconds: 5));
        setState(() {
          _questions = questions;
          _isLoading = false;
        });

        if (_questions.isNotEmpty) {
          _loadAnswers(_questions[_currentQuestionIndex]['id']);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (kDebugMode) {
          print('Error fetching questions or timeout: $e');
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      if (kDebugMode) {
        print('No token found');
      }
    }
  }

  void _loadAnswers(int questionId) async {
    setState(() {
      _isLoading = true;
    });

    if (_token != null) {
      try {
        final answers = await _apiServices.fetchAnswers(_token!, questionId);
        setState(() {
          _answers = answers;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (kDebugMode) {
          print('Error fetching answers: $e');
        }
      }
    }
  }

  // Increment score if the selected answer is correct
  void _incrementScore(bool isCorrect) async {
    final prefs = await SharedPreferences.getInstance();
    int currentScore = prefs.getInt('quiz_score') ?? 0;
    if (isCorrect) {
      currentScore++;
      await prefs.setInt('quiz_score', currentScore);
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        selectedAnswer = null;
        isAnswerSelected = false;
      });
      _loadAnswers(_questions[_currentQuestionIndex]['id']);
    } else {
      _submitQuizAndShowDialog();
    }
  }

  void _submitQuizAndShowDialog() async {
    int score = await _calculateScore();
    await _apiServices.submitQuiz(widget.quizId, score, _token!);

    // Remove score from SharedPreferences after submission
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('quiz_score'); // Remove the stored score

    // Show the dialog after submission
    MyMessage.showMessage(
      context,
      'Quiz Finished',
      'Your score is: $score / ${_questions.length}',
      () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => QuizzesScreen()),
          (Route<dynamic> route) => false,
        );
      },
    );
  }

  Future<int> _calculateScore() async {
    final prefs = await SharedPreferences.getInstance();
    int correctAnswers = prefs.getInt('quiz_score') ?? 0;
    return correctAnswers;
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        selectedAnswer = null;
        isAnswerSelected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        elevation: 0.0,
        automaticallyImplyLeading: false,
        backgroundColor: kMainColor,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Questions",
        ),
        titleTextStyle: kInactiveBoldTextStyle(context).copyWith(
          fontSize: 20.0,
          color: kBackground,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 50.0,
        ),
        child: _isLoading
            ? const Center(child: MyProgressIndicator())
            : _questions.isEmpty
                ? Center(
                    child: Text(
                      'No questions found',
                      style: kInactiveBoldTextStyle(context),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                kSizedBoxHeight_30,
                                Text(
                                  _questions[_currentQuestionIndex]
                                          ['question_text'] ??
                                      'No Question Text',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                kSizedBoxHeight_40,
                                _answers.isEmpty
                                    ? Text(
                                        'No answers available',
                                        style: const TextStyle(fontSize: 16),
                                      )
                                    : Expanded(
                                        child: ListView.builder(
                                          itemCount: _answers.length,
                                          itemBuilder: (context, index) {
                                            bool isCorrect = _answers[index]
                                                    ['is_correct'] ==
                                                1;
                                            return AnswerTile(
                                              title: _answers[index]
                                                  ['answer_text'],
                                              value: index,
                                              groupValue: selectedAnswer,
                                              onChanged: !isAnswerSelected
                                                  ? (value) {
                                                      setState(() {
                                                        selectedAnswer = value;
                                                        isAnswerSelected = true;
                                                      });
                                                      _incrementScore(
                                                          isCorrect);
                                                    }
                                                  : null,
                                              isCorrect: isCorrect,
                                              showFeedback: isAnswerSelected &&
                                                  selectedAnswer == index,
                                            );
                                          },
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _currentQuestionIndex < _questions.length - 1
                                      ? kMainColor
                                      : kBackground,
                              foregroundColor:
                                  _currentQuestionIndex < _questions.length - 1
                                      ? kBackground
                                      : kMainColor,
                              shadowColor: Colors.black,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                            ),
                            onPressed: _nextQuestion,
                            child: _currentQuestionIndex < _questions.length - 1
                                ? Text('Next')
                                : Text('Submit'),
                          ),
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }
}
