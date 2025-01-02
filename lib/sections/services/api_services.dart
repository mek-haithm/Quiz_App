import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiServices {
  final String baseUrl = "http://192.168.1.103:8000/api";

  // Register User
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String role = "user",
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
        'role': role,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          jsonDecode(response.body)['message'] ?? 'Registration failed');
    }
  }

  // Login User
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Login failed');
    }
  }

  // Logout User
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        final url = Uri.parse('$baseUrl/logout');
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          print("Logged out successfully");
        } else {
          throw Exception(
              jsonDecode(response.body)['message'] ?? 'Logout failed');
        }

        await prefs.remove('auth_token');
      } else {
        print("No token found, user is not logged in.");
      }
    } catch (e) {
      print("Logout failed: $e");
    }
  }

// Fetch Quizzes
  Future<List<Map<String, dynamic>>> fetchQuizzes(String token) async {
    final url =
        Uri.parse('$baseUrl/quizzes'); // Replace with your correct endpoint
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Pass the token for authorization
      },
    );

    if (response.statusCode == 200) {
      // Parse the response body into a List of Maps (quizzes)
      List<dynamic> quizzesData = jsonDecode(response.body);
      return quizzesData.map((quiz) => quiz as Map<String, dynamic>).toList();
    } else {
      throw Exception(
          jsonDecode(response.body)['message'] ?? 'Failed to fetch quizzes');
    }
  }

  Future<List<Map<String, dynamic>>> fetchQuestions(String token, int quizId) async {
    final url = Uri.parse('$baseUrl/quizzes/$quizId/questions');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> questionsData = jsonDecode(response.body);
      return questionsData.map((question) => question as Map<String, dynamic>).toList();
    } else {
      throw Exception(
          jsonDecode(response.body)['message'] ?? 'Failed to fetch questions');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAnswers(String token, int questionId) async {
    final url = Uri.parse('$baseUrl/questions/$questionId/answers');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      // Directly accessing the 'answers' key which holds the list
      List<dynamic> answersData = responseData['answers'];
      return answersData.map((answer) => answer as Map<String, dynamic>).toList();
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch answers');
    }
  }

  Future<void> submitQuiz(int quizId, int score, String token) async {
    final url = Uri.parse('$baseUrl/results');

    // Prepare the request body
    final body = json.encode({
      'quiz_id': quizId,
      'score': score,
    });

    // Set up the headers with the authentication token
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',  // Pass the user's authentication token here
    };

    // Send the POST request
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    // Check the response
    if (response.statusCode == 201) {
      // Successfully submitted the quiz result
      print('Quiz result submitted successfully');
      final result = json.decode(response.body);
      print('Result: $result');
    } else {
      // Handle errors
      print('Failed to submit quiz result: ${response.statusCode}');
      print(response.body);
    }
  }


}
