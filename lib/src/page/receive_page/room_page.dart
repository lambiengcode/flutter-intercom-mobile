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
  String _hour;
  String _hourPublishAt;
  Color _color;

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

    if (responcedTime.hour < 10 && responcedTime.minute < 10) {
      _hour =
          '0${responcedTime.hour}:0${responcedTime.minute}:${responcedTime.second}';
    } else if (responcedTime.hour < 10) {
      _hour =
          '0${responcedTime.hour}:${responcedTime.minute}:${responcedTime.second}';
    } else if (responcedTime.minute < 10) {
      _hour =
          '${responcedTime.hour}:0${responcedTime.minute}:${responcedTime.second}';
    } else {
      _hour =
          '${responcedTime.hour}:${responcedTime.minute}:${responcedTime.second}';
    }

    if (publishAt.hour < 10 && publishAt.minute < 10) {
      _hourPublishAt =
          '0${publishAt.hour}:0${publishAt.minute}:${publishAt.second}';
    } else if (publishAt.hour < 10) {
      _hourPublishAt =
          '0${publishAt.hour}:${publishAt.minute}:${publishAt.second}';
    } else if (responcedTime.minute < 10) {
      _hourPublishAt =
          '${publishAt.hour}:0${publishAt.minute}:${publishAt.second}';
    } else {
      _hourPublishAt =
          '${publishAt.hour}:${publishAt.minute}:${publishAt.second}';
    }
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
                  width: 12.0,
                ),
                IconButton(
                  icon: Icon(
                    Feather.minimize_2,
                    color: Colors.grey.shade700,
                    size: size.width / 18.0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(context);
                  },
                ),
                SizedBox(
                  width: 16.0,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: Text(
                    'Details',
                    style: TextStyle(
                      fontSize: size.width / 20.0,
                      color: Colors.grey.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                      text: 'Responce\t\t=\t\t',
                      style: TextStyle(
                        fontSize: size.width / 22.5,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: widget.responce,
                      style: TextStyle(
                        fontSize: size.width / 23.5,
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
                      text: 'Responced Time\t:\t\t',
                      style: TextStyle(
                        fontSize: size.width / 22.5,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          '$_hour - ${responcedTime.day}/${responcedTime.month}/${responcedTime.year}',
                      style: TextStyle(
                        fontSize: size.width / 23.5,
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
                      text: 'PublishAt\t:\t\t',
                      style: TextStyle(
                        fontSize: size.width / 22.5,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          '$_hourPublishAt - ${publishAt.day}/${publishAt.month}/${publishAt.year}',
                      style: TextStyle(
                        fontSize: size.width / 23.5,
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
