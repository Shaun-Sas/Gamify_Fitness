import 'dart:convert';

import 'package:client/Components/community_card.dart';
import 'package:client/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GuildsPage extends StatefulWidget {
  const GuildsPage({super.key});

  @override
  State<GuildsPage> createState() => _GuildsPageState();
}

class _GuildsPageState extends State<GuildsPage> {
  bool isLoading = false;
  var nameCont = TextEditingController();
  var desCont = TextEditingController();

  void addGuilds(String gName, String gDes) async {
    setState(() {
      isLoading = false;
    });

    String token = await SharedPref.getToken();
    Map<String, String> header = {"Authorization": "Bearer $token"};

    var response = await http.post(
      Uri.parse("http://localhost:5000/community/community"),
      headers: header,
      body: Map.from({"name": gName, "description": gDes}),
    );

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<http.Response> getGuilds() async {
    String token = await SharedPref.getToken();
    Map<String, String> header = {"Authorization": "Bearer $token"};
    return http.get(
      Uri.parse("http://localhost:5000/community/mycommunities"),
      headers: header,
    );
  }

  Future<http.Response> getAllGuilds() async {
    String token = await SharedPref.getToken();
    Map<String, String> header = {"Authorization": "Bearer $token"};
    return http.get(
      Uri.parse("http://localhost:5000/community/community"),
      headers: header,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
        child: FutureBuilder(
          future: getAllGuilds(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasData) {
              var data = jsonDecode(snapshot.data!.body) as List;
              if (data.isEmpty) {
                return const Center(
                  child: Text("No any guild in you have joined"),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return CommunityWidget(
                    id: data[index]["_id"],
                    name: data[index]["name"],
                    desc: data[index]["description"],
                    image: data[index]["name"],
                    members: data[index]["members"],
                    tasks: data[index]["tasks"],
                  );
                },
              );
            } else {
              return Center(child: Text(snapshot.error.toString()));
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialofContext) {
              return AlertDialog(
                title: const Text("Create Guild"),
                content: Wrap(
                  children: [
                    TextField(controller: nameCont, 
                      decoration: InputDecoration( hintText: "Guild Name")),
                    TextField(controller: desCont, 
                      decoration: InputDecoration( hintText: "Description")),
                  ],
                ),
                actions: [
                  isLoading
                      ? const CircularProgressIndicator()
                      : TextButton(
                        onPressed: () {
                          addGuilds(nameCont.text, desCont.text);
                          Navigator.pop(dialofContext);
                        },
                        child: Text(
                          "Create",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                      ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
