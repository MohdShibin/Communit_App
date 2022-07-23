import 'package:flutter/material.dart';
import '../pages/friend_chat_pages/friend_chat_page.dart';

class FriendChatListItem extends StatelessWidget {
  final Map<String, dynamic>? userMap;
  String? chatRoomId;

  FriendChatListItem(
      {Key? key, @required this.chatRoomId, @required this.userMap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0,left: 4.0,right: 4.0),
      child: ListTile(
        leading: const CircleAvatar(
          maxRadius: 30,
          backgroundImage: AssetImage(
            'assets/user.png',
          ),
        ),
        title: Text(userMap!['name']),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FriendChatPage(
                chatRoomId: chatRoomId!,
                userMap: userMap!,
              ),
            ),
          );
        },
        tileColor: Color(0xffF0F4F5),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
