import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailScreen extends StatelessWidget {
  final Map job;

  const JobDetailScreen({super.key, required this.job});

  Future<void> _launchURL() async {
    final String? url =
        job['jobProviders'][0]['url']; // Access first job provider's URL
    print(url);
    if (url != null && url.isNotEmpty) {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      debugPrint("No valid URL found.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Job Details',
          style: TextStyle(color: Colors.greenAccent, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  job['title'] ?? 'No Title',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _launchURL,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Apply Now",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "📛 Company:\n",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '${job['company'] ?? 'Unknown'}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    TextSpan(text: '\n\n'), // Add spacing
                    TextSpan(
                      text: '📍 Location:\n',
                      style: TextStyle(
                        color: Colors.blue, // Blue color for the heading
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text:
                          '${job['location'] ?? 'Unknown'}, ${job['job_country'] ?? ''}',
                      style: TextStyle(
                        color: Colors.white, // Default text color
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(text: '\n\n'), // Add spacing
                    // Job Type Section
                    TextSpan(
                      text: '💼 Job Type:\n',
                      style: TextStyle(
                        color: Colors.green, // Green color for the heading
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: '${job['employmentType'] ?? 'N/A'}',
                      style: TextStyle(
                        color: Colors.white, // Default text color
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(text: '\n\n'), // Add spacing
                    // Description Section
                    TextSpan(
                      text: '📝 Description:\n',
                      style: TextStyle(
                        color: Colors.purple, // Purple color for the heading
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text:
                          '${job['description'] ?? 'No description available.'}',
                      style: TextStyle(
                        color: Colors.white, // Default text color
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
