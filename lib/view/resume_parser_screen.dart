import 'dart:convert';
import 'dart:io';

import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:parser/const/colors.dart';
import 'package:parser/controller/login_controller.dart';
import 'package:parser/controller/notification_controller.dart';
import 'package:parser/controller/notification_service.dart';
import 'package:parser/controller/service_key.dart';
import 'package:parser/modals/user.dart';
import 'package:parser/view/drawer/resume_scans.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../controller/send_notification.dart';
import '../main.dart';
import 'auth/login_screen.dart';
import 'drawer/myaccount_screen.dart';
import 'job_list_screen.dart';
import 'notification_screen.dart';

class ResumeParserScreen extends StatefulWidget {
  final LoginController controller = Get.find<LoginController>();
  final Resume resume;

  ResumeParserScreen({super.key, required this.resume});

  @override
  _ResumeParserScreenState createState() => _ResumeParserScreenState();
}

class _ResumeParserScreenState extends State<ResumeParserScreen> {
  NotificationService notificationService = NotificationService();
  var isLoading = false.obs;
  var jobLoading = false.obs;

  var extractedText = "No text extracted yet.".obs;

  final String apiKey =
      "AIzaSyDxgUYiBKZN2liKNg6HLlyS7jiTm0aIHGs"; // Replace with your Google Gemini API Key

  Future<void> pickAndExtractText() async {
    isLoading.value = true;
    widget.resume.name.value = "Not Found";
    widget.resume.email.value = "Not Found";
    widget.resume.phone.value = "Not Found";
    widget.resume.skills.value = "Not Found";
    widget.resume.education.value = "Not Found";
    widget.resume.projects.value = "Not Found";
    widget.resume.jobRoles.clear();

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      extractAndParseText(file);
    }
    isLoading.value = false;
  }

  Future<void> extractAndParseText(File pdfFile) async {
    isLoading.value = true;
    try {
      final PdfDocument document = PdfDocument(
        inputBytes: await pdfFile.readAsBytes(),
      );

      String text = PdfTextExtractor(document).extractText();
      document.dispose();

      extractedText.value = text;

      await extractUsingGeminiAI(text);
    } catch (e) {
      extractedText.value = "Error extracting text: $e";
    }
    isLoading.value = false;
  }

  Future<void> extractUsingGeminiAI(String text) async {
    isLoading.value = true;

    print(isLoading.value);
    final Uri url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash-lite:generateContent?key=$apiKey",
    );

    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "parts": [
            {
              "text": """
Extract the following details from the resume text:
- Name
- Email
- Phone number
- Skills
- Education
- Projects (title & description)

Remember If a detail is not found from the resume text, place value "Not Found" in response.
I only need values from the resume text provided.
Sometimes uploaded resume text that does not have all info i needed. in that case, never add a value by yourself or from the example given below.

Return the response in JSON format without any extra characters:
{
  "name": "John Doe",
  "email": "johndoe@gmail.com",
  "phone": "+1-234-567-890",
  "skills": ["Flutter", "Dart", "Firebase"],
  "education": "Bachelor's in Computer Science, XYZ University",
  "projects": [
    {
      "title": "Weather App",
      "description": "Developed a Flutter-based weather app using OpenWeather API."
    },
    {
      "title": "E-commerce Website",
      "description": "Built a full-stack e-commerce platform using React and Node.js."
    }
  ]
}

Resume Text:
$text
""",
            },
          ],
        },
      ],
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(response.body);

        if (result.containsKey('candidates') &&
            result['candidates'].isNotEmpty) {
          String content =
              result['candidates'][0]['content']['parts'][0]['text'];

          // 🔹 Remove backticks (```json and ```)
          content = content.replaceAll(RegExp(r'```json|```'), '').trim();

          // print("Cleaned Extracted Data: $content");

          try {
            Map<String, dynamic> extractedData = jsonDecode(content);
            parseEntities(extractedData); // Use extracted JSON
          } catch (jsonError) {
            print("JSON Parsing Error: $jsonError. Cleaned Response: $content");
          }
        } else {
          print("API Response Format Unexpected: ${response.body}");
        }
        isLoading.value = false;
      } else {
        print("API Error: ${response.body}");
      }
    } catch (e) {
      print("API Request Failed: $e");
    }
    isLoading.value = false;
  }

  void parseEntities(Map<String, dynamic> response) {
    isLoading.value = true;

    if (response.containsKey("name"))
      widget.resume.name.value = response["name"];
    if (response.containsKey("email"))
      widget.resume.email.value = response["email"];
    if (response.containsKey("phone"))
      widget.resume.phone.value = response["phone"];
    if (response.containsKey("skills")) {
      widget.resume.skills.value = response["skills"].join(", ");
    }
    if (response.containsKey("education"))
      widget.resume.education.value = response["education"];

    if (response.containsKey("projects")) {
      widget.resume.projects.value = response["projects"]
          .map<String>((project) {
            return "${project['title']}: ${project['description']}";
          })
          .toList()
          .join("\n");
    }
    isLoading.value = false;
  }

  Future<void> roleUsingGemini() async {
    jobLoading.value = true;

    final Uri url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash-lite:generateContent?key=$apiKey",
    );

    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "parts": [
            {
              "text": """
Based on the following skills, education, and projects, and suggest top 3 most relevant job roles according to it. Provide both general roles (e.g., Web Developer, App Developer, UI/UX Designer) and specific roles (e.g., MERN Stack Developer, Flutter Developer, React Native Developer). 

### Skills:
${widget.resume.skills}

### Education:
${widget.resume.education}

### Projects:
${widget.resume.projects}

Return the response in JSON format, containing only a list of job roles:
{
  "job_roles": [
    "role 1",
    "role 2",
    "role 3"
  ]
}
""",
            },
          ],
        },
      ],
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(response.body);

        if (result.containsKey('candidates') &&
            result['candidates'].isNotEmpty) {
          String content =
              result['candidates'][0]['content']['parts'][0]['text'];

          // 🔹 Remove backticks (```json and ```)
          content = content.replaceAll(RegExp(r'```json|```'), '').trim();

          print("Extracted Job Roles: $content");

          try {
            Map<String, dynamic> extractedData = jsonDecode(content);

            if (extractedData.containsKey("job_roles")) {
              widget.resume.jobRoles.assignAll(
                List<String>.from(extractedData["job_roles"]),
              );
            }
          } catch (jsonError) {
            print("JSON Parsing Error: $jsonError. Cleaned Response: $content");
          }
        } else {
          print("API Response Format Unexpected: ${response.body}");
        }
      } else {
        print("API Error: ${response.body}");
      }
    } catch (e) {
      print("API Request Failed: $e");
    }
    jobLoading.value = false;
  }

  @override
  void initState() {
    super.initState();
    notificationService.requestNotificationPermission();
    notificationService.getToken();
    notificationService.firebaseInit(context);
    notificationService.offNotifications(context);
    // FcmService.firebaseinit();
  }

  NotificationController notifyController = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.scaffold,
        title: Text(
          'AI Resume Parser',
          style: TextStyle(color: AppColors.text),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await widget.controller.loadUser();
              widget.resume.name.value = "Not Found";
              widget.resume.email.value = "Not Found";
              widget.resume.phone.value = "Not Found";
              widget.resume.skills.value = "Not Found";
              widget.resume.education.value = "Not Found";
              widget.resume.projects.value = "Not Found";
              widget.resume.jobRoles.clear();
              SendNotification.sendNotification(
                token: await NotificationService().getToken(),
                title: widget.controller.userAccount.name.value,
                body: 'Welcome to the app😊',
                data: {
                  'name': widget.controller.userAccount.name.value,
                  'email': widget.controller.userAccount.email.value,
                },
              );
              await fetchAndNotifyLatestJobs("software engineer");
              setState(() {});
            },
            icon: Icon(Icons.refresh),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Obx(
              () => badges.Badge(
                position: badges.BadgePosition.topEnd(top: 0, end: 1),
                showBadge: notifyController.NotificationCount.value > 0,
                badgeContent: Obx(
                  () => Text(
                    notifyController.NotificationCount.value.toString(),
                    style: TextStyle(color: AppColors.text),
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    Get.to(() => NotificationScreen());
                  },
                  icon: Icon(Icons.notifications_active),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: myDrawer(widget.controller),
      body: RefreshIndicator(
        color: AppColors.refresh,
        onRefresh: () => widget.controller.loadUser(),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Obx(
                () => Center(
                  child: Text(
                    "Welcome, ${widget.controller.userAccount.name.value} 😊",
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: BorderSide(color: Colors.white, width: 1),
                  ),
                ),
                onPressed: () {
                  Get.to(JobListScreen(searchQuery: "Software Engineer"));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Search Jobs yourself...",
                    style: TextStyle(color: AppColors.text, fontSize: 20),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.lightBlueAccent, thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'or',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.lightBlueAccent, thickness: 1),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  //border
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: BorderSide(color: Colors.white, width: 1),
                  ),
                  backgroundColor: AppColors.buttonBackground,
                ),
                onPressed: () async {
                  await pickAndExtractText();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Pick & Parse Resume",
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  "📝 Extracted Info",
                  style: TextStyle(
                    // color: Colors.blueAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Scrollable section for extracted details
              paresInfo(isLoading, widget),

              SizedBox(height: 5),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.resume.skills.value == "No data" ||
                        widget.resume.skills.value.isEmpty ||
                        widget.resume.skills.value == "Not Found") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.error,
                          content: Text(
                            'Extract Info first',
                            style: TextStyle(color: AppColors.text),
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      print('Neww');
                      Get.defaultDialog(
                        backgroundColor: AppColors.buttonBackground,
                        title: "Confirm Save",
                        middleText: "Are you sure to save data?",
                        textConfirm: "Yes",
                        confirmTextColor: AppColors.success,
                        textCancel: "No",
                        cancelTextColor: AppColors.error,
                        onConfirm: () {
                          final resumes = widget.controller.userAccount.resumes;

                          if (resumes.length >= 5) {
                            Get.defaultDialog(
                              backgroundColor: AppColors.error,
                              title: "Limit Exceeded",
                              middleText:
                                  "Only 5 resumes can be saved. Do you want to replace the oldest one?",
                              textConfirm: "Yes",
                              textCancel: "No",
                              onConfirm: () {
                                resumes.removeAt(0); // Remove the oldest
                                resumes.add(widget.resume);
                                widget.controller.updateDoc(
                                  widget.controller.userAccount,
                                );
                                Get.back(); // Close the dialog
                                Get.back(); // Go back after saving
                              },
                              onCancel: () {},
                            );
                          } else {
                            resumes.add(widget.resume);
                            widget.controller.updateDoc(
                              widget.controller.userAccount,
                            );
                            Get.back(); // Go back after saving
                          }
                        },
                      );
                    }
                  },
                  child: Text(
                    "Save Data",
                    style: TextStyle(color: AppColors.text),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Button to fetch job roles
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: BorderSide(color: Colors.white, width: 1),
                  ),
                  backgroundColor: AppColors.buttonBackground,
                ),
                onPressed: () async {
                  if (widget.resume.skills.value == "Not Found" ||
                      widget.resume.skills.value == "No data" ||
                      widget.resume.skills.value.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.error,
                        content: Text(
                          'Extract Info first',
                          style: TextStyle(color: AppColors.text),
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    await roleUsingGemini();
                  }
                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                      jobLoading.value
                          ? Text(
                            "Getting...",
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : Text(
                            "Get Job Roles",
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),

              SizedBox(height: 20),

              // Displaying Suggested Job Roles
              if (widget.resume.jobRoles.isNotEmpty) ...[
                Center(
                  child: Text(
                    "🎯 Suggested Job Roles",
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Flexible(
                  child: Container(
                    width: double.maxFinite,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.container,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child:
                        jobLoading.value
                            ? Center(
                              child: CircularProgressIndicator(
                                color: AppColors.indicator,
                              ),
                            )
                            : SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  ...widget.resume.jobRoles.map(
                                    (role) => TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: AppColors.text,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                          side: BorderSide(
                                            color: AppColors.success,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => JobListScreen(
                                                  searchQuery:
                                                      widget
                                                              .resume
                                                              .jobRoles
                                                              .isEmpty
                                                          ? "software engineer"
                                                          : role,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "- $role",
                                        style: TextStyle(
                                          color: AppColors.buttonBackground,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Widget myDrawer(LoginController controller) {
  return Drawer(
    backgroundColor: Colors.black.withOpacity(0.8),
    child: ListView(
      children: [
        Obx(
          () => UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppColors.drawer),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child:
                  controller.userAccount.profilePicture.value.isNotEmpty
                      ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: controller.userAccount.profilePicture.value,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) =>
                                  CircularProgressIndicator(strokeWidth: 2),
                          errorWidget:
                              (context, url, error) => Image.asset(
                                'assets/profile_placeholder.jpg',
                                fit: BoxFit.cover,
                              ),
                        ),
                      )
                      : ClipOval(
                        child: Image.asset(
                          'assets/profile_placeholder.jpg',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
            ),
            accountName: Text(
              controller.userAccount.name.value,
              style: TextStyle(
                color: AppColors.blackText,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              controller.userAccount.email.value,
              style: TextStyle(color: AppColors.blackText, fontSize: 16),
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text('My Account'),
          onTap: () {
            Get.to(() => MyAccountScreen());
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('My Scans'),
          onTap: () {
            Get.to(() => ResumeScansScreen());
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.work),
          title: Text('Jobs'),
          onTap: () {
            Get.to(() => JobListScreen(searchQuery: "Software Engineer"));
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('Logout'),
          onTap: () {
            Get.defaultDialog(
              backgroundColor: AppColors.scaffold,
              title: "Confirm Logout",
              middleText: "Are you sure you want to log out?",
              textConfirm: "Yes",
              textCancel: "No",
              onConfirm: () {
                controller.signOut();
                Get.offAll(LoginScreen());
              },
            );
          },
        ),
      ],
    ),
  );
}

Widget paresInfo(RxBool isLoading, ResumeParserScreen widget) {
  return Flexible(
    child: Obx(
      () => Container(
        width: double.maxFinite,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.container,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child:
            isLoading.value
                ? Center(
                  child: CircularProgressIndicator(color: AppColors.indicator),
                )
                : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "🤵🏻 Name:\n",
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: widget.resume.name.value,
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "\n📧 Email:\n",
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: widget.resume.email.value,
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "\n📞 Phone:\n",
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: widget.resume.phone.value,
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "\n🛠️ Skills:\n",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.text,
                              ),
                            ),
                            TextSpan(
                              text: widget.resume.skills.value,
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "\n🎓 Education:\n",
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: widget.resume.education.value,
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "\n💼 Projects:\n",
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: widget.resume.projects.value,
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    ),
  );
}
