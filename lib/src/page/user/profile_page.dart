import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_message_demo/src/model/user.dart';
import 'package:project_message_demo/src/service/auth.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File _image;
  String _username = '';
  final _formKey = GlobalKey<FormState>();
  String _password = '';

  Future<String> _uploadImage(file, uid, key) async {
    String fileName = uid;
    StorageReference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('key')
        .child('Profile')
        .child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(file);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    var downUrl = await taskSnapshot.ref.getDownloadURL();
    String url = downUrl.toString();
    return url;
  }

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);
    setState(() {
      _image = selected;
    });
  }

  Future<void> _updateProfile(index, username, urlToImage, uid) async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(index);
      String key = snapshot['key'];
      await transaction.update(index, {
        'username': _username == '' ? username : _username,
        'urlToImage':
            _image == null ? urlToImage : await _uploadImage(_image, uid, key),
      });
    });
  }

  void _changePassword(String password) async {
    //Create an instance of the current user.
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    //Pass in the password to updatePassword.
    user.updatePassword(password).then((_) {
      print("Succesfull changed password");
    }).catchError((error) {
      print("Password can't be changed" + error.toString());
      //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
    });
  }

  void _showChangePasswordDialog(sizeWidth, sizeHeight) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(
            30.0,
          ))),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      30.0,
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.grey[200]))),
                        child: TextFormField(
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: sizeWidth / 26.0,
                            fontWeight: FontWeight.w400,
                          ),
                          onChanged: (val) => _password = val.trim(),
                          validator: (val) => val.length < 6
                              ? 'Password must be least 6 characters'
                              : null,
                          obscureText: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(
                              left: 4.0,
                            ),
                            border: InputBorder.none,
                            hintText: "New Password",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: sizeWidth / 26.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        child: TextFormField(
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: sizeWidth / 26.0,
                            fontWeight: FontWeight.w400,
                          ),
                          validator: (val) => val.trim() != _password.trim()
                              ? 'Password do not match'
                              : null,
                          obscureText: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(
                              left: 4.0,
                            ),
                            border: InputBorder.none,
                            hintText: "Confirm Password",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: sizeWidth / 26.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 6.0,
                ),
                GestureDetector(
                  onTap: () async {
                    if (_formKey.currentState.validate()) {
                      _changePassword(_password);
                      Navigator.of(context).pop(context);
                    }
                  },
                  child: Container(
                    height: sizeHeight * 0.065,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        30.0,
                      ),
                      color: Colors.blueAccent,
                    ),
                    child: Center(
                      child: Text(
                        "Confirm",
                        style: TextStyle(
                          color: Colors.white.withOpacity(.88),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizeWidth = MediaQuery.of(context).size.width;
    final sizeHeight = MediaQuery.of(context).size.height;
    final user = Provider.of<User>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 1.5,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Feather.arrow_left,
            color: Colors.grey.shade800,
            size: sizeWidth / 14.5,
          ),
          onPressed: () {
            Navigator.of(context).pop(context);
          },
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: sizeWidth / 18.8,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
            height: 2,
          ),
        ),
        actions: <Widget>[
          StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .where('id', isEqualTo: user.uid)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return IconButton(
                  icon: Icon(
                    Feather.refresh_cw,
                    size: sizeWidth / 14.5,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {},
                );
              }

              String username = snapshot.data.documents[0]['username'];
              String urlToImage = snapshot.data.documents[0]['urlToImage'];

              return IconButton(
                icon: Icon(
                  Feather.check,
                  size: sizeWidth / 14.5,
                  color: Colors.blueAccent,
                ),
                onPressed: () async {
                  await _updateProfile(snapshot.data.documents[0].reference,
                      username, urlToImage, user.uid);
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        height: sizeHeight,
        width: sizeWidth,
        color: Colors.white,
        child: StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .where('id', isEqualTo: user.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            String username = snapshot.data.documents[0]['username'];
            String urlToImage = snapshot.data.documents[0]['urlToImage'];
            String phone = snapshot.data.documents[0]['phone'];
            String dept = snapshot.data.documents[0]['dept'];

            return ListView(
              children: <Widget>[
                SizedBox(
                  height: 18.0,
                ),
                GestureDetector(
                  onTap: () async {
                    try {
                      await _pickImage(ImageSource.gallery);
                    } on Exception catch (_) {
                      throw Exception('Error');
                    }
                  },
                  child: Container(
                    height: sizeWidth / 2.75,
                    width: sizeWidth / 2.75,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFFBFBEBF),
                        width: .5,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      height: sizeWidth / 3,
                      width: sizeWidth / 3,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFFBFBEBF),
                          width: .5,
                        ),
                        image: DecorationImage(
                          image: _image != null
                              ? FileImage(_image)
                              : urlToImage == ''
                                  ? AssetImage('images/avt.jpg')
                                  : NetworkImage(urlToImage),
                          fit: BoxFit.cover,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        height: sizeWidth / 3,
                        width: sizeWidth / 3,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: sizeWidth / 12.8,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: sizeWidth / 24.0,
                          fontWeight: FontWeight.w400,
                        ),
                        initialValue: username,
                        validator: (val) =>
                            val.length == 0 ? 'Enter Username' : null,
                        onChanged: (val) => _username = val.trim(),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 2.0),
                          labelText: 'Name',
                          labelStyle: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: sizeWidth / 24.0,
                            fontWeight: FontWeight.w400,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: .6,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: .6,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 22.0,
                      ),
                      TextFormField(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: sizeWidth / 24.0,
                          fontWeight: FontWeight.w400,
                        ),
                        initialValue: phone,
                        validator: (val) =>
                            val.length == 0 ? 'Enter your Phone' : null,
                        decoration: InputDecoration(
                          enabled: false,
                          contentPadding: EdgeInsets.only(top: 2.0),
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: sizeWidth / 24.0,
                            fontWeight: FontWeight.w400,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: .6,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: .6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: sizeWidth / 24.0,
                          fontWeight: FontWeight.w400,
                        ),
                        initialValue: dept,
                        validator: (val) =>
                            val.length == 0 ? 'Enter your Phone' : null,
                        decoration: InputDecoration(
                          enabled: false,
                          contentPadding: EdgeInsets.only(top: 2.0),
                          labelText: 'Department',
                          labelStyle: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: sizeWidth / 24.0,
                            fontWeight: FontWeight.w400,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: .6,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: .6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 24.0,
                ),
                GestureDetector(
                  onTap: () async {
                    AuthService _auth = AuthService();
                    Navigator.of(context).pop(context);
                    await _auth.signOut();
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    height: 55.0,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'SignOut',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: sizeWidth / 25.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 12.0,
                ),
                GestureDetector(
                  onTap: () {
                    _showChangePasswordDialog(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Change your password',
                        style: TextStyle(
                          color: Colors.deepPurple[800],
                          fontSize: sizeWidth / 26.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        width: 4.0,
                      ),
                      Icon(
                        Feather.arrow_right,
                        color: Colors.deepPurple[800],
                        size: sizeWidth / 22.5,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
