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
    return http.get(
      Uri.parse("http://65.2.182.126:5000/post/myposts"),
      headers: header,
    );
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const NewPostWidget();
                },
              ),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
        child: FutureBuilder(
          future: getPosts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else if (snapshot.data == null) {
              return const Center(child: Text("No data available"));
            } else {
              var data = jsonDecode(snapshot.data!.body) as List;
              if (data.isEmpty) {
                return const Text("No Post Found");
              }
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return PostWidget(
                    authorId: data[index]["user"],
                    timestamps: data[index]["user"],
                    media: data[index]["media"],
                    caption: data[index]["caption"],
                    likes: "${data[index]["likes"]}",
                    dislikes: "2",
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
