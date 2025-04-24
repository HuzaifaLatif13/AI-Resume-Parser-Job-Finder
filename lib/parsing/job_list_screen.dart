import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
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

    final searchQuery = widget.searchQuery;
    final url = Uri.parse(
      'https://jobs-api14.p.rapidapi.com/v2/list?query=$searchQuery&location=$location&autoTranslateLocation=true&remoteOnly=false&employmentTypes=fulltime%3Bparttime%3Bintern%3Bcontractor',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'x-rapidapi-key':
              'YOUR-API-KEY',
          'x-rapidapi-host': 'jobs-api14.p.rapidapi.com',
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse.containsKey('jobs')) {
          final List<dynamic> newJobs = decodedResponse['jobs'];

          // Use a Set to remove duplicates based on job ID
          final Set<String> existingJobIds =
              jobs.map((job) => job['id'].toString()).toSet();
          final List<dynamic> filteredJobs =
              newJobs
                  .where(
                    (job) => !existingJobIds.contains(job['id'].toString()),
                  )
                  .toList();

          setState(() {
            jobs.addAll(filteredJobs);
            isLoading = false;
          });

          await saveJobs(jobs);
        } else {
          throw Exception('Invalid API response');
        }
      } else {
        print('API Response Code: ${response.statusCode}');
        await loadJobs(); // Load cached jobs if API fails
        throw Exception('Failed to load jobs');
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

  Future<void> saveJobs(List<dynamic> newJobs) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Load existing jobs
    String? existingJobsJSON = prefs.getString('savedJobs');
    List<dynamic> existingJobs =
        existingJobsJSON != null ? jsonDecode(existingJobsJSON) : [];
    // Append new jobs while avoiding duplicates
    for (var job in newJobs) {
      if (!existingJobs.any((existingJob) => existingJob['id'] == job['id'])) {
        existingJobs.add(job);
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

  void openFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Apply Filters",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Job Type",
                      ),
                      value: jobType.isEmpty ? null : jobType,
                      items:
                          ["", "onsite", "remote", "hybrid"].map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.isEmpty ? "All" : type),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          jobType = value ?? "";
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        fetchJobs();
                      },
                      child: Text("Apply Filters"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color getRandomColor() {
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
    ];
    return colors[Random().nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Jobs Listing',
          style: TextStyle(color: Colors.greenAccent, fontSize: 22),
        ),
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
                hintStyle: TextStyle(
                  color: Colors.amberAccent.withOpacity(0.6),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.greenAccent, width: 2.0),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.greenAccent),
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
                    side: BorderSide(color: Colors.amber, width: 1),
                  ),
                  backgroundColor: Colors.brown.withOpacity(0.9),
                ),
                onPressed: fetchJobs,
                child: Text(
                  "See results",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            SizedBox(height: 15),

            // Job List with Random Colors
            Expanded(
              child:
                  isLoading
                      ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.greenAccent,
                        ),
                      )
                      // : isError
                      // ? Center(
                      //   child: Text(
                      //     "Failed to load jobs. Please try again.",
                      //     style: TextStyle(color: Colors.redAccent),
                      //   ),
                      // )
                      : jobs.isEmpty
                      ? Center(
                        child: Column(
                          spacing: 20,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: jobs.length,
                        itemBuilder: (context, index) {
                          final job = jobs[index];
                          return Card(
                            color: getRandomColor(),
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
                                job['company'] ?? 'Unknown Company',
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
