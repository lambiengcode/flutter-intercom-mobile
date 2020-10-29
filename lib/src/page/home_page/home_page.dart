import 'dart:async';
import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:project_message_demo/src/page/receive_page/receive_page.dart';
import 'package:project_message_demo/src/page/request_page.dart/request_page.dart';
import 'package:project_message_demo/src/page/user/profile_page.dart';

class HomePage extends StatefulWidget {
  final String uid;
  HomePage({this.uid});
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int currentPage = 0;

  var _pages = [
    ReceivePage(),
    EditProfilePage(),
  ];

  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;

  _saveDeviceToken() async {
    // Get the current user
    String uid = widget.uid;
    // FirebaseUser user = await _auth.currentUser();

    // Get the token for this device
    String fcmToken = await _fcm.getToken();

    // Save it to Firestore
    if (fcmToken != null) {
      var tokens = _db
          .collection('users')
          .document(uid)
          .collection('tokens')
          .document(fcmToken);

      await tokens.setData({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(), // optional
        'platform': Platform.operatingSystem, // optional
      });
    }
  }

  playLocal() async {
    final assetsAudioPlayer = AssetsAudioPlayer();
    try {
      await assetsAudioPlayer.open(
        Audio('assets/message.mp3'),
        showNotification: true,
        autoStart: true,
        loopMode: LoopMode.single,
      );
    } catch (t) {
      //stream unreachable
    }
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        _saveDeviceToken();
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken();
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        //playLocal();
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (i) {
          setState(() {
            currentPage = i;
          });
        },
        elevation: 2.5,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey.shade800,
        iconSize: 24.0,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Feather.mail), title: Text("Receive")),
          BottomNavigationBarItem(
              icon: Icon(Feather.user), title: Text("User")),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 60.0),
        child: _pages[currentPage],
      ),
    );
  }
}
