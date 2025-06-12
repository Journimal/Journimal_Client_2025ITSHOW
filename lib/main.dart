import 'package:flutter/material.dart';
import 'package:journimal_client/screen/auth/signup.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Journimal',
        theme: ThemeData(
          primarySwatch: Colors.lightGreen,
        ),
        home: SignupScreen());
  }
}
