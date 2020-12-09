import 'package:flutter/material.dart';
import 'package:project_message_demo/src/animation/fade_animation.dart';
import 'package:project_message_demo/src/service/auth.dart';
import 'package:project_message_demo/src/widget/general/loading.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();

  FocusNode textFieldFocus = FocusNode();
  String email = '';
  String password = '';

  bool hidePassword = true;
  bool loading = false;

  hideKeyboard() => textFieldFocus.unfocus();

  @override
  Widget build(BuildContext context) {
    final sizeHeight = MediaQuery.of(context).size.height;
    final sizeWidth = MediaQuery.of(context).size.width;

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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: sizeHeight * .18,
                        ),
                        Container(
                          height: sizeHeight * .26,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('images/background.jpg'),
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: sizeHeight * .1,
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: sizeWidth * 0.1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              FadeAnimation(
                                1.7,
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0),
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                        width: 1.2,
                                      )),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[200]))),
                                        child: TextFormField(
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: sizeWidth / 24,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          validator: (val) => val.length == 0
                                              ? 'Enter your Email'
                                              : null,
                                          onChanged: (val) =>
                                              email = val.trim(),
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.only(
                                              left: 12.0,
                                            ),
                                            border: InputBorder.none,
                                            hintText: "Email",
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontSize: sizeWidth / 24,
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
                                            fontSize: sizeWidth / 24,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          focusNode: textFieldFocus,
                                          validator: (val) => val.length == 0
                                              ? 'Enter your password'
                                              : null,
                                          onChanged: (val) =>
                                              password = val.trim(),
                                          obscureText: hidePassword,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.only(
                                              left: 12.0,
                                            ),
                                            border: InputBorder.none,
                                            hintText: "Password",
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontSize: sizeWidth / 24,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 32,
                              ),
                              FadeAnimation(
                                1.9,
                                GestureDetector(
                                  onTap: () async {
                                    if (_formKey.currentState.validate()) {
                                      setState(() {
                                        loading = true;
                                      });
                                      dynamic result = await _auth
                                          .signInWithEmailAndPassword(
                                              email, password);
                                      if (result == null) {
                                        setState(() {
                                          loading = false;
                                        });
                                      } else {}
                                    }
                                  },
                                  child: Container(
                                    height: sizeHeight * 0.065,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0),
                                      color: Colors.blue,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Login",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(.88),
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 30,
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
