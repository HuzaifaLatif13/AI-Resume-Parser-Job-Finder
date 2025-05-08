import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parser/view/auth/login_screen.dart';
import 'package:parser/view/resume_parser_screen.dart';

import 'const/colors.dart';
import 'controller/login_controller.dart';
import 'modals/user.dart';

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
        widget.controller.loadUser();
        Get.to(() => ResumeParserScreen(resume: Resume()));
      } else {
        Get.to(() => LoginScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Center(
        child: Image.asset('assets/app_logo.png'),
        // child: Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: [
        //     Text(
        //       'AI',
        //       style: TextStyle(
        //         fontSize: 40,
        //         fontWeight: FontWeight.bold,
        //         color: AppColors.text,
        //       ),
        //     ),
        //     Text(
        //       'Resume Parser 📝',
        //       style: TextStyle(
        //         fontSize: 30,
        //         fontWeight: FontWeight.bold,
        //         color: AppColors.text,
        //       ),
        //     ),
        //     Text(
        //       '&',
        //       style: TextStyle(
        //         fontSize: 40,
        //         fontWeight: FontWeight.bold,
        //         color: AppColors.text,
        //       ),
        //     ),
        //     Text(
        //       'Your Job Finder 🔍',
        //       style: TextStyle(
        //         fontSize: 30,
        //         fontWeight: FontWeight.bold,
        //         color: AppColors.text,
        //       ),
        //     ),
        //     SizedBox(height: 100),
        //     Container(
        //       decoration: BoxDecoration(
        //         color: AppColors.text,
        //         borderRadius: BorderRadius.circular(10),
        //       ),
        //       child: Lottie.asset(
        //         'assets/search.json',
        //         width: 150,
        //         height: 150,
        //         fit: BoxFit.fill,
        //       ),
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
