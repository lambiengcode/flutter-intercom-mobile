import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_message_demo/src/model/user.dart';
import 'package:provider/provider.dart';

class InputBottom extends StatefulWidget {
  final bool request;
  final String idReceive;
  final String idRoom;
  final index;
  final bool available;

  InputBottom({
    this.request,
    this.idReceive,
    this.idRoom,
    this.index,
    this.available,
  });

  @override
  State<StatefulWidget> createState() => _InputBottomState();
}

class _InputBottomState extends State<InputBottom> {
  bool available = false;

  @override
  void initState() {
    super.initState();
    available = widget.available;
  }

  @override
  Widget build(BuildContext context) {
    return available == false
        ? _unAvailable(context)
        : widget.request
            ? _requestType(context)
            : _receiveType(context);
  }

  Future<void> _sendMessage(
    idSend,
    idReceive,
    id,
    message,
    type,
  ) async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      CollectionReference reference = Firestore.instance.collection("inboxs");
      await reference.add({
        'idSend': idSend,
        'idReceive': idReceive,
        'id': id,
        'publishAt': DateTime.now(),
        'message': message,
        'seen': false,
        'type': type,
        'hour': DateTime.now().hour,
        'min': DateTime.now().minute,
      });
    });

    setState(() {
      available = false;
    });
  }

  Future<void> _updateRoom() async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(widget.index);
      await transaction.update(widget.index, {
        'completed': true,
      });
    });
  }

  //receive
  Future<String> uploadImage(file) async {
    String fileName = DateTime.now().microsecondsSinceEpoch.toString();
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('Images').child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(file);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    var downUrl = await taskSnapshot.ref.getDownloadURL();
    String url = downUrl.toString();
    return url;
  }

  Future<void> _pickImage(ImageSource source, User user) async {
    File selected = await ImagePicker.pickImage(source: source);
    if (selected != null) {
      String message = await uploadImage(selected);
      await _sendMessage(
          user.uid, widget.idReceive, widget.idRoom, message, 'image');
    }
  }

  Widget _requestType(context) {
    Size size = MediaQuery.of(context).size;
    final user = Provider.of<User>(context);
    return Container(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () async {
                await _sendMessage(
                    user.uid, widget.idReceive, widget.idRoom, 'False', 'text');
              },
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
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () async {
                await _sendMessage(
                  user.uid,
                  widget.idReceive,
                  widget.idRoom,
                  'True',
                  'text',
                );
                await _updateRoom();
              },
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
          ),
        ],
      ),
    );
  }

  Widget _receiveType(context) {
    Size size = MediaQuery.of(context).size;
    final user = Provider.of<User>(context);
    return Container(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () async {
                try {
                  _pickImage(ImageSource.gallery, user);
                } on Exception catch (_) {
                  throw Exception('Error on server');
                }
              },
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
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () async {
                try {
                  _pickImage(ImageSource.camera, user);
                } on Exception catch (_) {
                  throw Exception('Error on server');
                }
              },
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
          ),
        ],
      ),
    );
  }

  Widget _unAvailable(context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.8),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 18.0),
      child: Text(
        'Waiting Reply',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: size.width / 26.5,
        ),
      ),
    );
  }
}
