import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/shared/widgets/my_progress_indicator.dart';
import 'package:quiz_app/shared/widgets/my_snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/alerts/my_message.dart';
import '../../shared/constants/colors.dart';
import '../../shared/constants/sizes.dart';
import '../../shared/constants/text_styles.dart';
import '../../shared/widgets/my_button.dart';
import '../../shared/widgets/my_text_field.dart';
import '../services/api_services.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _apiServices = ApiServices();
  final _formKey = GlobalKey<FormState>();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus(); // Hides the keyboard
      MyProgressIndicator.showProgressIndicator(context);
      try {
        final response = await _apiServices.register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );

        final user = response['user'];
        final token = response['token'];

        if (kDebugMode) {
          print("User: $user");
          print("Token: $token");
        }

        // Save token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        MyProgressIndicator.showProgressIndicator(context);

        // Log out immediately
        _apiServices.logout();

        // Navigate to Login Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      } catch (e) {
        MyProgressIndicator.hideProgressIndicator(context);
        MySnackBar.showSnackBar(context: context, message: e.toString());
        if (kDebugMode) {
          print(e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: kBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15.0,
            vertical: 50.0,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign Up',
                    style: kTitleTextStyle(context).copyWith(fontSize: 35.0),
                  ),
                  kSizedBoxHeight_60,
                  MyTextField(
                    hintText: 'Name',
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_emailFocusNode);
                    },
                  ),
                  kSizedBoxHeight_15,
                  MyTextField(
                    hintText: 'Email',
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    isEmail: true,
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                  ),
                  kSizedBoxHeight_15,
                  MyTextField(
                    hintText: 'Password',
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    isPassword: true,
                    onSubmitted: (_) {
                      FocusScope.of(context)
                          .requestFocus(_confirmPasswordFocusNode);
                    },
                  ),
                  kSizedBoxHeight_15,
                  MyTextField(
                    hintText: 'Confirm Password',
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocusNode,
                    isPassword: true,
                    onSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  kSizedBoxHeight_15,
                  MyButton(
                    text: 'Sign Up',
                    onPressed: () {
                      _confirmPasswordFocusNode.unfocus();
                      if (_emailController.text.isEmpty ||
                          _passwordController.text.isEmpty) {
                        MyMessage.showWarningMessage(
                          context,
                          'All fields must be filled.',
                        );
                      } else {
                        _signup();
                      }
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Already have an account? Login',
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
