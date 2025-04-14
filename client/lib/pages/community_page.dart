import 'package:client/Components/task.dart';
import 'package:client/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:http/http.dart' as http;

class CommunityPage extends StatelessWidget {
  String id;
  String name;
  String image;
  String desc;
  List members;
  List tasks;
  CommunityPage({
    super.key,
    required this.id,
    required this.name,
    required this.desc,
    required this.image,
    required this.members,
    required this.tasks,
  });

  Future<http.Response> getTasks() async {
    String token = await SharedPref.getToken();
    Map<String, String> header = {"Authorization": "Bearer $token"};
    return http.get(
      Uri.parse("http://localhost:5000/community/mycommunities"),
      headers: header,
    );
  }

    Future<http.Response> joinGuild(communityId) async {
    String token = await SharedPref.getToken();
    
    Map<String, String> header = {"Authorization": "Bearer $token"};
    return http.post(
      Uri.parse("http://localhost:5000/community/add-member"),
      headers: header,
      body: {"communityId": communityId}
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          name,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: LinearPercentIndicator(
                  barRadius: const Radius.circular(20),
                  animation: true,
                  lineHeight: 20.0,
                  animationDuration: 2000,
                  percent: 0.9,
                  center: const Text("90.0%"),
                  progressColor: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                        ),
                        onPressed: () {
                          joinGuild(id);
                        },
                        child: const Text(
                          "Join Guild",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text(
                          "Members",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TaskWidget(
                id: "232",
                name: "test task",
                des: "this task must be done",
              ),
              TaskWidget(
                id: "232",
                name: "test task 2 ",
                des: "this is an import task by guilt",
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        type: ExpandableFabType.up,
        distance: 80,
        children: [
          FloatingActionButton.small(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text("Add Memberers"),
                    content: const TextField(),
                    actions: [
                      TextButton(onPressed: () {}, child: const Text("Add")),
                    ],
                  );
                },
              );
            },
            heroTag: "add members",
            child: const Icon(Icons.group),
          ),
          FloatingActionButton.small(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text("add quest "),
                    content: const Wrap(children: [TextField(), TextField()]),
                    actions: [
                      TextButton(onPressed: () {}, child: const Text("Add")),
                    ],
                  );
                },
              );
            },
            heroTag: "add quests",
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
