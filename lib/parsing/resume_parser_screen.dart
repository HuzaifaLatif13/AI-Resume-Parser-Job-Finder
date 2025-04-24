import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:parser/controller/login_controller.dart';
import 'package:parser/modals/user.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../auth/login_screen.dart';
import 'job_list_screen.dart';

class ResumeParserScreen extends StatefulWidget {
  final LoginController controller = Get.find<LoginController>();

  ResumeParserScreen({super.key});

  @override
  _ResumeParserScreenState createState() => _ResumeParserScreenState();
}

class _ResumeParserScreenState extends State<ResumeParserScreen> {
  var isLoading = false.obs;
  var jobLoading = false.obs;

  var extractedText = "No text extracted yet.".obs;
  Resume resume = Resume();

  final String apiKey =
      "YOUR-GEMINI-KEY"; // Replace with your Google Gemini API Key

  Future<void> pickAndExtractText() async {
    isLoading.value = true;
    resume.name.value = "Not Found";
    resume.email.value = "Not Found";
    resume.phone.value = "Not Found";
    resume.skills.value = "Not Found";
    resume.education.value = "Not Found";
    resume.projects.value = "Not Found";
    resume.jobRoles.clear();

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

    if (response.containsKey("name")) resume.name.value = response["name"];
    if (response.containsKey("email")) resume.email.value = response["email"];
    if (response.containsKey("phone")) resume.phone.value = response["phone"];
    if (response.containsKey("skills")) {
      resume.skills.value = response["skills"].join(", ");
    }
    if (response.containsKey("education"))
      resume.education.value = response["education"];

    if (response.containsKey("projects")) {
      resume.projects.value = response["projects"]
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
Based on the following skills, education, and projects, suggest top 3 most relevant job roles. Provide both general roles (e.g., Web Developer, App Developer, UI/UX Designer) and specific roles (e.g., MERN Stack Developer, Flutter Developer, React Native Developer). 

### Skills:
$resume.skills

### Education:
$resume.education

### Projects:
$resume.projects

Return the response in **JSON format**, containing only a list of job roles:
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
              resume.jobRoles.assignAll(
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.blue.withOpacity(0.3),
        title: Text(
          'AI Resume Parser',
          style: TextStyle(color: Colors.greenAccent),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.3)),
              accountName: Text(widget.controller.userAccount!.name.value),
              accountEmail: Text(widget.controller.userAccount!.email.value),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('My Account'),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Profile'),
              onTap: () {
                Get.to(ResumeParserScreen());
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                widget.controller.signOut();
                Get.offAll(LoginScreen());
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Welcome, ",
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  TextSpan(
                    text: "${widget.controller.userAccount!.name.value} 😊",
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent.withOpacity(0.3),
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
                  style: TextStyle(color: Colors.redAccent, fontSize: 20),
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
                backgroundColor: Colors.blueGrey.withOpacity(0.9),
              ),
              onPressed: () async {
                await pickAndExtractText();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Pick & Parse Resume",
                  style: TextStyle(
                    color: Colors.orange,
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
                  color: Colors.blueAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),

            // Scrollable section for extracted details
            Flexible(
              child: Obx(
                () => Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child:
                      isLoading.value
                          ? Center(
                            child: CircularProgressIndicator(
                              color: Colors.deepOrangeAccent,
                            ),
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
                                        text: "📛 Name:\n",
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      TextSpan(
                                        text: resume.name.value,
                                        style: TextStyle(
                                          color: Colors.white,
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
                                          color: Colors.purpleAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      TextSpan(
                                        text: resume.email.value,
                                        style: TextStyle(
                                          color: Colors.white,
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
                                          color: Colors.limeAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      TextSpan(
                                        text: resume.phone.value,
                                        style: TextStyle(
                                          color: Colors.white,
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
                                          color: Colors.tealAccent,
                                        ),
                                      ),
                                      TextSpan(
                                        text: resume.skills.value,
                                        style: TextStyle(
                                          color: Colors.white,
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
                                          color: Colors.amberAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      TextSpan(
                                        text: resume.education.value,
                                        style: TextStyle(
                                          color: Colors.white,
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
                                          color: Colors.pinkAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      TextSpan(
                                        text: resume.projects.value,
                                        style: TextStyle(
                                          color: Colors.white,
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
            ),

            SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  widget.controller.userAccount?.resumes.add(resume);
                  widget.controller.updateDoc(widget.controller.userAccount!);
                },
                child: Text("Save Data", style: TextStyle(color: Colors.blue)),
              ),
            ),
            SizedBox(height: 20),

            // Button to fetch job roles
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                //border
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                  side: BorderSide(color: Colors.white, width: 1),
                ),
                backgroundColor: Colors.yellow.withOpacity(0.9),
              ),
              onPressed: () async {
                if (resume.skills.value == "Not Found") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text(
                        'Extract Info first',
                        style: TextStyle(color: Colors.white),
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
                child: Text(
                  "Get Job Roles",
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Displaying Suggested Job Roles
            if (resume.jobRoles.isNotEmpty) ...[
              Center(
                child: Text(
                  "🎯 Suggested Job Roles",
                  style: TextStyle(
                    color: Colors.amberAccent,
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
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child:
                      jobLoading.value
                          ? Center(
                            child: CircularProgressIndicator(
                              color: Colors.deepPurpleAccent,
                            ),
                          )
                          : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                ...resume.jobRoles.map(
                                  (role) => TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.black45,
                                      backgroundColor: Colors.redAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                        side: BorderSide(
                                          color: Colors.greenAccent,
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
                                                    resume.jobRoles.isEmpty
                                                        ? "software engineer"
                                                        : role,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "- $role",
                                      style: TextStyle(color: Colors.white),
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
    );
  }
}
