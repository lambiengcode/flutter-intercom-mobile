import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:project_message_demo/src/animation/fade_animation.dart';
import 'package:project_message_demo/src/model/user.dart';
import 'package:project_message_demo/src/page/user/profile_page.dart';
import 'package:project_message_demo/src/widget/receive_widget/inbox_list.dart';
import 'package:provider/provider.dart';

class ReceivePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2.0,
        centerTitle: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .where('id', isEqualTo: user.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }

                String urlToImage = snapshot.data.documents[0]['urlToImage'];

                return Row(
                  children: [
                    CircleAvatar(
                        backgroundImage: urlToImage == ''
                            ? AssetImage('images/avt.jpg')
                            : NetworkImage(urlToImage),
                        radius: 16.96),
                    SizedBox(
                      width: 6.8,
                    ),
                    Text(
                      "History",
                      style: TextStyle(
                        fontSize: size.width / 18.25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Feather.sliders,
              size: size.width / 16.0,
              color: Colors.grey.shade800,
            ),
            onPressed: () {},
          ),
          SizedBox(
            width: 4.0,
          ),
          IconButton(
            icon: Icon(
              Feather.settings,
              size: size.width / 16.0,
              color: Colors.grey.shade800,
            ),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EditProfilePage()));
            },
          ),
          SizedBox(
            width: 4.0,
          ),
        ],
      ),
      body: Container(
        height: size.height,
        width: size.width,
        child: Column(
          children: [
            SizedBox(
              height: 12.0,
            ),
            Expanded(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('requests')
                    .where('receiveID', isEqualTo: user.uid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  List<DocumentSnapshot> docs = snapshot.data.documents;

                  for (int i = 0; i < docs.length - 1; i++) {
                    for (int j = 0; j < docs.length - 1 - i; j++) {
                      Timestamp t1 = docs[j]['responcedTime'];
                      Timestamp t2 = docs[j + 1]['responcedTime'];
                      if (t1.compareTo(t2) == -1) {
                        DocumentSnapshot temp = docs[j];
                        docs[j] = docs[j + 1];
                        docs[j + 1] = temp;
                      }
                    }
                  }

                  return FadeAnimation(
                    .25,
                    InboxList(
                      documents: docs,
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
