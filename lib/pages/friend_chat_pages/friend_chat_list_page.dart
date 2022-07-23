import 'package:flutter/material.dart';
import '../../components/community_chat_list_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../components/friend_chat_list_item.dart';

class FriendChatListPage extends StatefulWidget {
  const FriendChatListPage({
    Key? key,
  }) : super(key: key);

  @override
  State<FriendChatListPage> createState() => _FriendChatListPageState();
}

class _FriendChatListPageState extends State<FriendChatListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;

  List friendsList = [];
  List friendUserMap = [];

  @override
  void initState() {
    super.initState();
    getAvailableFriends();
  }

  void getAvailableFriends() async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('friend')
        .get()
        .then((value) {
      setState(() {
        friendsList = value.docs;
        isLoading = false;
      });
    });

    for (int i = 0; i < friendsList.length; i++) {
      await _firestore
          .collection('users')
          .where("uid", isEqualTo: friendsList[i]['id'])
          .get()
          .then((value) {
        setState(() {
          friendUserMap.add(value.docs[0].data());
          isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : ListView.builder(
            itemCount: friendUserMap.length,
            itemBuilder: (context, index) {
              return FriendChatListItem(
                chatRoomId: friendsList[index]['roomId'],
                userMap: friendUserMap[index],
              );
            });
  }
}


