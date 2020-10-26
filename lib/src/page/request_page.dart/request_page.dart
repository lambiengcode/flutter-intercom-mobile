import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:project_message_demo/src/model/user.dart';
import 'package:project_message_demo/src/widget/search_widget/user_card.dart';
import 'package:provider/provider.dart';

class RequestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  String searchKey = '';
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 2.0,
        title: Row(
          children: <Widget>[
            StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .where('id', isEqualTo: user.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }

                String urlToImage = snapshot.data.documents[0]['urlToImage'];

                return CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  radius: 16.98,
                  child: CircleAvatar(
                    backgroundImage: urlToImage == ''
                        ? AssetImage('images/avt.jpg')
                        : NetworkImage(urlToImage),
                    radius: 16.88,
                  ),
                );
              },
            ),
            Expanded(
              child: TextFormField(
                autofocus: true,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: size.width / 22.8,
                  fontWeight: FontWeight.w400,
                ),
                onChanged: (val) {
                  setState(() {
                    searchKey = val.trim();
                  });
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 16.0),
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: size.width / 22.5,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Feather.sliders,
              size: size.width / 16.0,
              color: Colors.grey.shade800,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: searchKey.length == 0
          ? Container()
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .orderBy('username', descending: false)
                  .limit(200)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                List<DocumentSnapshot> docs = snapshot.data.documents;

                for (int i = 0; i < docs.length; i++) {
                  if (docs[i]['phone']
                      .toString()
                      .toLowerCase()
                      .startsWith(searchKey.toLowerCase())) {
                    continue;
                  } else {
                    docs.removeAt(i);
                  }
                }

                for (int i = 0; i < docs.length; i++) {
                  if (user.uid == docs[i]['id']) {
                    docs.removeAt(i);
                  }
                }

                return docs.length == 0
                    ? Container(
                        height: 0.0,
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(top: 12.5),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          return UserCard(
                            user: docs[index],
                          );
                        },
                      );
              },
            ),
    );
  }
}
