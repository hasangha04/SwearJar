import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addDare(String dare, int severity) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String displayName = await getUserDisplayName(user.uid);
      String? gameId = await getUserGameId();

      await _firestore.collection('dares').add({
        'dare': dare,
        'severity': severity,
        'displayName': displayName,
        'gameId': gameId,
      });
    }
  }

  static Future<void> addAct(String act, int severity) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String displayName = await getUserDisplayName(user.uid);
      String? gameId = await getUserGameId();

      await _firestore.collection('acts').add({
        'act': act,
        'severity': severity,
        'displayName': displayName,
        'gameId': gameId,
      });
    }
  }

  static Future<String> getUserDisplayName(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.exists ? userDoc['displayName'] ?? 'Anonymous' : 'Anonymous';
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
      rethrow; // Rethrow the exception to handle it elsewhere if needed
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
      rethrow; // Rethrow the exception to handle it elsewhere if needed
    }
  }

  static Future<List<Map<String, dynamic>>> getUsersJarData(String gameId) async {
    try {
      List<Map<String, dynamic>> usersData = [];
      // Query the users collection where gameId matches
      QuerySnapshot querySnapshot = await _firestore.collection('users').where('gameId', isEqualTo: gameId).get();

      // Iterate over the documents and extract jar data for each user
      querySnapshot.docs.forEach((userDoc) {
        Map<String, dynamic> userData = {
          'displayName': userDoc['displayName'] ?? 'Anonymous',
          'counter': userDoc['counter'] ?? 0,
          'moneyInCents': userDoc['moneyInCents'] ?? 0,
        };
        usersData.add(userData);
      });

      return usersData;
    } catch (e) {
      print('Error getting users jar data: $e');
      throw e;
    }
  }

  static Future<void> updateUserDisplayName(String displayName) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'displayName': displayName,
      }, SetOptions(merge: true));
    }
  }

  static Future<void> initializeUserData(User user) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      await _firestore.collection('users').doc(user.uid).set({
        'counter': 0,
        'moneyInCents': 0,
        'displayName': user.displayName ?? 'Anonymous',
      });
      await createGame();
    }
  }

  // Generate a 4-character uppercase game ID
  static String _generateGameId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rand = Random();
    return String.fromCharCodes(Iterable.generate(4, (_) => chars.codeUnitAt(rand.nextInt(chars.length))));
  }

  // Check if a game ID already exists
  static Future<bool> _gameIdExists(String gameId) async {
    final querySnapshot = await _firestore.collection('games').doc(gameId).get();
    return querySnapshot.exists;
  }

  // Create a new game with a unique 4-character uppercase game ID
  static Future<String> createGame() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String gameId;
      bool exists;
      do {
        gameId = _generateGameId();
        exists = await _gameIdExists(gameId);
      } while (exists);

      await _firestore.collection('games').doc(gameId).set({
        'users': [user.uid],
        'gameId': gameId,
      });

      await _firestore.collection('users').doc(user.uid).set({
        'gameId': gameId,
      }, SetOptions(merge: true));

      return gameId;
    }
    throw Exception('User not authenticated');
  }

  static Future<void> joinGame(String gameId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference gameRef = _firestore.collection('games').doc(gameId);
      DocumentSnapshot gameDoc = await gameRef.get();

      if (gameDoc.exists) {
        await gameRef.update({
          'users': FieldValue.arrayUnion([user.uid]),
        });

        // Update the user's document with the new game ID
        await _firestore.collection('users').doc(user.uid).set({
          'gameId': gameId,
        }, SetOptions(merge: true));
      } else {
        throw Exception('Game not found');
      }
    }
    throw Exception('User not authenticated');
  }

  static Future<Map<String, dynamic>?> getGameData(String gameId) async {
    DocumentSnapshot gameDoc = await _firestore.collection('games').doc(gameId).get();
    return gameDoc.data() as Map<String, dynamic>?;
  }

  static Future<String?> getUserGameId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc['gameId'] as String?;
    }
    return null;
  }
}
