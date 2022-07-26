import 'package:community_app/pages/community_pages/select_members_page.dart';
import 'package:community_app/pages/friend_chat_pages/Match_friend_Page.dart';
import 'package:flutter/material.dart';
import '../pages/settings_page.dart';
import '../pages/profile_page.dart';
import 'dart:math';

const double buttonSize = 60.0;

class CircularMenuButton extends StatefulWidget {
  const CircularMenuButton({Key? key}) : super(key: key);

  @override
  State<CircularMenuButton> createState() => _CircularMenuButtonState();
}

class _CircularMenuButtonState extends State<CircularMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Flow(delegate: FlowMenuDelegate(controller: controller), children: [
        // buildButton(Icons.person_add_alt_sharp, () {
        //   addFriend(context);
        // }),
        buildButton(Icons.person_add_alt_sharp, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) =>  MatchFriendPage()));
        }),
        // buildButton(Icons.group_add, () {
        //   addCommunity(context);
        // }),
        buildButton(Icons.group_add, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) =>  const SelectMembersPage()));
        }),
        buildButton(Icons.admin_panel_settings, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ProfilePage()));
        }),
        buildButton(Icons.settings, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SettingsPage()));
        }),
        buildAnimatedButton(AnimatedIcons.menu_close),
      ]);

  Widget buildButton(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(45.0),
              border: Border.all(
                color: Colors.black,
                width: 2.0,
              )),
          child: Icon(
            icon,
            color: Colors.black,
            size: 35,
          ),
        ),
      );

  Widget buildAnimatedButton(AnimatedIconData icon) => SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: FloatingActionButton(
          backgroundColor: Colors.black,
          elevation: 0,
          child: AnimatedIcon(
            icon: icon,
            progress: controller,
            color: Colors.white,
            size: 35,
          ),
          isExtended: true,
          onPressed: () {
            if (controller.status == AnimationStatus.completed) {
              controller.reverse();
            } else {
              controller.forward();
            }
          },
        ),
      );
}

class FlowMenuDelegate extends FlowDelegate {
  final Animation<double> controller;

  const FlowMenuDelegate({required this.controller})
      : super(repaint: controller);

  @override
  void paintChildren(FlowPaintingContext context) {
    final size = context.size;
    final xStart = size.width - buttonSize;
    final yStart = size.height - buttonSize;

    final n = context.childCount;
    for (int i = 0; i < n; i++) {
      final isLastItem = i == context.childCount - 1;
      final setValue = (value) => isLastItem ? 0.0 : value;

      final radius = 140 * controller.value;

      final theta = i * pi * 0.5 / (n - 2);
      final x = xStart - setValue(radius * cos(theta));
      final y = yStart - setValue(radius * sin(theta));

      context.paintChild(
        i,
        transform: Matrix4.identity()
          ..translate(x, y, 0)
          ..translate(buttonSize / 2, buttonSize / 2)
          //..rotateZ((isLastItem ? 180 * (1 - controller.value) * pi : 0.0) / 180)
          ..translate(-buttonSize / 2, -buttonSize / 2),
      );
    }
  }

  @override
  bool shouldRepaint(FlowMenuDelegate oldDelegate) => false;
}
