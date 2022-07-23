import 'package:flutter/material.dart';
import '../../components/community_chat_list_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupChatListItems extends StatefulWidget {
  const GroupChatListItems({
    Key? key,
  }) : super(key: key);

  @override
  State<GroupChatListItems> createState() => _GroupChatListItemsState();
}

class _GroupChatListItemsState extends State<GroupChatListItems> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;

  List communityList = [];

  @override
  void initState() {
    super.initState();
    getAvailableGroups();
  }

  void getAvailableGroups() async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('groups')
        .get()
        .then((value) {
      setState(() {
        communityList = value.docs;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Flexible(
            child: ListView.builder(
                itemCount: communityList.length,
                itemBuilder: (context, index) {
                  return CommunityChatListItem(
                      communityName: communityList[index]['name'],
                      communityChatId: communityList[index]['id']);
                }),
          );
  }
}
