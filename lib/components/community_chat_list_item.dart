import 'package:community_app/pages/community_pages/community_chat_page.dart';
import 'package:flutter/material.dart';

class CommunityChatListItem extends StatelessWidget {
  String? communityName;
  String? communityChatId;

  CommunityChatListItem(
      {Key? key, @required this.communityName, @required this.communityChatId})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0,left: 4.0,right: 4.0),
      child: ListTile(
        leading: const CircleAvatar(
          maxRadius: 30,
          backgroundImage: AssetImage(
            'assets/community.png',
          ),
        ),
        title: Text(communityName!),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CommunityChatPage(
                  communityName: communityName!, groupChatId: communityChatId!),
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
