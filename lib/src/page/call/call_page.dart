import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:project_message_demo/src/widget/general/photo_viewer.dart';
import 'package:sdp_transform/sdp_transform.dart';

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

  //VideoCallVariables
  RTCPeerConnection _peerConnection;
  MediaStream _localStream;
  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();
  bool isFrontCamera = true;
  int id = 12022000;

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
    _peerConnection.close();
    _localStream.dispose();
    _localRenderer.dispose();
    _timmerInstance.cancel();
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

    initRenderers();
    _createPeerConnection().then((pc) {
      _peerConnection = pc;
      _setRemoteDescription(
          jsonDecode(widget.info['sdp'])['sdp']['sdp'].toString());
    });
    startTimmer();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _timmerInstance.cancel();
    super.dispose();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void switchCamera() async {
    if (_localStream != null) {
      bool value = await _localStream.getVideoTracks()[0].switchCamera();
      while (value == this.isFrontCamera)
        value = await _localStream.getVideoTracks()[0].switchCamera();
      this.isFrontCamera = value;
    }
  }

  void _createAnswer() async {
    RTCSessionDescription description = await _peerConnection.createAnswer({
      'offerToReceiveVideo': 1,
      'offerToReceiveAudio': 1,
    });

    var session = parse(description.sdp);
    String sdp = write(session, null);
    await sendSdp(sdp);

    _peerConnection.setLocalDescription(description);

    _peerConnection.onIceCandidate = (event) => {
          sendCandidates(event.candidate.toString(), event.sdpMid.toString(),
              event.sdpMlineIndex),
        };
  }

  void _setRemoteDescription(sdp) async {
    RTCSessionDescription description = new RTCSessionDescription(sdp, 'offer');
    await _peerConnection.setRemoteDescription(description);
    _createAnswer();
  }

  _createPeerConnection() async {
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"},
      ]
    };

    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };

    _localStream = await _getUserMedia();

    RTCPeerConnection pc =
        await createPeerConnection(configuration, offerSdpConstraints);
    // if (pc != null) print(pc);
    pc.addStream(_localStream);

    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        print(json.encode({
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMlineIndex': e.sdpMlineIndex,
        }));
      }
    };

    pc.onIceConnectionState = (e) {
      print(e);
    };

    pc.onAddStream = (stream) {
      print('addStream: ' + stream.id);
      _remoteRenderer.srcObject = stream;
    };

    return pc;
  }

  String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future sendCandidates(
    String candidate,
    String sdpMid,
    int sdpMLineIndex,
  ) async {
    DatabaseReference _candidateRef = FirebaseDatabase().reference();
    String jsonString =
        '{"ice":{"candidate":${jsonEncode(candidate)},"sdpMid":$sdpMid,"sdpMlineIndex":$sdpMLineIndex}}';
    _candidateRef.child(getRandomString(20)).set({
      'sender': id,
      'message': jsonString,
    });
    setState(() {
      id++;
    });
    _candidateRef.remove();
  }

  Future sendSdp(
    String sdp,
  ) async {
    DatabaseReference _sdpRef = FirebaseDatabase().reference();
    String jsonString = '{"sdp":{"type":"answer","sdp":${jsonEncode(sdp)}}}';
    _sdpRef.child(getRandomString(20)).set({
      'sender': id,
      'message': jsonString,
    });
    setState(() {
      id++;
    });
    _sdpRef.remove();
  }

  _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      },
    };

    MediaStream stream = await navigator.getUserMedia(mediaConstraints);

    // _localStream = stream;
    _localRenderer.srcObject = stream;
    _localRenderer.mirror = false;

    // _peerConnection.addStream(stream);

    return stream;
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              children: [
                Container(
                  width: size.width,
                  height: size.height - size.width * .15,
                  child: _remoteRenderer.textureId == null
                      ? Container()
                      : FittedBox(
                          fit: BoxFit.cover,
                          child: new Center(
                            child: new SizedBox(
                              width: size.height * 1.34,
                              height: size.height,
                              child: new Transform(
                                transform: Matrix4.identity()..rotateY(0.0),
                                alignment: FractionalOffset.center,
                                child: new Texture(
                                    textureId: _remoteRenderer.textureId),
                              ),
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: 40.0,
                  left: 15.0,
                  child: Column(
                    children: [
                      Text(
                        _timmer,
                        style: TextStyle(
                          color: _remoteRenderer.textureId == null
                              ? Colors.white
                              : Colors.black,
                          fontSize: size.width / 26.5,
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Container(
                        height: size.width * .54,
                        width: size.width * .32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                          border:
                              Border.all(color: Colors.blueAccent, width: 2.0),
                        ),
                        child: _localRenderer.textureId == null
                            ? Container()
                            : SizedBox(
                                width: size.height,
                                height: size.height,
                                child: new Transform(
                                  transform: Matrix4.identity()
                                    ..rotateY(
                                      isFrontCamera ? -pi : 0.0,
                                    ),
                                  alignment: FractionalOffset.center,
                                  child: new Texture(
                                      textureId: _localRenderer.textureId),
                                ),
                              ),
                      ),
                      SizedBox(
                        height: 12.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PhotoViewer(
                                image: widget.info['urlToImage'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: size.width * .3,
                          width: size.width * .3,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0)),
                            border: Border.all(
                                color: Colors.blueAccent, width: 2.0),
                            image: DecorationImage(
                              image: widget.info['urlToImage'] == ''
                                  ? AssetImage('images/avt.jpg')
                                  : NetworkImage(widget.info['urlToImage']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          switchCamera();
                        },
                        child: Container(
                          height: size.width * .125,
                          width: size.width * .125,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.0)),
                            border: Border.all(
                                color: Colors.blueAccent, width: 2.0),
                            color: Colors.blueAccent,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.switch_camera,
                            color: Colors.white,
                            size: size.width / 14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () async {
                      await _responce('Reject');
                    },
                    child: Container(
                      height: size.width * .15,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: size.width / 14.0,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () async {
                      await _responce('Accept');
                    },
                    child: Container(
                      height: size.width * .15,
                      decoration: BoxDecoration(
                        color: Colors.green,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: size.width / 14.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
