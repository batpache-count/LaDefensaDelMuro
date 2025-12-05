import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if this is a new user
        final userDoc = await _firestore.collection('players').doc(user.uid).get();
        if (!userDoc.exists) {
          // New user, create a document for them
          await _firestore.collection('players').doc(user.uid).set({
            'displayName': user.displayName,
            'email': user.email,
            'photoURL': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return user;
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> savePlayerData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('players').doc(userId).set(data);
    } catch (e) {
      debugPrint('Error saving player data: $e');
    }
  }

  Future<DocumentSnapshot?> getPlayerData(String userId) async {
    try {
      return await _firestore.collection('players').doc(userId).get();
    } catch (e) {
      debugPrint('Error getting player data: $e');
      return null;
    }
  }
}
