import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_app/pages/friend_chat_pages/friend_chat_page.dart';
import 'package:community_app/pages/home_page.dart';
import 'package:community_app/pages/search_friend.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SearchCommunity extends StatefulWidget {
  @override
  _SearchCommunityState createState() => _SearchCommunityState();
}

class _SearchCommunityState extends State<SearchCommunity> {

  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? communityMap;
  Map<String, dynamic>? CurrentUserMap;
  List membersList = [];
  bool isLoading = false;

  void getCurrentUserMap() {
    CurrentUserMap ={'email':_auth.currentUser!.email,'name':_auth.currentUser!.displayName,'uid':_auth.currentUser!.uid,'isAdmin':false};
  }

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('groups')
        .where("name", isGreaterThanOrEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        communityMap = value.docs[0].data();
        isLoading = false;
      });
      //print(communityMap);
    });
    getCurrentUserMap();
  }

  void onTap() async {
      await _firestore
          .collection('groups')
          .doc(communityMap!['id'])
          .get()
          .then((chatMap) {
        membersList = chatMap['members'];
      });
    membersList.add(CurrentUserMap);

    await _firestore.collection('groups').doc(communityMap!['id']).update({
      "members": membersList,
    });

    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('groups')
        .doc(communityMap!['id'])
        .set({"name": communityMap!['name'], "id": communityMap!['id']});
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const HomePage()
    ));

  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Community"),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: (){
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const HomePage()
            ));
          },
        ),
      ),
      body: isLoading
          ? Center(
        child: Container(
          height: size.height / 20,
          width: size.height / 20,
          child: CircularProgressIndicator(),
        ),
      )
          : Column(
        children: [
          SizedBox(
            height: size.height / 20,
          ),
          Container(
            height: size.height / 14,
            width: size.width,
            alignment: Alignment.center,
            child: Container(
              height: size.height / 14,
              width: size.width / 1.15,
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: "Search Community",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: size.height / 50,
          ),
          ElevatedButton(
            onPressed: onSearch,
            child: const Text("Search"),
            style: ElevatedButton.styleFrom(
              primary: Colors.deepOrangeAccent,
            ),
          ),
          SizedBox(
            height: size.height / 30,
          ),
          communityMap != null
              ? ListTile(
            tileColor: const Color(0xffF0F4F5),
            leading: const Icon(Icons.person, color: Colors.black),
            title: Text(
              communityMap!['name'],
              style: const TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: OutlinedButton(
              onPressed: onTap,
              child: const Text('JOIN',style: TextStyle(color: Colors.deepOrangeAccent)),
            ),
          )
              : Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => SearchFriend()
          ));
        },
        child: const Icon(Icons.person_add_alt_1_rounded),
        backgroundColor: Colors.black,
      ),
    );
  }
}

