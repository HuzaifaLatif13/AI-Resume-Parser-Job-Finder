import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:parser/const/colors.dart';
import 'package:parser/view/job_details_screen.dart';

class NotificationScreen extends StatefulWidget {
  final RemoteMessage? message;

  const NotificationScreen({super.key, this.message});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: AppColors.scaffold,
      ),
      body: FutureBuilder(
        future:
            FirebaseFirestore.instance
                .collection('notifications')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('user-notifications')
                .get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Notifications Yet.'));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('All Notifications', style: TextStyle(fontSize: 16)),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.scaffold,
                      ),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('notifications')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('user-notifications')
                            .where('isSeen', isEqualTo: false)
                            .get()
                            .then((QuerySnapshot snapshot) {
                              for (var doc in snapshot.docs) {
                                doc.reference.update({'isSeen': true});
                              }
                            });
                        setState(() {});
                      },
                      child: Text(
                        'Mark all as read',
                        style: TextStyle(color: AppColors.text),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      String docId = snapshot.data!.docs[index].id;
                      return GestureDetector(
                        onTap: () async {
                          await FirebaseFirestore.instance
                              .collection('notifications')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('user-notifications')
                              .doc(docId)
                              .update({'isSeen': true});
                          setState(() {});
                          if (snapshot.data!.docs[index]['data']['job']
                              .toString()
                              .isNotEmpty) {
                            final String jobString =
                                snapshot.data!.docs[index]['data']['job'];
                            var job = jsonDecode(jobString);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JobDetailScreen(job: job),
                              ),
                            );
                          }
                        },
                        child: Card(
                          color: AppColors.container,
                          elevation:
                              snapshot.data!.docs[index]['isSeen'] ? 0 : 5,
                          shadowColor: AppColors.scaffold,
                          child: ListTile(
                            leading:
                                snapshot.data!.docs[index]['isSeen']
                                    ? const Icon(
                                      Icons.notifications_none_rounded,
                                    )
                                    : const Icon(Icons.notifications_active),
                            title: Text(snapshot.data!.docs[index]['title']),
                            subtitle: Text(snapshot.data!.docs[index]['body']),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
