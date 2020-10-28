import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CallPage extends StatefulWidget {
  final String idSend;
  final DocumentSnapshot info;
  final index;

  CallPage({this.idSend, this.index, this.info});

  @override
  State<StatefulWidget> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  Timer _timmerInstance;
  int _start = 0;
  String _timmer = '';

  void startTimmer() {
    var oneSec = Duration(seconds: 1);
    _timmerInstance = Timer.periodic(
        oneSec,
        (Timer timer) => setState(() {
              if (_start < 0) {
                _timmerInstance.cancel();
              } else {
                _start = _start + 1;
                _timmer = getTimerTime(_start);
              }
            }));
  }

  String getTimerTime(int start) {
    int minutes = (start ~/ 60);
    String sMinute = '';
    if (minutes.toString().length == 1) {
      sMinute = '0' + minutes.toString();
    } else
      sMinute = minutes.toString();

    int seconds = (start % 60);
    String sSeconds = '';
    if (seconds.toString().length == 1) {
      sSeconds = '0' + seconds.toString();
    } else
      sSeconds = seconds.toString();

    return sMinute + ':' + sSeconds;
  }

  Future<void> _responce(responce) async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(widget.index);
      await transaction.update(widget.index, {
        'completed': true,
        'responce': responce,
        'responcedTime': DateTime.now(),
      });
    });
  }

  @override
  void initState() {
    super.initState();
    startTimmer();
  }

  @override
  void dispose() {
    _timmerInstance.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: size.height * 0.12,
            ),
            StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .where('id', isEqualTo: widget.idSend)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }

                return Column(
                  children: [
                    Text(
                      _timmer,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: size.width / 18.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      height: size.height * .46,
                      width: size.width * .76,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(
                          16.0,
                        )),
                        image: DecorationImage(
                          image: widget.info['urlToImage'] == ''
                              ? AssetImage('images/avt.jpg')
                              : NetworkImage(
                                  widget.info['urlToImage'],
                                ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      snapshot.data.documents[0]['username'],
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: size.width / 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: size.height * .1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await _responce('Reject');
                          },
                          child: Container(
                            height: size.width * .18,
                            width: size.width * .18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: size.width / 14.0,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await _responce('Accept');
                          },
                          child: Container(
                            height: size.width * .18,
                            width: size.width * .18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: size.width / 14.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
