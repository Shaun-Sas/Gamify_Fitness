import 'package:client/services/authenticator.dart';

import 'package:client/theme/dark_mode.dart';
import 'package:client/theme/light_mode.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Level Up',
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const Authenticator(),
    );
  }
}
