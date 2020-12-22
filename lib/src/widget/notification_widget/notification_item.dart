import 'package:flutter/material.dart';

import '../general/photo_viewer.dart';

class NotificationItem extends StatefulWidget {
  final String title;
  final String body;
  final String urlToImage;
  NotificationItem({
    this.title,
    this.body,
    this.urlToImage,
  });
  @override
  State<StatefulWidget> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(
        top: 10.0,
      ),
      padding: EdgeInsets.only(
        left: 20.0,
        right: 8.0,
        bottom: 10.0,
      ),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        color: Colors.grey.shade300,
        width: .4,
      ))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: size.width / 20.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 4.0,
                ),
                Text(
                  widget.body,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: size.width / 25.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
          widget.urlToImage == ''
              ? Container()
              : GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PhotoViewer(
                          image: widget.urlToImage,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 55.0,
                    width: 55.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blueGrey.shade100,
                        width: 1.8,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(widget.urlToImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
