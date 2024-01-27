import 'package:client/pages/guilds_page.dart';
import 'package:client/pages/homepage.dart';
import 'package:client/pages/profile_page.dart';
import 'package:client/pages/quotes_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  var usernameCont = TextEditingController();
  bool isloading = false;
  int currentPageIndex = 0;
  List<Widget> pages = [
    const MyHomePage(),
    const QuotesPage(),
    const GuildsPage(),
    const ProfilePage(),
  ];

  void addConn() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('L E V E L   U P'),
          actions: [
            IconButton(
              onPressed: () => {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("add connectiond"),
                      content: TextField(
                          controller: usernameCont,
                          decoration:
                              const InputDecoration(label: Text("Username"))),
                      actions: [
                        isloading
                            ? const CircularProgressIndicator()
                            : TextButton(
                                onPressed: () {}, child: const Text("continue"))
                      ],
                    );
                  },
                )
              },
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () => {},
              icon: const Icon(Icons.notifications),
            )
          ],
        ),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          indicatorColor: Theme.of(context).colorScheme.secondary,
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.sports),
              icon: Icon(Icons.sports),
              label: 'Quots',
            ),
            NavigationDestination(
              icon: Icon(Icons.local_activity),
              label: 'Guilds',
            ),
            NavigationDestination(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
        body: pages[currentPageIndex]);
  }
}
