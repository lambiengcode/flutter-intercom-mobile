import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:project_message_demo/src/animation/fade_animation.dart';
import 'package:project_message_demo/src/model/user.dart';
import 'package:project_message_demo/src/page/user/profile_page.dart';
import 'package:project_message_demo/src/widget/receive_widget/inbox_list.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ReceivePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  DateTime _fromDate;
  DateTime _toDate;
  List<String> _states = [
    'All',
    'Accept',
    'Reject',
    'Missing',
    'Rejected Call',
  ];
  String _state;
  String _from;
  String _to;

  @override
  void initState() {
    super.initState();
    _toDate = DateTime.now();
    _fromDate = _toDate.subtract(Duration(days: 14));
    _from = DateFormat('dd/MM/yyyy').format(_fromDate);
    _to = DateFormat('dd/MM/yyyy').format(_toDate);
    _state = _states[0];
  }

  Future<void> _selectDateFrom(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _fromDate,
        firstDate: DateTime(2020, 10),
        lastDate: DateTime.now());
    if (picked != null &&
        picked != _fromDate &&
        _toDate.compareTo(_fromDate) != -1)
      setState(() {
        _fromDate = picked;
        _from = DateFormat('dd/MM/yyyy').format(_fromDate);
      });

    Navigator.of(context).pop(context);
    showFilterBottomSheet();
  }

  Future<void> _selectDateTo(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _toDate,
        firstDate: DateTime(2020, 10),
        lastDate: DateTime.now());
    if (picked != null &&
        picked != _toDate &&
        _toDate.compareTo(_fromDate) != -1)
      setState(() {
        _toDate = picked;
        _to = DateFormat('dd/MM/yyyy').format(_toDate);
      });
    Navigator.of(context).pop(context);
    showFilterBottomSheet();
  }

  void showFilterBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12.0),
        ),
      ),
      context: context,
      builder: (context) {
        return _filterBottomSheet(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2.0,
        centerTitle: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
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

                return Row(
                  children: [
                    CircleAvatar(
                        backgroundImage: urlToImage == ''
                            ? AssetImage('images/avt.jpg')
                            : NetworkImage(urlToImage),
                        radius: 16.96),
                    SizedBox(
                      width: 6.8,
                    ),
                    Text(
                      "History",
                      style: TextStyle(
                        fontSize: size.width / 18.25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                );
              },
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
            onPressed: () {
              showFilterBottomSheet();
            },
          ),
          SizedBox(
            width: 4.0,
          ),
          IconButton(
            icon: Icon(
              Feather.settings,
              size: size.width / 16.0,
              color: Colors.grey.shade800,
            ),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EditProfilePage()));
            },
          ),
          SizedBox(
            width: 4.0,
          ),
        ],
      ),
      body: Container(
        height: size.height,
        width: size.width,
        child: Column(
          children: [
            SizedBox(
              height: 12.0,
            ),
            Expanded(
              child: StreamBuilder(
                stream: _state == 'All'
                    ? Firestore.instance
                        .collection('requests')
                        .where('receiveID', isEqualTo: user.uid)
                        .snapshots()
                    : Firestore.instance
                        .collection('requests')
                        .where('receiveID', isEqualTo: user.uid)
                        .where('responce', isEqualTo: _state)
                        .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  List<DocumentSnapshot> docs = snapshot.data.documents;

                  for (int i = 0; i < docs.length; i++) {
                    Timestamp t1 = docs[i]['publishAt'];
                    DateTime publishAt = t1.toDate();

                    if (_toDate.compareTo(publishAt) == -1 ||
                        _fromDate.compareTo(publishAt) == 1) {
                      docs.removeAt(i);
                    }
                  }

                  for (int i = 0; i < docs.length - 1; i++) {
                    for (int j = 0; j < docs.length - 1 - i; j++) {
                      Timestamp t1 = docs[j]['responcedTime'];
                      Timestamp t2 = docs[j + 1]['responcedTime'];
                      if (t1.compareTo(t2) == -1) {
                        DocumentSnapshot temp = docs[j];
                        docs[j] = docs[j + 1];
                        docs[j + 1] = temp;
                      }
                    }
                  }

                  return FadeAnimation(
                    .25,
                    InboxList(
                      documents: docs,
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _filterBottomSheet(context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height * .3,
      child: Column(
        children: [
          SizedBox(
            height: 28.0,
          ),
          Row(
            children: [
              SizedBox(
                width: 20.0,
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'From',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: size.width / 23.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTap: () async {
                    _selectDateFrom(context);
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 18.0,
                      right: 12.0,
                      top: 12.0,
                      bottom: 12.0,
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      color: Colors.grey.shade50,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFABBAD5),
                          spreadRadius: .8,
                          blurRadius: 2.0,
                          offset: Offset(0, 2.0), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _from,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: size.width / 28.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Icon(
                          Feather.calendar,
                          size: size.width / 20,
                          color: Colors.grey.shade700,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 20.0,
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'To',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: size.width / 23.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTap: () async {
                    await _selectDateTo(context);
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 18.0,
                      right: 12.0,
                      top: 12.0,
                      bottom: 12.0,
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      color: Colors.grey.shade50,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFABBAD5),
                          spreadRadius: .8,
                          blurRadius: 2.0,
                          offset: Offset(0, 2.0), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _to,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: size.width / 28.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Icon(
                          Feather.calendar,
                          size: size.width / 20,
                          color: Colors.grey.shade700,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 20.0,
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'State',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: size.width / 22.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  padding: EdgeInsets.only(left: 18.0, right: 12.0),
                  margin: EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    color: Colors.grey.shade50,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFABBAD5),
                        spreadRadius: .8,
                        blurRadius: 2.0,
                        offset: Offset(0, 2.0), // changes position of shadow
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField(
                      icon: Icon(
                        Feather.hash,
                        size: size.width / 20,
                        color: Colors.grey.shade700,
                      ),
                      iconEnabledColor: Colors.grey.shade800,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      value: _state,
                      items: _states.map((state) {
                        return DropdownMenuItem(
                            value: state,
                            child: Text(
                              state,
                              style: TextStyle(
                                fontSize: size.width / 24,
                                color: Colors.grey.shade800,
                              ),
                            ));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _state = val;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
