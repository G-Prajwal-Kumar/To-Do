import 'package:flutter/material.dart';
import 'package:keka_to_do_list/home_screen.dart';

class LoadingSplash extends StatefulWidget {

  const LoadingSplash({super.key});

  @override
  State<LoadingSplash> createState() => _LoadingSplashState();
}

class _LoadingSplashState extends State<LoadingSplash> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () => {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()))
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(41, 98, 255, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              color: Colors.white,
              width: MediaQuery.of(context).size.width * 0.2,
              image: const AssetImage('assets/to-do-list.png'),
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 15),
            const Text(
              'To-Do List Application',
              style: TextStyle(
                color: Colors.white,
                fontFamily: "Lato",
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      )
    );
  }
}