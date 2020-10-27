import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_message_demo/src/model/user.dart';
import 'package:project_message_demo/src/page/auth/auth_page.dart';
import 'package:project_message_demo/src/page/home_page/home_page.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  static bool dark;
  static String systemLocales = Platform.localeName.substring(0, 2);

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return user == null
        ? AuthenticatePage()
        : HomePage(
            uid: user.uid,
          );
  }
}
