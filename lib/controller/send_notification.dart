import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:parser/controller/service_key.dart';

class SendNotification {
  static Future<void> sendNotification({
    required String? token,
    required String? title,
    required String? body,
    required Map<String, dynamic>? data,
  }) async {
    String serverKey = await ServiceKey().getServiceKey();
    String url =
        'https://fcm.googleapis.com/v1/projects/resume-3cf51/messages:send';
    var header = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $serverKey',
    };
    Map<String, dynamic> message = {
      "message": {
        "token": token,
        "notification": {"body": body, "title": title},
        "data": data,
      },
    };

    //hit api
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: header,
      body: jsonEncode(message),
    );
    if (response.statusCode == 200) {
      print('Notification sent successfully');
      //save notification
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('user-notifications')
          .doc()
          .set({
            'title': title,
            'body': body,
            'data': data,
            'timestamp': FieldValue.serverTimestamp(),
            'isSeen': false,
          });
    } else {
      print('Failed to send notification: ${response.body}');
    }
  }
}
