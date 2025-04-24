import 'package:get/get.dart';

class UserAccount {
  var id = ''.obs;
  var name = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var resumes = <Resume>[].obs;

  // Constructor
  UserAccount({
    String? id,
    String? name,
    String? email,
    String? password,
    List<Resume>? resumes,
  }) {
    this.id.value = id ?? '';
    this.name.value = name ?? '';
    this.email.value = email ?? '';
    this.password.value = password ?? '';
    if (resumes != null) {
      this.resumes.assignAll(resumes);
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id.value,
      'name': name.value,
      'email': email.value,
      'password': password.value,
      'resumes': resumes.map((resume) => resume.toJson()).toList(),
    };
  }

  // Convert from JSON
  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      resumes:
          (json['resumes'] as List<dynamic>?)
              ?.map((resume) => Resume.fromJson(resume))
              .toList() ??
          [],
    );
  }
}

class Resume {
  var name = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var skills = ''.obs;
  var education = ''.obs;
  var projects = ''.obs;
  var jobRoles = <String>[].obs;

  // Constructor
  Resume({
    String? name,
    String? email,
    String? phone,
    String? skills,
    String? education,
    String? projects,
    List<String>? jobRoles,
  }) {
    this.name.value = name ?? '';
    this.email.value = email ?? '';
    this.phone.value = phone ?? '';
    this.skills.value = skills ?? '';
    this.education.value = education ?? '';
    this.projects.value = projects ?? '';
    if (jobRoles != null) {
      this.jobRoles.assignAll(jobRoles);
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name.value,
      'email': email.value,
      'phone': phone.value,
      'skills': skills.value,
      'education': education.value,
      'projects': projects.value,
      'jobRoles': jobRoles.toList(),
    };
  }

  // Convert from JSON
  factory Resume.fromJson(Map<String, dynamic> json) {
    return Resume(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      skills: json['skills'],
      education: json['education'],
      projects: json['projects'],
      jobRoles:
          (json['jobRoles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
