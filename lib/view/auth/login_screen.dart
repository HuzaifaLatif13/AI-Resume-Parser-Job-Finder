import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parser/const/colors.dart';
import 'package:parser/controller/login_controller.dart';
import 'package:parser/view/auth/signup_screen.dart';

class LoginScreen extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Log In',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Obx(
              () => TextField(
                keyboardType: TextInputType.emailAddress,
                controller: controller.email,
                onChanged: (value) {
                  controller.emailText.value = value;
                },
                decoration: InputDecoration(
                  fillColor: AppColors.container,
                  filled: true,
                  labelText: 'Email',
                  labelStyle: TextStyle(color: AppColors.text),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.scaffold),
                  ),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.scaffold,
                  ),
                  suffixIcon:
                      controller.emailText.isNotEmpty
                          ? IconButton(
                            onPressed: () {
                              controller.clearEmail();
                            },
                            icon: Icon(Icons.clear, color: AppColors.error),
                          )
                          : null,
                  hintText: 'Enter Email',
                ),
                cursorColor: AppColors.text,
                cursorHeight: 20,
                cursorWidth: 2,
                cursorRadius: Radius.circular(10),
                style: TextStyle(color: AppColors.text),
              ),
            ),
            Obx(
              () => TextField(
                keyboardType: TextInputType.visiblePassword,
                controller: controller.pass,
                onChanged: (value) {
                  controller.passText.value = value;
                },
                decoration: InputDecoration(
                  fillColor: AppColors.container,
                  filled: true,
                  labelText: 'Password',
                  labelStyle: TextStyle(color: AppColors.text),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.scaffold),
                  ),
                  prefixIcon: Icon(
                    Icons.lock_open_outlined,
                    color: AppColors.scaffold,
                  ),
                  suffixIcon:
                      controller.isPasswordVisible.value
                          ? IconButton(
                            onPressed: () {
                              controller.togglePasswordVisibility();
                            },
                            icon: Icon(
                              Icons.visibility,
                              color: AppColors.error.withOpacity(0.7),
                            ),
                          )
                          : IconButton(
                            onPressed: () {
                              controller.togglePasswordVisibility();
                            },
                            icon: Icon(
                              Icons.visibility_off,
                              color: AppColors.error.withOpacity(0.7),
                            ),
                          ),
                  hintText: 'Enter password',
                ),
                obscureText: !controller.isPasswordVisible.value,
                cursorColor: AppColors.text,
                cursorHeight: 20,
                cursorWidth: 2,
                cursorRadius: Radius.circular(10),
                style: TextStyle(color: AppColors.text),
              ),
            ),
            SizedBox(height: 5),
            Obx(
              () => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  shadowColor: AppColors.text,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: AppColors.text),
                  ),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: AppColors.buttonBackground,
                  //full width
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  if (controller.email.text.isEmpty ||
                      controller.pass.text.isEmpty) {
                    Get.snackbar(
                      'Login Error',
                      'Empty email or password.',
                      backgroundColor: AppColors.error,
                    );
                  } else {
                    controller.login();
                  }
                },
                child:
                    controller.isLoading.value
                        ? CircularProgressIndicator(color: AppColors.text)
                        : Text(
                          'Log in',
                          style: TextStyle(color: AppColors.text),
                        ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                controller.clearAll();
                Get.to(SignupScreen());
              },
              child: Text(
                "Don't have an account? Create Now!",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: AppColors.text,
                    indent: 10,
                    endIndent: 10,
                  ),
                ),
                Text('or', style: TextStyle(color: AppColors.text)),
                Expanded(
                  child: Divider(
                    color: AppColors.text,
                    indent: 10,
                    endIndent: 10,
                  ),
                ),
              ],
            ),
            Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    controller.googleLogin();
                    // Get.to(ResumeParserScreen());
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: AppColors.text,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green,
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.g_mobiledata_outlined,
                      color: Colors.green,
                      size: 50,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: AppColors.text,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue,
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.facebook_outlined,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
