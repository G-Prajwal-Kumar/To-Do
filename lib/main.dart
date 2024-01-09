import 'package:flutter/material.dart';
import 'package:keka_to_do_list/loading_splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Lato'
      ),
      debugShowCheckedModeBanner: false,
      home: const LoadingSplash(),
    );
  }
}