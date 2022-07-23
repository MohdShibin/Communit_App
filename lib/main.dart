import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../pages/login_page.dart';
import 'services/auth_decider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        tabBarTheme: TabBarTheme(
          labelColor: Colors.black,

        ),
      ),
      home: AuthDecider(),
    );
  }
}
