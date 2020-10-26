import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_message_demo/src/model/user.dart';
import 'package:project_message_demo/src/widget/receive_widget/inbox_card.dart';
import 'package:provider/provider.dart';

class InboxList extends StatefulWidget {
  final List<DocumentSnapshot> documents;

  InboxList({this.documents});

  @override
  State<StatefulWidget> createState() => _InboxListState();
}

class _InboxListState extends State<InboxList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 0.0),
      itemCount: widget.documents.length,
      itemBuilder: (context, index) {
        String room = widget.documents[index]['id'];

        return StreamBuilder(
          stream: Firestore.instance
              .collection('requests')
              .where('id', isEqualTo: room)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            String temp = '';
            String user1 = snapshot.data.documents[0]['idSend'];
            String user2 = snapshot.data.documents[0]['idReceive'];

            if (user.uid == user1) {
              temp = user2;
            } else {
              temp = user1;
            }

            return StreamBuilder(
                stream: Firestore.instance
                    .collection('inboxs')
                    .where('id', isEqualTo: room)
                    .orderBy('publishAt', descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot1) {
                  if (!snapshot1.hasData) {
                    return Container();
                  }

                  int lengthMessage = snapshot1.data.documents.length;

                  return InboxCard(
                    lastMessage: lengthMessage == 0
                        ? 'Empty'
                        : snapshot1.data.documents[0]['message']
                                    .toString()
                                    .length >
                                12
                            ?
                            //Sent a Image
                            snapshot1.data.documents[0]['message']
                                        .toString()
                                        .substring(0, 12) ==
                                    'https://fire'
                                ? '[\"Image\"]'
                                :
                                //normal
                                snapshot1.data.documents[0]['message']
                            : snapshot1.data.documents[0]['message'],
                    publishAt: snapshot1.data.documents[0]['publishAt'],
                    roomID: room,
                    uid: temp,
                    isMe: lengthMessage == 0
                        ? true
                        : snapshot1.data.documents[0]['idSend'] == user.uid
                            ? true
                            : false,
                    seen: snapshot1.data.documents[0]['seen'],
                    request: widget.documents[index]['idSend'] == user.uid
                        ? true
                        : false,
                  );
                });
          },
        );
      },
    );
  }
}
