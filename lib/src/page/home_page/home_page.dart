import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:project_message_demo/src/page/receive_page/receive_page.dart';
import 'package:project_message_demo/src/page/request_page.dart/request_page.dart';
import 'package:project_message_demo/src/page/user/profile_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int currentPage = 0;

  var _pages = [
    ReceivePage(),
    RequestPage(),
    EditProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // transparent status bar
        systemNavigationBarColor: Colors.black, // navigation bar color
        statusBarIconBrightness: Brightness.dark, // status bar icons' color
      ),
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentPage,
          onTap: (i) {
            setState(() {
              currentPage = i;
            });
          },
          elevation: 2.0,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey.shade800,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Feather.mail), title: Text("Mail")),
            BottomNavigationBarItem(
                icon: Icon(Feather.plus_square), title: Text("Search")),
            BottomNavigationBarItem(
                icon: Icon(Feather.user), title: Text("User")),
          ],
        ),
        body: _pages[currentPage],
      ),
    );
  }
}
