import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:project_message_demo/src/page/receive_page/room_page.dart';

class InboxCard extends StatelessWidget {
  final String lastMessage;
  final Timestamp publishAt;
  final String uid;
  final String roomID;
  final bool isMe;
  final bool seen;
  final bool request;
  final bool completed;
  final index;

  InboxCard({
    this.uid,
    this.lastMessage,
    this.publishAt,
    this.roomID,
    this.isMe,
    this.seen,
    this.request,
    this.index,
    this.completed,
  });

  @override
  Widget build(BuildContext context) {
    int hour = publishAt.toDate().hour;
    int min = publishAt.toDate().minute;
    String time = '';
    String lastMes;

    lastMes = lastMessage.replaceAll('''\n''', ' ');
    lastMes = lastMes.length > 23 ? lastMes.substring(0, 20) + '...' : lastMes;

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

    if (hour < 10 && min < 10) {
      time = '0$hour:0$min';
    } else if (hour < 10) {
      time = '0$hour:$min';
    } else if (min < 10) {
      time = '$hour:0$min';
    } else {
      time = '$hour:$min';
    }

    final double sizeWidth = MediaQuery.of(context).size.width;

    return StreamBuilder(
      stream: Firestore.instance
          .collection('users')
          .where('id', isEqualTo: uid)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            padding: EdgeInsets.fromLTRB(14, 0, 14, 8),
            decoration: BoxDecoration(
              color: seen ? Colors.transparent : Colors.white.withOpacity(.08),
              border: Border(
                  bottom: BorderSide(
                      color: Colors.white.withOpacity(.3), width: 0.04)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: sizeWidth / 6.4,
                  width: sizeWidth / 6.4,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white10, width: 0.4),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('images/avt.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Container(
                  width: sizeWidth * 0.70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Username',
                        style: TextStyle(
                            fontSize: sizeWidth / 21.5,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 6.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isMe ? 'You: message' : 'Stranger: message',
                              style: TextStyle(
                                fontSize: sizeWidth / 28,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12.0,
                          ),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: sizeWidth / 28,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        String username = snapshot.data.documents[0]['username'];
        String urlToImage = snapshot.data.documents[0]['urlToImage'];

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatRoomPage(
                      name: username,
                      roomID: roomID,
                      request: request,
                      index: index,
                      idReceive: uid,
                      available: completed
                          ? false
                          : request && lastMessage == '[\"Image\"]'
                              ? true
                              : request == false && lastMessage != '[\"Image\"]'
                                  ? true
                                  : false,
                    )));
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.5),
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                urlToImage == ''
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        height: sizeWidth / 6.5,
                        width: sizeWidth / 6.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage('images/avt.jpg'),
                              fit: BoxFit.cover),
                        ),
                        alignment: Alignment.bottomRight,
                      )
                    : CachedNetworkImage(
                        imageBuilder: (BuildContext context, index) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            height: sizeWidth / 6.5,
                            width: sizeWidth / 6.5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: NetworkImage(urlToImage),
                                  fit: BoxFit.cover),
                            ),
                            alignment: Alignment.bottomRight,
                          );
                        },
                        imageUrl: urlToImage,
                        placeholder: (context, url) =>
                            Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Center(
                          child: Icon(
                            Icons.error,
                            color: Colors.white.withOpacity(.88),
                          ),
                        ),
                      ),
                SizedBox(
                  width: 12.0,
                ),
                Container(
                  width: sizeWidth * 0.70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: sizeWidth / 20.5,
                              fontWeight: FontWeight.bold,
                              color: request
                                  ? Colors.blueAccent
                                  : Colors.redAccent,
                            ),
                          ),
                          Text(
                            time,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: sizeWidth / 28.0,
                              fontWeight: isMe == false
                                  ? seen
                                      ? FontWeight.w400
                                      : FontWeight.bold
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 2.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: RichText(
                              softWrap: true,
                              overflow: TextOverflow.visible,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: isMe ? 'You:\b' : '$username:\b',
                                    style: TextStyle(
                                      fontSize: sizeWidth / 26.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  TextSpan(
                                    text: lastMes,
                                    style: TextStyle(
                                      fontSize: sizeWidth / 26.0,
                                      fontWeight: isMe == false
                                          ? seen
                                              ? FontWeight.w400
                                              : FontWeight.bold
                                          : FontWeight.w400,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Icon(
                            Feather.check,
                            color: seen
                                ? parseColor('#00CC00')
                                : Colors.grey.shade600,
                            size: sizeWidth / 18.5,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
