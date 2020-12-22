import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:project_message_demo/src/widget/notification_widget/notification_item.dart';
import 'package:provider/provider.dart';

import '../../model/user.dart';

class NotificationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Future<void> _updateNotification(index) async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(index);
      bool notification = snapshot['notifications'];
      await transaction.update(index, {
        'notifications': !notification,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final sizeWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        elevation: 1.5,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Feather.arrow_left,
            color: Colors.grey.shade800,
            size: sizeWidth / 14.5,
          ),
          onPressed: () {
            Navigator.of(context).pop(context);
          },
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: sizeWidth / 18.8,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
            height: 2,
          ),
        ),
        actions: [
          StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .where('id', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return IconButton(
                  icon: Icon(
                    Feather.bell,
                    color: Colors.grey.shade800,
                    size: sizeWidth / 16.5,
                  ),
                  onPressed: () {},
                );
              }

              return IconButton(
                icon: Icon(
                  snapshot.data.documents[0]['notifications']
                      ? Feather.bell
                      : Feather.bell_off,
                  color: Colors.grey.shade800,
                  size: sizeWidth / 16.5,
                ),
                onPressed: () async {
                  await _updateNotification(
                      snapshot.data.documents[0].reference);
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('users')
                    .where('id', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  return StreamBuilder(
                    stream: Firestore.instance
                        .collection('notifications')
                        .where('key',
                            isEqualTo: snapshot.data.documents[0]['key'])
                        .orderBy('publishAt', descending: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> result) {
                      if (!result.hasData) {
                        return Container();
                      }

                      List<DocumentSnapshot> docs = result.data.documents;

                      docs
                          .where((doc) {
                            if (doc['all'] == false) {
                              int count = 0;
                              List<dynamic> members = doc['members'];
                              for (int j = 0; j < members.length; j++) {
                                if (user.uid == members[j]) {
                                  count++;
                                }
                              }

                              return count == 0 ? true : false;
                            }
                            return false;
                          }) // filter keys
                          .toList() // create a copy to avoid concurrent modifications
                          .forEach(docs.remove);

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          return NotificationItem(
                            title: docs[index]['title'],
                            body: docs[index]['body'],
                            urlToImage: docs[index]['urlToImage'],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
