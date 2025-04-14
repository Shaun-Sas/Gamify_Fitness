import 'dart:convert';
import 'package:client/pages/signin_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isloading = false;
  String errmsg = "";
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameControlller = TextEditingController();

  void signup() async {
    setState(() {
      isloading = true;
    });

    final response = await http.post(
      Uri.parse("http://localhost:5000/auth/signup"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usernameControlller.text,
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      navigate();
    } else {
      setState(() {
        errmsg = response.body;
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(35.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                const SizedBox(height: 010),
                const Text("M I N I M A L", style: TextStyle(fontSize: 20)),
                const SizedBox(height: 25),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    label: const Text("Email"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: "",
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: usernameControlller,
                  decoration: InputDecoration(
                    label: const Text("Username"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    label: const Text("Password"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                isloading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.inversePrimary,
                      ),
                      onPressed: () {
                        signup();
                      },
                      child: const Text(
                        "Continue",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                const SizedBox(height: 20),
                Padding(padding: const EdgeInsets.all(16), child: Text(errmsg)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        " signup Here",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void navigate() {
    Navigator.pop(context);
  }
}
