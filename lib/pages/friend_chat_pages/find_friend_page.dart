import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_app/pages/friend_chat_pages/friend_chat_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class FindFriendPage extends StatefulWidget {
  @override
  _FindFriendPageState createState() => _FindFriendPageState();
}

class _FindFriendPageState extends State<FindFriendPage>
    with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    setStatus("Online");
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else {
      // offline
      setStatus("Offline");
    }
  }

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("email", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  void onTapToChat() async {
    //Creating a temperary roomID
    var roomId = Uuid().v1();


    String uid = _auth.currentUser!.uid;
    bool isExistingRoom = false;
    List roomsList = [];
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('friend')
        .get()
        .then((value) {
      roomsList = value.docs;
    });
    //checking whether there exist chatRoom between these two users
    if (roomsList.isNotEmpty) {
      for (int i = 0; i < roomsList.length; i++) {
        if (roomsList[i]['name'] == userMap!['name']) {
          roomId = roomsList[i]['roomId'];
          isExistingRoom = true;
          break;
        }
      }
    }
    //If there is not exit a chatroom between these two users.createing one.
    if (isExistingRoom == false) {
      await _firestore.collection('chatroom').doc(roomId).set({
        "user1": _auth.currentUser!.displayName!,
        "user2": userMap!['name'],
      });
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('friend')
          .doc(roomId)
          .set({
        "name": userMap!['name'],
        "id": userMap!['uid'],
        "roomId": roomId,
      });

      await _firestore
          .collection('users')
          .doc(userMap!['uid'])
          .collection('friend')
          .doc(roomId)
          .set({
        "name": _auth.currentUser!.displayName!,
        "id": _auth.currentUser!.uid,
        "roomId": roomId,
      });
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FriendChatPage(
          chatRoomId: roomId,
          userMap: userMap!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Find Friend"),
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
                        hintText: "Search",
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
                  child: Text("Search"),
                ),
                SizedBox(
                  height: size.height / 30,
                ),
                userMap != null
                    ? ListTile(
                        onTap: onTapToChat,
                        leading: Icon(Icons.person, color: Colors.black),
                        title: Text(
                          userMap!['name'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(userMap!['email']),
                      )
                    : Container(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.forward),
        onPressed: () {},
      ),
    );
  }
}
