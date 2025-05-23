import 'package:flutter/material.dart';
import 'package:parser/const/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailScreen extends StatelessWidget {
  final Map<String, dynamic> job;

  JobDetailScreen({super.key, required this.job});

  Future<void> _launchURL() async {
    final String? url = job['url']; // Access first job provider's URL
    print(url);
    if (url != null && url.isNotEmpty) {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      debugPrint("No valid URL found.");
    }
  }

  @override
  Widget build(BuildContext context) {
    print('job details screen: \n\t\t\t$job');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.scaffold,
        title: Text(
          'Job Details',
          style: TextStyle(color: AppColors.text, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job['title'] ?? 'No Title',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _launchURL,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Apply Now",
                    style: TextStyle(color: AppColors.text, fontSize: 20),
                  ),
                ),
              ),
              SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "⏱️ Posted Time:\n",
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '${job['date_posted'] ?? 'Unknown'}',
                      style: TextStyle(color: AppColors.text, fontSize: 16),
                    ),
                    TextSpan(text: '\n\n'), // Add spacing
                    TextSpan(
                      text: "📛 Company:\n",
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '${job['organization'] ?? 'Unknown'}',
                      style: TextStyle(color: AppColors.text, fontSize: 16),
                    ),
                    TextSpan(text: '\n\n'), // Add spacing
                    TextSpan(
                      text: '📍 Location:\n',
                      style: TextStyle(
                        color: AppColors.text, // Blue color for the heading
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text:
                          '${job['locations_derived'] ?? 'Unknown'}, ${job['job_country'] ?? ''}',
                      style: TextStyle(
                        color: AppColors.text, // Default text color
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(text: '\n\n'), // Add spacing
                    // Job Type Section
                    TextSpan(
                      text: '💼 Job Type:\n',
                      style: TextStyle(
                        color: AppColors.text, // Green color for the heading
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text:
                          '${(job['employment_type'] is List && job['employment_type'].isNotEmpty) ? job['employment_type'][0] : 'N/A'}',
                      style: TextStyle(
                        color: AppColors.text, // Default text color
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(text: '\n\n'), // Add spacing
                    // Description Section
                    TextSpan(
                      text: '📝 Description:\n',
                      style: TextStyle(
                        color: AppColors.text, // Purple color for the heading
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text:
                          '${job['linkedin_org_description'] ?? 'No description available.'}',
                      style: TextStyle(
                        color: AppColors.text, // Default text color
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
