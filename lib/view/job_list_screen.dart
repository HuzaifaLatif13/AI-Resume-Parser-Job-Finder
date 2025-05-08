import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:parser/const/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'job_details_screen.dart';

class JobListScreen extends StatefulWidget {
  String searchQuery;

  JobListScreen({super.key, required this.searchQuery});

  @override
  _JobListScreenState createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  List jobs = [];
  bool isLoading = false;
  bool isError = false;
  String jobType = "";
  String location = "Pakistan";
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  Future<void> fetchJobs({bool loadMore = false}) async {
    if (loadMore) {
      currentPage++;
    } else {
      currentPage = 1;
      jobs.clear();
    }

    setState(() {
      isLoading = true;
      isError = false;
    });
    final API_KEY = '6e946ad07amshdf2a8fa7c53c3d2p162825jsnf51f72ac9c25';
    // final API_KEY = '2ba0628913mshba893feccba5faep1dfaf6jsn66c58f2c64c9';
    // final API_KEY = 'bddc4b1903msh9c858829b644892p132bf1jsnc770a5458e0d';
    final searchQuery = widget.searchQuery;
    // final url = Uri.parse(
    //   'https://jobs-api14.p.rapidapi.com/v2/list?query=$searchQuery&location=$location&autoTranslateLocation=true&remoteOnly=false&employmentTypes=fulltime%3Bparttime%3Bintern%3Bcontractor',
    // );
    final url = Uri.parse(
      'https://linkedin-job-search-api.p.rapidapi.com/active-jb-7d?limit=10&offset=0&title_filter=%22$searchQuery%22&location_filter=%22lahore%22',
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
        print('yes');
        final decodedResponse = json.decode(response.body);
        print(decodedResponse); // Check the structure

        final List<dynamic> newJobs = decodedResponse;

        final Set<String> existingJobIds =
            jobs.map((job) => job['id'].toString()).toSet();

        final List<dynamic> filteredJobs =
            newJobs
                .where((job) => !existingJobIds.contains(job['id'].toString()))
                .toList();

        setState(() {
          jobs.addAll(filteredJobs);
          isLoading = false;
        });

        await saveJobs(jobs, searchQuery: searchQuery);
      }
    } catch (e) {
      print('Error: $e');
      await loadJobs(); // Load cached jobs if an error occurs
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  Future<void> saveJobs(
    List<dynamic> newJobs, {
    String searchQuery = "software engineer",
  }) async {
    print('Saving Jobs to Memory');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Load existing jobs
    String? existingJobsJSON = prefs.getString('savedJobs');
    List<dynamic> existingJobs =
        existingJobsJSON != null ? jsonDecode(existingJobsJSON) : [];
    // Append new jobs while avoiding duplicates
    for (var job in newJobs) {
      print('\t\t\t\tsaving...');
      if (!existingJobs.any((existingJob) => existingJob['id'] == job['id'])) {
        existingJobs.add(job);
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
      }
    }
    // Save updated job list
    final String updatedJobsJSON = jsonEncode(existingJobs);
    await prefs.setString('savedJobs', updatedJobsJSON);
    print('Updated Memory Saved Jobs: $updatedJobsJSON');
  }

  Future<void> loadJobs() async {
    print('Loading Jobs from Memory');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jobsJSON = prefs.getString('savedJobs');

    if (jobsJSON != null) {
      final List<dynamic> jobsList = jsonDecode(jobsJSON);
      setState(() {
        jobs = jobsList; // Update state with cached jobs
        print('Loaded Jobs: $jobs');
      });
      print('Loaded Jobs: $jobsList');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.scaffold,
        title: Text('Jobs Listing', style: TextStyle(color: AppColors.text)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Search Bar with Rounded Design
            TextField(
              decoration: InputDecoration(
                hintText: widget.searchQuery,
                hintStyle: TextStyle(color: AppColors.hintText),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.greenAccent, width: 2.0),
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.text),
              ),
              onChanged: (value) {
                setState(() {
                  widget.searchQuery = value;
                });
                fetchJobs();
              },
            ),

            SizedBox(height: 10),

            // Button with Full Width
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: AppColors.success, width: 1),
                  ),
                  backgroundColor: AppColors.buttonBackground,
                ),
                onPressed: fetchJobs,
                child: Text(
                  "See results",
                  style: TextStyle(color: AppColors.text, fontSize: 16),
                ),
              ),
            ),

            SizedBox(height: 15),

            Expanded(
              child:
                  isLoading
                      ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.indicator,
                        ),
                      )
                      : jobs.isEmpty
                      ? Center(
                        child: Column(
                          spacing: 20,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.text,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Lottie.asset(
                                'assets/broke.json',
                                width: 150,
                                height: 150,
                                fit: BoxFit.fill,
                              ),
                            ),
                            Text(
                              "Seems like, something broke on our side.",
                              style: TextStyle(color: AppColors.text),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: jobs.length,
                        itemBuilder: (context, index) {
                          final job = jobs[index];
                          return Card(
                            color: AppColors.buttonBackground,
                            margin: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                job['title'] ?? 'No Title',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Text(
                                job['organization'] ?? 'Unknown Company',
                                style: TextStyle(fontSize: 14),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black54,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => JobDetailScreen(job: job),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
