import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FirebaseService {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addDare(String dareText, int severity) async {
    try {
      await _firestore.collection('dares').add({
        'dare': dareText,
        'severity': severity,
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });
    } catch (e) {
      print('Error adding dare: $e');
      throw e; // Rethrow the exception to handle it elsewhere if needed
    }
  }

  static Future<void> addAct(String actText, int severity) async {
    try {
      await _firestore.collection('acts').add({
        'act': actText,
        'severity': severity,
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });
    } catch (e) {
      print('Error adding dare: $e');
      throw e; // Rethrow the exception to handle it elsewhere if needed
    }
  }
}
