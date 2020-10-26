import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:project_message_demo/src/model/user.dart';
import 'package:project_message_demo/src/service/auth.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
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
            Feather.check,
            size: sizeWidth / 14.5,
            color: Colors.blueAccent,
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
          IconButton(
            icon: Icon(
              Feather.log_out,
              size: sizeWidth / 14.5,
              color: Colors.grey.shade800,
            ),
            onPressed: () async {
              AuthService _auth = AuthService();
              await _auth.signOut();
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

            return ListView(
              children: <Widget>[
                SizedBox(
                  height: 18.0,
                ),
                Container(
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
                        image: NetworkImage(urlToImage),
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
                            val.length == 0 ? 'Enter your Email' : null,
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
                  height: 40.0,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
