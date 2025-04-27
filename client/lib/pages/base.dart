import 'package:client/pages/guilds_page.dart';
import 'package:client/pages/homepage.dart';
import 'package:client/pages/profile_page.dart';
import 'package:client/pages/quotes_page.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  int currentPageIndex = 0;
  List<Widget> pages = [
    const MyHomePage(),
    const HabitPage(),
    const GuildsPage(),
    const ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('L E V E L   U P'),
          actions: [
            IconButton(
              onPressed: () => {},
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
              icon: Icon(Icons.shield),
              label: 'Habits',
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
