import 'package:flutter/material.dart';
import 'package:project_message_demo/src/animation/fade_animation.dart';
import 'package:project_message_demo/src/service/auth.dart';
import 'package:project_message_demo/src/widget/general/loading.dart';

class ForgotPage extends StatefulWidget {
  @override
  _ForgotPageState createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  final _formKey = GlobalKey<FormState>();
  String email;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final sizeHeight = MediaQuery.of(context).size.height;
    final sizeWidth = MediaQuery.of(context).size.width;
    final AuthService _auth = AuthService();

    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: sizeHeight / 3,
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: sizeHeight / 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  FadeAnimation(
                                      1.5,
                                      Text(
                                        "Reset PW",
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30),
                                      )),
                                  FadeAnimation(
                                    1.5,
                                    IconButton(
                                      icon: Icon(
                                        Icons.exit_to_app,
                                        color: Colors.white,
                                        size: sizeWidth / 12,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop(context);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              FadeAnimation(
                                  1.7,
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color.fromRGBO(
                                                196, 135, 198, .3),
                                            blurRadius: 20,
                                            offset: Offset(0, 10),
                                          )
                                        ]),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          child: TextFormField(
                                            validator: (val) => val.length == 0
                                                ? 'Enter email'
                                                : null,
                                            onChanged: (val) =>
                                                email = val.trim(),
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: "Email",
                                                hintStyle: TextStyle(
                                                    color: Colors.grey)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                              SizedBox(
                                height: 20.0,
                              ),
                              FadeAnimation(
                                  1.9,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () async {
                                          if (_formKey.currentState
                                              .validate()) {
                                            setState(() {
                                              loading = true;
                                            });
                                            dynamic result = await _auth
                                                .sendPasswordResetEmail(email);
                                            if (result == null) {
                                              setState(() {
                                                loading = false;
                                              });
                                            } else {
                                              Navigator.of(context)
                                                  .pop(context);
                                            }
                                          }
                                        },
                                        child: Container(
                                          height: 50,
                                          width: 130.0,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 60),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            color: Colors.deepPurple[600],
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Request",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
