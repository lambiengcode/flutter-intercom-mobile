import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:project_message_demo/src/animation/fade_animation.dart';
import 'package:project_message_demo/src/model/user.dart';
import 'package:project_message_demo/src/widget/receive_widget/build_chat_line.dart';
import 'package:project_message_demo/src/widget/receive_widget/input_bottom.dart';
import 'package:provider/provider.dart';

class ChatRoomPage extends StatefulWidget {
  final String name;
  final String roomID;
  final bool request;
  final index;

  ChatRoomPage({this.name, this.roomID, this.index, this.request});

  @override
  State<StatefulWidget> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _scrollController = new ScrollController();
  String stranger = 'Stranger';

  @override
  void initState() {
    super.initState();
  }

  Color parseColor(String color) {
    String hex = color.replaceAll("#", "");
    if (hex.isEmpty) hex = "ffffff";
    if (hex.length == 3) {
      hex =
          '${hex.substring(0, 1)}${hex.substring(0, 1)}${hex.substring(1, 2)}${hex.substring(1, 2)}${hex.substring(2, 3)}${hex.substring(2, 3)}';
    }
    Color col = Color(int.parse(hex, radix: 16)).withOpacity(1.0);
    return col;
  }

  @override
  Widget build(BuildContext context) {
    final double sizeWidth = MediaQuery.of(context).size.width;

    final user = Provider.of<User>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 2.0,
        backgroundColor: Colors.white,
        title: StreamBuilder(
          stream: Firestore.instance
              .collection('inboxs')
              .where('id', isEqualTo: widget.roomID)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            String user1 = snapshot.data.documents[0]['idSend'];
            String user2 = snapshot.data.documents[0]['idReceive'];

            String idStranger = user1 == user.uid ? user2 : user1;

            return StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .where('id', isEqualTo: idStranger)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot1) {
                if (!snapshot1.hasData) {
                  return Container();
                }

                String username = snapshot1.data.documents[0]['username'];
                String urlToImage = snapshot1.data.documents[0]['urlToImage'];

                return GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      urlToImage == ''
                          ? CircleAvatar(
                              backgroundImage: AssetImage('images/avt.jpg'),
                              radius: 20.0,
                            )
                          : CircleAvatar(
                              backgroundImage: NetworkImage(urlToImage),
                              radius: 20.0,
                            ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: sizeWidth / 23.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        leading: IconButton(
          icon: Icon(
            Feather.arrow_left,
            color: Colors.black,
            size: sizeWidth / 14,
          ),
          onPressed: () {
            Navigator.of(context).pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        child: StreamBuilder(
          stream: Firestore.instance
              .collection('requests')
              .where('id', isEqualTo: widget.roomID)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            String id1 = snapshot.data.documents[0]['idSend'];
            String id2 = snapshot.data.documents[0]['idReceive'];

            String idReceive;

            id1 == user.uid ? idReceive = id2 : idReceive = id1;

            return Column(
              children: <Widget>[
                Expanded(
                  child: FadeAnimation(
                    1.0,
                    Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 4.0, bottom: 8.0),
                      child: StreamBuilder(
                        stream: Firestore.instance
                            .collection('inboxs')
                            .where('id', isEqualTo: widget.roomID)
                            .orderBy('publishAt', descending: true)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return Container(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(0.0),
                            itemCount: snapshot.data.documents.length,
                            controller: _scrollController,
                            reverse: true,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return BuildChatLine(
                                message: snapshot.data.documents[index]
                                    ['message'],
                                isMe: snapshot.data.documents[index]
                                            ['idSend'] ==
                                        user.uid
                                    ? true
                                    : false,
                                type: snapshot.data.documents[index]['type'],
                                name: widget.name,
                                seen: snapshot.data.documents[index]['seen'] ==
                                        null
                                    ? true
                                    : snapshot.data.documents[index]['seen'],
                                index: snapshot.data.documents[index].reference,
                                isLast: index == 0 ? true : false,
                                idUser: snapshot.data.documents[index]
                                    ['receiveID'],
                                publishAt: snapshot.data.documents[index]
                                    ['publishAt'],
                                color: 414141,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                InputBottom(
                  request: widget.request,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
