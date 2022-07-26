import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// this returns the list of all users
Future<List> getAllUsers() async {
  List users = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;
  await _firestore.collection('users').get().then(
    (value) {
      users = value.docs;
    },
  );
  return users;
}
