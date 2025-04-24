import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:parser/parsing/resume_parser_screen.dart';

import 'auth/login_screen.dart';
import 'controller/login_controller.dart';

class SplashScreen extends StatefulWidget {
  LoginController controller = Get.put(LoginController());

  SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      if (widget.controller.auth.currentUser != null) {
        Get.to(ResumeParserScreen());
      } else {
        Get.to(LoginScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'AI',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
            Text(
              'Resume Parser 📝',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
            Text(
              '&',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
            Text(
              'Your Job Finder 🔍',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
            SizedBox(height: 100),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Lottie.asset(
                'assets/search.json',
                width: 150,
                height: 150,
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
