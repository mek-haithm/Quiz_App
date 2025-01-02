import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/sections/questions/screens/question_screen.dart';
import 'package:quiz_app/sections/quizzes/widgets/quiz_box.dart';
import 'package:quiz_app/shared/alerts/my_message.dart';
import 'package:quiz_app/shared/widgets/my_progress_indicator.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/constants/text_styles.dart';
import 'package:quiz_app/sections/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../logins/login_screen.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  final ApiServices _apiServices = ApiServices();
  List<Map<String, dynamic>> _quizzes = [];
  bool _isLoading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchQuizzes();
  }

  // Load token and fetch quizzes with a timeout
  void _loadTokenAndFetchQuizzes() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');

    if (_token != null) {
      try {
        // Add a timeout to limit how long we wait for the response
        final quizzes = await _apiServices
            .fetchQuizzes(_token!)
            .timeout(Duration(seconds: 5));
        setState(() {
          _quizzes = quizzes;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (kDebugMode) {
          print('Error fetching quizzes or timeout: $e');
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

  void _logout() async {
    try {
      MyProgressIndicator.showProgressIndicator(context);
      MyMessage.showMyMessage(
        context: context,
        message: 'Are you sure you want to logout?',
        firstButton: 'No',
        onFirstButtonPressed: () {
          MyProgressIndicator.hideProgressIndicator(context);
          Navigator.pop(context);
        },
        secondButton: 'Yes',
        onSecondButtonPressed: () {
          _apiServices.logout();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        },
        isDismissible: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error while login out.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        automaticallyImplyLeading: false,
        backgroundColor: kMainColor,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Quizzes",
        ),
        titleTextStyle: kInactiveBoldTextStyle(context).copyWith(
          fontSize: 20.0,
          color: kBackground,
        ),
        leading: IconButton(
          onPressed: () {
            _logout();
          },
          icon: Icon(
            Icons.logout,
            color: kBackground,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: MyProgressIndicator())
          : _quizzes.isEmpty
              ? Center(
                  child: Text(
                    'No quizzes available',
                    style: kInactiveBoldTextStyle(context),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(10.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: _quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = _quizzes[index];
                    return QuizBox(
                      title: quiz['title'] ?? 'Untitled',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuestionScreen(
                              quizId: quiz['id'],
                            ),
                          ),
                        );
                      },
                      description: quiz['description'] ?? 'No description',
                    );
                  },
                ),
    );
  }
}
