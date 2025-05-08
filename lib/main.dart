import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:parser/splash_screen.dart';

import 'controller/notification_service.dart';
import 'controller/send_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await initializeService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Resume Builder',
      //dark theme
      theme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

Future<void> fetchAndNotifyLatestJobs(String searchQuery) async {
  final API_KEY = '6e946ad07amshdf2a8fa7c53c3d2p162825jsnf51f72ac9c25';
  final url = Uri.parse(
    'https://linkedin-job-search-api.p.rapidapi.com/active-jb-7d?limit=10&offset=0&title_filter=%22software%20engineer%22&location_filter=%22lahore%22',
  );

  try {
    final response = await http.get(
      url,
      headers: {
        'x-rapidapi-key': API_KEY,
        'x-rapidapi-host': 'linkedin-job-search-api.p.rapidapi.com',
      },
    );

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);

      if (decodedResponse is List && decodedResponse.isNotEmpty) {
        final List<dynamic> newJobs = decodedResponse;

        // Sort jobs by most recent posting time
        newJobs.sort((a, b) {
          final aDate =
              DateTime.tryParse(a['date_posted'] ?? '') ?? DateTime(2000);
          final bDate =
              DateTime.tryParse(b['date_posted'] ?? '') ?? DateTime(2000);
          return bDate.compareTo(aDate); // Descending order
        });

        // Save to Firebase (you can customize this logic)
        if (newJobs.isEmpty) {
          // Fetch all jobs in the collection
          final querySnapshot =
              await FirebaseFirestore.instance
                  .collection('jobs')
                  .doc('all-jobs')
                  .collection(searchQuery)
                  .get();

          if (querySnapshot.docs.isNotEmpty) {
            // Select a random job
            final randomIndex = Random().nextInt(querySnapshot.docs.length);
            final randomJobDoc = querySnapshot.docs[randomIndex];

            // Now `randomJobDoc.data()` contains the job data
            final job = randomJobDoc.data();

            // Do something with `job`
            print("Random job: $job");
          } else {
            print("No jobs found in collection.");
          }

          return;
        }

        final job = newJobs.first; // Only handle the latest job
        Map<String, dynamic> filteredJob = {
          'id': job['id'],
          'title': job['title'],
          'organization': job['organization'],
          'url': job['url'],
          'date_posted': job['date_posted'],
          'locations_derived': job['locations_derived'],
          'employment_type':
              (job['employment_type'] != null &&
                      job['employment_type'] is List &&
                      job['employment_type'].isNotEmpty)
                  ? job['employment_type'][0]
                  : null,
          'linkedin_org_description': job['linkedin_org_description'],
        };
        final docRef = FirebaseFirestore.instance
            .collection('jobs')
            .doc('all-jobs')
            .collection(searchQuery)
            .doc(filteredJob['id'].toString());

        // Check if job already exists
        final existingDoc = await docRef.get();

        if (existingDoc.exists) {
          print('Job already exists');
          // Update if exists
          await docRef.update(filteredJob);
        } else {
          print('New Job');
          // Create new if not exists
          await docRef.set(filteredJob);
        }

        // Send Notification
        final token = await NotificationService().getToken();
        print(
          '${job['organization']} - ${job['locations_derived']?[0] ?? 'Location not specified'}',
        );
        print(json.encode(job));

        await SendNotification.sendNotification(
          token: token,
          title: 'New Job: ${filteredJob['title']}',
          body:
              '${filteredJob['organization']} - ${filteredJob['locations_derived']?[0] ?? 'Location not specified'}',
          data: {'job': json.encode(filteredJob)}, // send as map
        );
      } else {
        throw Exception('Invalid API response structure');
      }
    } else {
      print('API Error: ${response.statusCode}');
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('jobs')
              .doc('all-jobs')
              .collection(searchQuery)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Select a random job
        final randomIndex = Random().nextInt(querySnapshot.docs.length);
        final randomJobDoc = querySnapshot.docs[randomIndex];

        // Now `randomJobDoc.data()` contains the job data
        final job = randomJobDoc.data();

        // Do something with `job`
        print("Random job: $job");
        // Send Notification
        final token = await NotificationService().getToken();
        print(
          '${job['organization']} - ${job['locations_derived']?[0] ?? 'Location not specified'}',
        );
        print(json.encode(job));
        Map<String, dynamic> filteredJob = {
          'id': job['id'],
          'title': job['title'],
          'organization': job['organization'],
          'url': job['url'],
          'date_posted': job['date_posted'],
          'locations_derived': job['locations_derived'],
          'employment_type':
              (job['employment_type'] != null &&
                      job['employment_type'] is List &&
                      job['employment_type'].isNotEmpty)
                  ? job['employment_type'][0]
                  : null,
          'linkedin_org_description': job['linkedin_org_description'],
        };
        await SendNotification.sendNotification(
          token: token,
          title: 'New Job: ${filteredJob['title']}',
          body:
              '${filteredJob['organization']} - ${filteredJob['locations_derived']?[0] ?? 'Location not specified'}',
          data: {'job': json.encode(filteredJob)}, // send as map
        );
      } else {
        print("No jobs found in collection.");
      }
      return;
      // throw Exception('Failed to fetch jobs');
    }
  } catch (e) {
    print('here Error: $e');
  }
}
