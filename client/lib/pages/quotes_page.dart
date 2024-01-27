import 'package:client/Components/task.dart';
import 'package:flutter/material.dart';

class QuotesPage extends StatelessWidget {
  const QuotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 34, bottom: 16),
                  child: Text(
                    "Quests",
                    style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                  ),
                ),
                TaskWidget(
                  id: '',
                  name: 'pullups',
                  des: '21k peoples completed',
                ),
                TaskWidget(
                  id: '',
                  name: 'running',
                  des: '67k peoples completed',
                ),
                TaskWidget(
                  id: '',
                  name: 'walking',
                  des: '81k peoples completed',
                ),
                TaskWidget(
                  id: '',
                  name: 'pushups',
                  des: '29k peoples completed',
                ),
              ],
            )),
      ),
    );
  }
}
