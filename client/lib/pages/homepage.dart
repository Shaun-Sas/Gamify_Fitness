import 'dart:convert';

import 'package:client/Components/post_widget.dart';
import 'package:client/pages/new_post.dart';
import 'package:client/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<http.Response> getPosts() async {
    String token = await SharedPref.getToken();
    Map<String, String> header = {"Authorization": "Bearer $token"};
    return http.get(Uri.parse("http://192.168.78.217:5000/post/myposts"),
        headers: header);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SizedBox(
        height: 75,
        width: 75,
        child: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return const NewPostWidget();
                },
              ));
            },
            child: const Icon(
              Icons.add,
              color: Colors.white,
            )),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          PostWidget(
            authorId: "shaunak",
            timestamps: "12/12/23 at 12:12",
            media:
                "http://192.168.78.217:5000/uploads/1706356378090-428402713.mp4",
            caption: "this is a test data",
            likes: "12",
            dislikes: "2",
          ),
          PostWidget(
            authorId: "shaunak",
            timestamps: "12/12/23 at 12:12",
            media:
                "http://192.168.78.217:5000/uploads/1706356417878-356186700.mp4",
            caption: "this is a test data",
            likes: "12",
            dislikes: "2",
          ),
          PostWidget(
            authorId: "shaunak",
            timestamps: "12/12/23 at 12:12",
            media:
                "http://192.168.78.217:5000/uploads/1706360399727-792044374.mp4",
            caption: "test workout video data",
            likes: "12",
            dislikes: "2",
          ),
          PostWidget(
            authorId: "dvip",
            timestamps: "12/12/23 at 12:12",
            media:
                "http://192.168.78.217:5000/uploads/1706356378090-428402713.mp4",
            caption: "this is a test data",
            likes: "12",
            dislikes: "2",
          ),
          PostWidget(
            authorId: "taher",
            timestamps: "12/12/23 at 12:12",
            media:
                "http://192.168.78.217:5000/uploads/1706356417878-356186700.mp4",
            caption: "this is a test data",
            likes: "12",
            dislikes: "2",
          )
        ],
      )),
    );
  }
}
