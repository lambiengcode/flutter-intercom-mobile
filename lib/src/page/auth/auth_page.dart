import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_message_demo/src/page/auth/login_page.dart';
import 'package:project_message_demo/src/page/auth/signup_page.dart';

class AuthenticatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AuthenticatePageState();
}

class _AuthenticatePageState extends State<AuthenticatePage> {
  bool showSignIn = true;
  void toggleView() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // transparent status bar
        systemNavigationBarColor: Colors.black, // navigation bar color
        statusBarIconBrightness: Brightness.dark, // status bar icons' color
      ),
      child: showSignIn == true
          ? LoginPage(
              toggleView: toggleView,
            )
          : SignupPage(
              toggleView: toggleView,
            ),
    );
  }
}
