import 'package:flutter/material.dart';
import 'package:project_message_demo/src/app.dart';
import 'package:project_message_demo/src/model/user.dart';
import 'package:project_message_demo/src/service/auth.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Intercom',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
        ),
        home: App(),
      ),
    );
  }
}
