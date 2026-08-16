import 'package:flutter/material.dart';
import 'trails_page_view.dart';
import 'trail_logs_view.dart';
import 'auth_view.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => HomePageViewState();
}

class HomePageViewState extends State<HomePageView> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        height: 60,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.blue,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          // each navigation destinatio for each of the pages

          // trails view
          NavigationDestination(
            icon: Icon(Icons.hiking),
            label: "Trails",
          ),

          // log view
          NavigationDestination(
            icon: Icon(Icons.book),
            label: "Trail Logs",
          ),

          // auth gate view
          NavigationDestination(
            icon: Icon(Icons.account_circle),
            label: "Account",
          ),

        ],
      ),
      body: [
        TrailsPageView(),
        TrailLogsView(),
        AuthView(),
      ][currentPageIndex],
    );
  }
}