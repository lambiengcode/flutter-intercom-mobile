import 'package:flutter/material.dart';

class InputBottom extends StatefulWidget {
  final bool request;

  InputBottom({this.request});

  @override
  State<StatefulWidget> createState() => _InputBottomState();
}

class _InputBottomState extends State<InputBottom> {
  @override
  Widget build(BuildContext context) {
    return widget.request ? _requestType(context) : _receiveType(context);
  }

  Widget _requestType(context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.redAccent,
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 18.0),
              child: Text(
                'False',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: size.width / 24.0,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(color: Colors.blueAccent),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 18.0),
              child: Text(
                'True',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: size.width / 24.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiveType(context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey,
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 14.0),
              child: Icon(
                Icons.image,
                size: size.width / 14.0,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(color: Colors.blueAccent),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 14.0),
              child: Icon(
                Icons.camera_alt,
                size: size.width / 14.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
