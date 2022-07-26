import 'package:community_app/pages/search_friend.dart';
import 'package:community_app/pages/friend_chat_pages/friend_chat_list_page.dart';
import '../../components/circular_menu_button.dart';
import 'package:flutter/material.dart';
import 'community_pages/community_chat_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'A P P N A M E',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: (){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => SearchFriend()
                  ));},
                icon: const Icon(Icons.search,color: Colors.black),
              ),
            ],
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0.0,
            bottom: const TabBar(
              labelColor: Colors.black,
              indicatorColor: Colors.black,
              tabs: [
                Tab(text: 'Communities'),
                Tab(text: 'Friends'),
              ],
            ),
          ),
          extendBody: true,
          floatingActionButton: const CircularMenuButton(),
          backgroundColor: Colors.white,
          body: const TabBarView(
            children: [
              CommunityChatListPage(),
              FriendChatListPage(),
            ],
          ),
        ),
      );
}
