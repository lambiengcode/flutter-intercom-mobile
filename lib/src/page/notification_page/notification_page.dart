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
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final sizeWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
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
          IconButton(
            icon: Icon(
              Feather.bell,
              color: Colors.grey.shade800,
              size: sizeWidth / 16.5,
            ),
            onPressed: () {},
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

                      List<DocumentSnapshot> res = result.data.documents;

                      for (int i = 0; i < res.length; i++) {
                        if (res[i]['all'] == false) {
                          int count = 0;
                          List<dynamic> members = res[i]['members'];
                          for (int j = 0; j < members.length; j++) {
                            if (user.uid == members[j]) {
                              count++;
                            }
                          }
                          if (count == 0) {
                            res.removeAt(i);
                          }
                        }
                      }

                      print(res.length);
                      return ListView.builder(
                        itemCount: res.length,
                        itemBuilder: (context, index) {
                          return NotificationItem(
                            title: res[index]['title'],
                            body: res[index]['body'],
                            urlToImage: res[index]['urlToImage'],
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
