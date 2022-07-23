import '../components/top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  String? name;
  String? email;
  void getCurrentUserDetails() async {
    var user =
        await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    setState(() {
      name = user['name'];
      email = user['email'];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: Container(
                height: size.height / 20,
                width: size.height / 20,
                child: CircularProgressIndicator(),
              ),
            ):SafeArea(
        child: Column(
          children: [
            TopAppBar(
              isIconLeft: true,
              OnChanged: () {
                Navigator.pop(context);
              },
              title: "Profile",
              icon: Icons.arrow_back,
            ),
            Container(
              height: size.height / 7,
              width: size.height / 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: size.width / 6,
              ),
            ),
            const SizedBox(
              height: 40.0,
            ),
            Text(
              'Name : $name',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            Text(
              'Email : $email',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
