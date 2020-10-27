import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_message_demo/src/model/user.dart';
import 'package:provider/provider.dart';

class UserCard extends StatefulWidget {
  final DocumentSnapshot user;

  UserCard({this.user});

  @override
  State<StatefulWidget> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  Future<void> _request(
    idSend,
    idReceive,
  ) async {
    String id = idSend + DateTime.now().microsecondsSinceEpoch.toString();
    Firestore.instance.runTransaction((Transaction transaction) async {
      CollectionReference reference = Firestore.instance.collection("requests");

      await reference.add({
        'idSend': idSend,
        'idReceive': idReceive,
        'id': id,
        'publishAt': DateTime.now(),
        'completed': false,
      });
    });
    _firstInbox(idSend, idReceive, id);
  }

  Future<void> _firstInbox(
    idSend,
    idReceive,
    id,
  ) async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      CollectionReference reference = Firestore.instance.collection("inboxs");
      await reference.add({
        'idSend': idSend,
        'idReceive': idReceive,
        'id': id,
        'publishAt': DateTime.now(),
        'message': 'Request',
        'seen': false,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final sizeWidth = MediaQuery.of(context).size.width;
    final user = Provider.of<User>(context);

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: widget.user['urlToImage'] == ''
                      ? AssetImage('images/avt.jpg')
                      : NetworkImage(widget.user['urlToImage']),
                  radius: 26.0,
                ),
                SizedBox(
                  width: 12.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.user['username'],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: sizeWidth / 21.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 6.0,
                    ),
                    Text(
                      widget.user['phone'],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: sizeWidth / 25.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            StreamBuilder(
              stream: Firestore.instance
                  .collection('requests')
                  .where('idSend', isEqualTo: user.uid)
                  .where('idReceive', isEqualTo: widget.user['id'])
                  .where('completed', isEqualTo: false)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }

                int length = snapshot.data.documents.length;

                return GestureDetector(
                  onTap: () async {
                    if (length == 0) {
                      await _request(user.uid, widget.user['id']);
                    } else if (snapshot.data.documents[0]['id'] == '') {
                      await _request(user.uid, widget.user['id']);
                    } else {}
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                        color: length == 0
                            ? Colors.transparent
                            : Colors.blueAccent,
                        border: Border.all(
                          color: length == 0
                              ? Colors.grey.shade600
                              : Colors.blueAccent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(
                          4.0,
                        ))),
                    child: Text(
                      length == 0 ? 'Request' : 'Requested',
                      style: TextStyle(
                        color:
                            length == 0 ? Colors.grey.shade800 : Colors.white,
                        fontSize: sizeWidth / 28.8,
                      ),
                    ),
                    alignment: Alignment.center,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
