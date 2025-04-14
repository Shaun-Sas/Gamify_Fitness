import 'dart:math';

import 'package:client/pages/community_page.dart';
import 'package:flutter/material.dart';

class CommunityWidget extends StatefulWidget {
  String id;
  String name;
  String image;
  String desc;
  List members;
  List tasks;
  CommunityWidget({
    super.key,
    required this.id,
    required this.name,
    required this.desc,
    required this.image,
    required this.members,
    required this.tasks,
  });

  @override
  State<CommunityWidget> createState() => _CommunityWidgetState();
}

class _CommunityWidgetState extends State<CommunityWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => CommunityPage(
                  id: widget.id,
                  name: widget.name,
                  desc: widget.desc,
                  members: widget.members,
                  tasks: widget.tasks,
                  image: "",
                ),
          ),
        );
      },
      child: Card(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    radius: 34,
                    child: const Text("D"),
                  ),
                  title: Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    widget.desc,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
