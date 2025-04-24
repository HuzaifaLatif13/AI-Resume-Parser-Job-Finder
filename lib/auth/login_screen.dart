import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parser/auth/signup_screen.dart';
import 'package:parser/controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black12,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Log In',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
              ),
            ),
            Obx(
              () => TextField(
                keyboardType: TextInputType.emailAddress,
                controller: controller.email,
                onChanged: (value) {
                  controller.emailText.value = value;
                },
                decoration: InputDecoration(
                  fillColor: Colors.blueGrey.withOpacity(0.5),
                  filled: true,
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.greenAccent),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.greenAccent),
                  ),
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.yellow),
                  suffixIcon:
                      controller.emailText.isNotEmpty
                          ? IconButton(
                            onPressed: () {
                              controller.clearEmail();
                            },
                            icon: Icon(Icons.clear, color: Colors.red),
                          )
                          : null,
                  hintText: 'Enter Email',
                ),
                cursorColor: Colors.green,
                cursorHeight: 20,
                cursorWidth: 2,
                cursorRadius: Radius.circular(10),
                style: TextStyle(color: Colors.greenAccent),
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
                  //on focus show a eye suffix icon for show or unshow password
                  fillColor: Colors.blueGrey.withOpacity(0.5),
                  filled: true,
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  prefixIcon: Icon(
                    Icons.lock_open_outlined,
                    color: Colors.amber,
                  ),
                  suffixIcon:
                      controller.isPasswordVisible.value
                          ? IconButton(
                            onPressed: () {
                              controller.togglePasswordVisibility();
                            },
                            icon: Icon(Icons.visibility, color: Colors.red),
                          )
                          : IconButton(
                            onPressed: () {
                              controller.togglePasswordVisibility();
                            },
                            icon: Icon(Icons.visibility_off, color: Colors.red),
                          ),
                  hintText: 'Enter password',
                ),
                obscureText: !controller.isPasswordVisible.value,
                cursorColor: Colors.blue,
                cursorHeight: 20,
                cursorWidth: 2,
                cursorRadius: Radius.circular(10),
                style: TextStyle(color: Colors.greenAccent),
              ),
            ),
            SizedBox(height: 5),
            Obx(
              () => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  shadowColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal,
                  //full width
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  controller.login();
                },
                child:
                    controller.isLoading.value
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Log in'),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                controller.clearAll();
                Get.to(SignupScreen());
              },
              child: Text("Don't have an account? Create Now!"),
            ),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.amber,
                    indent: 10,
                    endIndent: 10,
                  ),
                ),
                Text('or', style: TextStyle(color: Colors.amber)),
                Expanded(
                  child: Divider(
                    color: Colors.amber,
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
                      color: Colors.white.withOpacity(0.9),
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
                      color: Colors.white.withOpacity(0.9),
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
