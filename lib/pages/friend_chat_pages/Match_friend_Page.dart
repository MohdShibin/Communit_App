import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_app/models/user_model.dart';
import 'package:community_app/pages/friend_chat_pages/friend_chat_page.dart';
import 'package:community_app/services/match_making.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class MatchFriendPage extends StatefulWidget {
  @override
  _MatchFriendPageState createState() => _MatchFriendPageState();
}

class _MatchFriendPageState extends State<MatchFriendPage>
    with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<Map<String, dynamic>?> getSpecificUser(UserModel userModel) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? currentUser = _auth.currentUser;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    print("Getting matched user data ----------------\n\n");

    final doc = await _firestore.collection('users').doc(userModel.uid).get();
    final map = doc.data();
    return map;

    // UserModel user = UserModel(
    //     email: doc['email'], uid: doc['uid'], interest: doc['interest']);

    // return user;
  }

  void onButtonPressed() async {
    setState(() {
      isLoading = true;
    });

    UserModel matchedUser = await mainMatch();
    //TODO get specific user info
    final map = await getSpecificUser(matchedUser);

    setState(() {
      userMap = map;
    });

    setState(() {
      isLoading = false;
    });
  }

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    List communityListMap = [];
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('groups')
        .get()
        .then((value) {
      communityListMap = value.docs;
    });
    List communityList = [];
    String? matchedUser;

    if (communityListMap.isNotEmpty) {
      for (int i = 0; i < communityListMap.length; i++) {
        communityList.add(communityListMap[i]['id']);
      }
      List communityDataList = [];
      var friendMatchMap = Map();
      int matchedCount = 0;
      for (int i = 0; i < communityList.length; i++) {
        await _firestore.collection('groups').get().then((value) {
          communityDataList = value.docs;
        });
        for (int j = 0; j < communityDataList[i]['members'].length; j++) {
          String name = communityDataList[i]['members'][j]['name'];
          if (name != _auth.currentUser!.displayName) {
            if (!friendMatchMap.containsKey(name)) {
              friendMatchMap[name] = 1;
            } else {
              friendMatchMap[name] += 1;
            }
            if (friendMatchMap[name] > matchedCount) {
              matchedCount = friendMatchMap[name];
              matchedUser = name;
            }
          }
        }
      }
      //finding matched user

      await _firestore
          .collection('users')
          .where("name", isEqualTo: matchedUser)
          .get()
          .then((value) {
        setState(() {
          userMap = value.docs[0].data();
        });
        print(userMap);
      });
    } else {
      //TODO IF the user doesnt have any group.
    }

    setState(() {
      isLoading = false;
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
        title: const Text("Find Friend"),
        backgroundColor: Colors.black,
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
                SizedBox(
                  height: size.height / 50,
                ),
                ElevatedButton(
                  // onPressed: onSearch,
                  onPressed: () {
                    print("find match working..");
                    // mainMatch();
                    onButtonPressed();
                  },
                  child: const Text("F I N D"),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepOrangeAccent,
                  ),
                ),
                SizedBox(
                  height: size.height / 30,
                ),
                userMap != null
                    ? ListTile(
                        onTap: onTapToChat,
                        leading: const Icon(Icons.person, color: Colors.black),
                        title: Text(
                          userMap!['name'],
                          style: const TextStyle(
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
    );
  }
}
