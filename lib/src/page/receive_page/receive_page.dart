import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:project_message_demo/src/animation/fade_animation.dart';
import 'package:project_message_demo/src/model/user.dart';
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
        backgroundColor: Colors.transparent,
        elevation: 0.0,
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

                return CircleAvatar(
                  backgroundImage: urlToImage == ''
                      ? AssetImage('images/avt.jpg')
                      : NetworkImage(urlToImage),
                  radius: 16.0,
                );
              },
            ),
            SizedBox(
              width: 4.0,
            ),
            Text(
              "\tReceive",
              style: TextStyle(
                fontSize: size.width / 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Feather.search,
              size: size.width / 14.5,
              color: Colors.grey.shade800,
            ),
            onPressed: () {},
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
              height: 20.0,
            ),
            Expanded(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('requests')
                    .where('idSend', isEqualTo: user.uid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  return StreamBuilder(
                    stream: Firestore.instance
                        .collection('requests')
                        .where('idReceive', isEqualTo: user.uid)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshotReceive) {
                      if (!snapshotReceive.hasData) {
                        return Container();
                      }

                      List<DocumentSnapshot> docs = snapshot.data.documents;
                      docs.addAll(snapshotReceive.data.documents);

                      for (int i = 0; i < docs.length - 1; i++) {
                        for (int j = 0; j < docs.length - 1 - i; j++) {
                          Timestamp t1 = docs[j]['publishAt'];
                          Timestamp t2 = docs[j + 1]['publishAt'];
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
                          ));
                    },
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
