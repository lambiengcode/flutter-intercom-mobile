import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReceiveCallPage extends StatefulWidget {
  final String idSend;
  final index;

  ReceiveCallPage({this.idSend, this.index});

  @override
  State<StatefulWidget> createState() => _ReceiveCallPageState();
}

class _ReceiveCallPageState extends State<ReceiveCallPage> {
  final assetsAudioPlayer = AssetsAudioPlayer();
  Future<void> _responce(bool accept) async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(widget.index);
      await transaction.update(widget.index, {
        'request': false,
        'completed': !accept,
      });
    });
    assetsAudioPlayer.stop();
  }

  playLocal() async {
    try {
      await assetsAudioPlayer.open(
        Audio('assets/calling.mp3'),
        loopMode: LoopMode.single,
      );
    } catch (t) {
      //stream unreachable
    }
  }

  @override
  void initState() {
    super.initState();
    playLocal();
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
              height: size.height * 0.15,
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
                      'Calling...',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontSize: size.width / 18.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      height: size.height * .18,
                      width: size.height * .18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(
                          20.0,
                        )),
                        image: DecorationImage(
                          image: snapshot.data.documents[0]['urlToImage'] == ''
                              ? AssetImage('images/avt.jpg')
                              : NetworkImage(
                                  snapshot.data.documents[0]['urlToImage'],
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
                      height: size.height * .32,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await _responce(false);
                          },
                          child: Container(
                            height: size.width * .18,
                            width: size.width * .18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
                            ),
                            child: Icon(
                              Icons.call_end,
                              color: Colors.white,
                              size: size.width / 18.0,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await _responce(true);
                          },
                          child: Container(
                            height: size.width * .18,
                            width: size.width * .18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                            child: Icon(
                              Icons.call,
                              color: Colors.white,
                              size: size.width / 18.0,
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
