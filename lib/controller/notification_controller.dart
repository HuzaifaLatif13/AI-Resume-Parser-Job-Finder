import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  User? user = FirebaseAuth.instance.currentUser;
  var NotificationCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCount();
  }

  void fetchCount() async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('user-notifications')
        .where('isSeen', isEqualTo: false)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
          NotificationCount.value = snapshot.docs.length;
          update();
        });
  }
}
