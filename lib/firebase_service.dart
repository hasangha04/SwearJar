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
      print('Error adding act: $e');
      throw e; // Rethrow the exception to handle it elsewhere if needed
    }
  }

  static Future<void> updateUserJarData(int counter, int moneyInCents) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'counter': counter,
          'moneyInCents': moneyInCents,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error updating jar data: $e');
      throw e; // Rethrow the exception to handle it elsewhere if needed
    }
  }

  static Future<Map<String, dynamic>?> getUserJarData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      print('Error getting jar data: $e');
      throw e; // Rethrow the exception to handle it elsewhere if needed
    }
  }
}
