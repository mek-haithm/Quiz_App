import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/sections/logins/sign_up_screen.dart';
import 'package:quiz_app/sections/quizzes/screens/quizzes_screen.dart';
import 'package:quiz_app/sections/services/api_services.dart';
import 'package:quiz_app/shared/alerts/my_message.dart';
import 'package:quiz_app/shared/constants/colors.dart';
import 'package:quiz_app/shared/constants/sizes.dart';
import 'package:quiz_app/shared/constants/text_styles.dart';
import 'package:quiz_app/shared/widgets/my_button.dart';
import 'package:quiz_app/shared/widgets/my_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/widgets/my_progress_indicator.dart';
import '../../shared/widgets/my_snack_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  final _apiServices = ApiServices();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _login() async {
    try {
      MyProgressIndicator.showProgressIndicator(context);

      final response = await _apiServices.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.containsKey('user')) {
        final user = response['user'];
        final token = response['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        if (kDebugMode) {
          print("User: $user");
          print("Token saved: $token");
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => QuizzesScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      MyProgressIndicator.hideProgressIndicator(context);
      MySnackBar.showSnackBar(context: context, message: e.toString());
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: kBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 50.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Login',
                    style: kTitleTextStyle(context).copyWith(fontSize: 35.0),
                  ),
                  kSizedBoxHeight_60,
                  MyTextField(
                    hintText: 'Email',
                    controller: _emailController,
                    isEmail: true,
                    focusNode: _emailFocusNode,
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                  ),
                  kSizedBoxHeight_15,
                  MyTextField(
                    hintText: 'Password',
                    controller: _passwordController,
                    isPassword: true,
                    focusNode: _passwordFocusNode,
                    onSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  kSizedBoxHeight_15,
                  MyButton(
                    text: 'Login',
                    onPressed: () {
                      _passwordFocusNode.unfocus();
                      if (_emailController.text.isEmpty ||
                          _passwordController.text.isEmpty) {
                        MyMessage.showWarningMessage(
                          context,
                          'All fields must be filled.',
                        );
                      } else {
                        _login();
                      }
                    },
                  ),
                  kSizedBoxHeight_15,
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Don\'t have an account? Sign up',
                      style: kButtonAlertTextStyle(context)
                          .copyWith(fontSize: 15.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
