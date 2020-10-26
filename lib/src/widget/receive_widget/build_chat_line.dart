import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_message_demo/src/widget/general/cached_image.dart';
import 'package:project_message_demo/src/widget/general/photo_viewer.dart';

class BuildChatLine extends StatefulWidget {
  final String message;
  final String type;
  final String name;
  final String idUser;
  final int hour;
  final int min;
  final int color;
  final bool isMe;
  final bool seen;
  final bool isLast;
  final Timestamp publishAt;
  final index;

  BuildChatLine(
      {this.message,
      this.type,
      this.name,
      this.hour,
      this.min,
      this.publishAt,
      this.isMe,
      this.seen,
      this.isLast,
      this.index,
      this.idUser,
      this.color});

  @override
  State<StatefulWidget> createState() => _BuildChatLineState();
}

class _BuildChatLineState extends State<BuildChatLine> {
  String time = '';
  bool showTime = false;
  int secondLeft = 0;

  Future<void> _updateSeen() async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(widget.index);
      await transaction.update(widget.index, {
        'seen': true,
      });
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.seen == false && widget.isMe == false) {
      _updateSeen();
    }
    var dateTime = DateTime.now();
    DateTime datePublish = widget.publishAt.toDate();
    secondLeft = dateTime.difference(datePublish).inSeconds;
  }

  @override
  Widget build(BuildContext context) {
    final sizeWidth = MediaQuery.of(context).size.width;

    void setTime() {
      if (widget.hour < 10 && widget.min < 10) {
        setState(() {
          time = '0${widget.hour}:0${widget.min}';
        });
      } else if (widget.hour < 10) {
        setState(() {
          time = '0${widget.hour}:${widget.min}';
        });
      } else if (widget.min < 10) {
        setState(() {
          time = '${widget.hour}:0${widget.min}';
        });
      } else {
        setState(() {
          time = '${widget.hour}:${widget.min}';
        });
      }
    }

    Future<void> _deleteMessage() async {
      Firestore.instance.runTransaction((Transaction transaction) async {
        DocumentSnapshot snapshot = await transaction.get(widget.index);
        await transaction.update(widget.index, {
          'message': 'This message has been deleted.',
          'type': 'deleted',
        });
      });
    }

    return Row(
      mainAxisAlignment:
          widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (widget.type == 'image') {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PhotoViewer(
                        image: widget.message,
                      )));
            } else {
              setState(() {
                showTime = !showTime;
              });
              setTime();
            }
          },
          child: Column(
            crossAxisAlignment:
                widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  senderLayout(),
                  widget.isLast && widget.isMe
                      ? widget.seen
                          ? StreamBuilder(
                              stream: Firestore.instance
                                  .collection('users')
                                  .where('id', isEqualTo: widget.idUser)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (!snapshot.hasData) {
                                  return Container(
                                    height: 12.0,
                                    width: 12.0,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(widget.color)),
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.grey.shade400,
                                      size: 6.0,
                                    ),
                                    alignment: Alignment.center,
                                  );
                                }

                                String image =
                                    snapshot.data.documents[0]['urlToImage'];

                                return Container(
                                  height: 12.0,
                                  width: 12.0,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: image == ''
                                              ? AssetImage('images/avt.jpg')
                                              : NetworkImage(image),
                                          fit: BoxFit.cover)),
                                );
                              },
                            )
                          : Container(
                              height: 12.0,
                              width: 12.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(widget.color),
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 6.0,
                              ),
                              alignment: Alignment.center,
                            )
                      : Container(
                          height: 0.0,
                        ),
                ],
              ),
              showTime
                  ? Padding(
                      padding: EdgeInsets.only(
                          left: widget.isMe ? 0 : 8,
                          right: widget.isMe ? 14 : 0,
                          bottom: 4.0),
                      child: Text(
                        time,
                        style: TextStyle(fontSize: sizeWidth / 38),
                      ),
                    )
                  : Container(
                      height: 0.0,
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget senderLayout() {
    return Container(
      margin: EdgeInsets.only(
          top: 6.0, right: widget.isMe && widget.isLast == false ? 10 : 0),
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.65,
          maxHeight: MediaQuery.of(context).size.height * 0.4),
      decoration: BoxDecoration(
        color: widget.type == 'image'
            ? Colors.grey.shade200
            : widget.isMe
                ? Colors.grey.shade200
                : Colors.grey.shade300,
        borderRadius: widget.type == 'image'
            ? BorderRadius.all(Radius.circular(8.0))
            : BorderRadius.all(Radius.circular(30.0)),
      ),
      child: Padding(
        padding: widget.type == 'image'
            ? EdgeInsets.all(1.5)
            : EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        child: getMessage(),
      ),
    );
  }

  getMessage() {
    return widget.type != 'image'
        ? Text(
            widget.type == 'text'
                ? widget.message
                : widget.isMe
                    ? '${widget.message.replaceAll('username', 'You')}'
                    : '${widget.message.replaceAll('username', widget.name)}',
            style: TextStyle(
                color: widget.isMe ? Colors.grey.shade800 : Colors.black,
                fontSize: MediaQuery.of(context).size.width / 24,
                fontWeight: FontWeight.w400),
          )
        : widget.message != null
            ? CachedImage(url: widget.message)
            : Text("Error!");
  }
}
