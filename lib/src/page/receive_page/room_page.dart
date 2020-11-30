import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';

class ChatRoomPage extends StatefulWidget {
  final String idRequest;
  final String idSend;
  final String idReceive;
  final String responce;
  final Timestamp publishAt;
  final Timestamp responcedTime;
  final String urlToImage;

  ChatRoomPage({
    this.idRequest,
    this.idSend,
    this.idReceive,
    this.publishAt,
    this.responcedTime,
    this.responce,
    this.urlToImage,
  });

  @override
  State<StatefulWidget> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  DateTime responcedTime;
  DateTime publishAt;
  String _publish;
  String _responced;
  Color _color;

  String checkDate(int input) {
    if (input < 10) {
      return '0$input';
    } else {
      return '$input';
    }
  }

  @override
  void initState() {
    super.initState();
    responcedTime = widget.responcedTime.toDate();
    publishAt = widget.publishAt.toDate();
    _color = widget.responce == 'Accept'
        ? Colors.green
        : widget.responce == 'Reject'
            ? Colors.blueAccent
            : widget.responce == 'Missing'
                ? Colors.redAccent
                : Colors.amber.shade700;

    _publish =
        '${checkDate(publishAt.hour)}:${checkDate(publishAt.minute)}:${checkDate(publishAt.second)} at ' +
            '${checkDate(publishAt.day)}/${checkDate(publishAt.month)}/${checkDate(publishAt.year)}';

    _responced =
        '${checkDate(responcedTime.hour)}:${checkDate(responcedTime.minute)}:${checkDate(responcedTime.second)} at ' +
            '${checkDate(responcedTime.day)}/${checkDate(responcedTime.month)}/${checkDate(responcedTime.year)}';
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      height: size.height * .77,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60.0,
            width: size.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 8.0,
                ),
                IconButton(
                  icon: Icon(
                    Feather.arrow_left,
                    color: Colors.grey.shade700,
                    size: size.width / 16.0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(context);
                  },
                ),
                SizedBox(
                  width: 24.0,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 2.0),
                  child: Text(
                    'State :',
                    style: TextStyle(
                      fontSize: size.width / 20.2,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Icon(
                  widget.responce == 'Accept'
                      ? Icons.check
                      : widget.responce == 'Reject'
                          ? Icons.close
                          : widget.responce == 'Missing'
                              ? Icons.call_missed
                              : Icons.call_end,
                  color: _color,
                  size: size.width / 16.0,
                ),
              ],
            ),
          ),
          Divider(
            height: .8,
            thickness: .8,
            color: Colors.grey.shade200,
          ),
          Container(
            height: size.height * .35,
            width: size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: widget.urlToImage == ''
                    ? AssetImage(
                        'images/avt.jpg',
                      )
                    : NetworkImage(
                        widget.urlToImage,
                      ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  overflow: TextOverflow.visible,
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'Responce\t\t:\t\t',
                      style: TextStyle(
                        fontSize: size.width / 24.0,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: widget.responce,
                      style: TextStyle(
                        fontSize: size.width / 24.0,
                        color: _color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]),
                ),
                SizedBox(
                  height: 12.0,
                ),
                RichText(
                  overflow: TextOverflow.visible,
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'Responses Time\t:\t',
                      style: TextStyle(
                        fontSize: size.width / 24.0,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: _responced,
                      style: TextStyle(
                        fontSize: size.width / 24.0,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]),
                ),
                SizedBox(
                  height: 12.0,
                ),
                RichText(
                  overflow: TextOverflow.visible,
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'PublishAt\t:\t',
                      style: TextStyle(
                        fontSize: size.width / 24.0,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: _publish,
                      style: TextStyle(
                        fontSize: size.width / 24.0,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
