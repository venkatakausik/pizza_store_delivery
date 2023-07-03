import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseServices {
  CollectionReference boys = FirebaseFirestore.instance.collection('boys');
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<DocumentSnapshot> validateUser(id) async {
    DocumentSnapshot result = await boys.doc(id).get();
    return result;
  }

  Future<DocumentSnapshot> getCustomerDetails(id) async {
    DocumentSnapshot doc = await users.doc(id).get();
    return doc;
  }

  Future<String> getToken() async {
    var deviceToken = '';
    await FirebaseMessaging.instance.getToken().then((value) {
      deviceToken = value!;
    });
    return deviceToken;
  }

  Future<void> updateUserDeviceToken({deviceToken}) async {
    User? user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('boys')
        .doc(user?.email)
        .update({"deviceToken": deviceToken});
  }
}
