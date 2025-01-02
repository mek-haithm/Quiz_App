import 'package:flutter/material.dart';
import 'package:quiz_app/sections/quizzes/screens/quizzes_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import '../../shared/constants/colors.dart';
import '../../shared/constants/sizes.dart';
import '../../shared/constants/text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkTokenAndNavigate();
  }

  void _checkTokenAndNavigate() async {
    await Future.delayed(
        const Duration(seconds: 3)); // Simulate a delay for splash screen
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token'); // Retrieve the token

    if (token != null && token.isNotEmpty) {
      // Token exists, navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const QuizzesScreen()),
      );
    } else {
      // No token, navigate to LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.quiz,
              size: 100,
              color: kMainColor,
            ),
            kSizedBoxHeight_25,
            Text(
              'Quiz App',
              style: kTitleTextStyle(context),
            ),
          ],
        ),
      ),
    );
  }
}
