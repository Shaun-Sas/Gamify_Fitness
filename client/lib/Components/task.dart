import 'package:client/pages/new_post.dart';
import 'package:flutter/material.dart';

class TaskWidget extends StatefulWidget {
  String name;
  String des;
  String id;
  TaskWidget(
      {super.key, required this.id, required this.name, required this.des});

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text("Create Post"),
              content:
                  const Text("do you want  to create post on this quest ?"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: Text("No",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ))),
                TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return NewPostWidget();
                        },
                      ));
                    },
                    child: Text("Yes",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        )))
              ],
            );
          },
        );
      },
      child: Card(
        // color: Theme.of(context).colorScheme.secondary,
        child: ListTile(
          title: Text(
            widget.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(widget.des, style: const TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}
