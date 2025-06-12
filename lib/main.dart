import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:journimal_client/screen/auth/signup.dart';
import 'package:journimal_client/screen/main_screen.dart';
import 'package:provider/provider.dart';
import 'providers/mission_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    ChangeNotifierProvider(
      create: (_) => MissionProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  final bool isSignUp = false; // 나중에 로그인하면 true로 바뀜

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Journimal',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: isSignUp ? MainScreen() : SignupScreen(),
    );
  }
}
