import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_wallet/ui/screen/drawer_page.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_wallet/util/file_path.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  static DateTime now = DateTime.now();
  String formattedTime = DateFormat.jm().format(now);
  String formattedDate = DateFormat('EEE, MMM d, yyyy').format(now);

  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  Future<void> loginUser() async {
    final Map<String, dynamic> loginData = {
      'email': _email,
      'password': _password,
    };

    final response = await http.post(
      Uri.parse('http://192.168.79.1:8000/api/login/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(loginData),
    );

    if (response.statusCode == 200) {
      // Login successful
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login successful'),
        ),
      );

      // Save user ID to SharedPreferences
      final responseData = jsonDecode(response.body);
      final userId = responseData['user']['username']; // Adjust according to the API response
      await saveUserId(userId);

      // Navigate to the next screen or perform other actions after successful login
    } else {
      // Login failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed'),
        ),
      );
    }
  }

  Future<void> saveUserId(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_id', userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(0.1),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SvgPicture.asset(mainBanner), // Replace with your banner image
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _topContent(),
                      const SizedBox(height: 16),
                      _formContent(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          formattedTime,
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            SvgPicture.asset(logo), // Replace with your cloud image
            const SizedBox(width: 8),
            Text(
              'Smart NFC',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          formattedDate,
          style: Theme.of(context).textTheme.bodyText2,
        ),
      ],
    );
  }

  Widget _formContent() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
            onSaved: (value) => _email = value!,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
            onSaved: (value) => _password = value!,
          ),
          const SizedBox(height: 16),
          MaterialButton(
            elevation: 0,
            color: const Color(0xFFFFAC30),
            height: 50,
            minWidth: double.infinity,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                // Perform login with _email and _password
                await loginUser();
                // After login, navigate to the next screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DrawerPage(),
                  ),
                );
              }
            },
            child: Text(
              'Sign in',
              style: Theme.of(context).textTheme.button,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Create an Account',
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ],
      ),
    );
  }
}
