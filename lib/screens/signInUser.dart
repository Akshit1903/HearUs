import 'package:HearUs/main.dart';
import 'package:HearUs/screens/listenerLoginNew.dart';
import 'package:HearUs/screens/signUpUser.dart';
import 'package:HearUs/services/auth.dart';
import 'package:HearUs/services/database.dart';
import 'package:HearUs/style/colors.dart';
import 'package:HearUs/util/sharedPrefHelper.dart';
import 'package:HearUs/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ListenerState {
  bool isListener = false;
  bool getisListener() {
    return isListener;
  }
}

class SignInUserPage extends StatefulWidget {
  final AuthMethods auth;
  SignInUserPage({this.auth});
  @override
  _SignInUserPageState createState() => _SignInUserPageState();
}

class _SignInUserPageState extends State<SignInUserPage> {
  final _formKey = GlobalKey<FormState>();
  String error = '';

  bool isLoading = false;

  // text field state
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: size.height,
            width: size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: size.height * 0.15,
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Image.asset('assets/HearUs_White.png',
                      fit: BoxFit.fitHeight),
                ),
                Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Text(
                      'Sign In',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.alegreya(
                          textStyle: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    )),
                Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Text(
                      'Hear Us - Here to Hear you',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.alegreyaSans(
                          textStyle: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.normal)),
                    )),
                SizedBox(height: size.height * 0.1),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                            ),
                        child: TextFormField(
                          style: GoogleFonts.alegreyaSans(
                            textStyle: TextStyle(
                              color: Color(0xFFBEC2C2),
                            ),
                          ),
                          validator: (val) =>
                              val.isEmpty ? 'Enter an email' : null,
                          onChanged: (val) {
                            setState(() => email = val);
                          },
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              hintStyle: GoogleFonts.alegreyaSans(
                                textStyle: TextStyle(
                                  color: Color(0xFFBEC2C2),
                                ),
                              ),
                              hintText: 'Enter Email',
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 10, 10)),
                        ),
                      ),
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: TextFormField(
                          style: GoogleFonts.alegreyaSans(
                            textStyle: TextStyle(
                              color: Color(0xFFBEC2C2),
                            ),
                          ),
                          obscureText: true,
                          validator: (val) => val.length < 6
                              ? 'Enter a password 6+ chars long'
                              : null,
                          onChanged: (val) {
                            setState(() => password = val);
                          },
                          decoration: InputDecoration(
                              hintStyle: GoogleFonts.alegreyaSans(
                                textStyle: TextStyle(
                                  color: Color(0xFFBEC2C2),
                                ),
                              ),
                              hintText: 'Enter Password',
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 0, 10, 0)),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: button1('LOGIN', AppColor().buttonColor, context,
                            () async {
                          setState(() {
                            isLoading = true;
                          });
                          if (_formKey.currentState.validate()) {
                            print("email : $email password: $password");
                            await widget.auth
                                .signInUser(email, password, context)
                                .then((value) {
                              if (value == null) {
                                setState(() {
                                  isLoading = false;
                                  ListenerState().isListener = false;
                                  error =
                                      'Could not sign in with those credentials';
                                });
                              } else {
                                print("User recieved is ${value.uid}");
                                setState(() {
                                  isLoading = false;
                                  ListenerState().isListener = false;
                                });
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(value.uid)
                                    .get()
                                    .then((val) {
                                  if (val.exists) {
                                    print(
                                        "The user has all ready signed in once ${val.data().toString()}");
                                    print(
                                        "Registered userid from user.uid is ${value.uid}");
                                    print(
                                        "Registered username from firebase is ${val.data()["username"]}");
                                    print(
                                        "Registered userid from firebase is ${val.data()["id"]}");

                                    // Saving the credentials in SharedPreferences...
                                    print(
                                        "Saving the credentials in SharedPreferences...");
                                    SharedPreferenceHelper()
                                        .saveUserId(value.uid)
                                        .whenComplete(() {
                                      print(
                                          "Registered UserId saved ${value.uid}");
                                    });
                                    SharedPreferenceHelper()
                                        .saveUserName(val.data()["username"])
                                        .whenComplete(() {
                                      print(
                                          "Registered Username saved ${val.data()["username"]}");
                                    });
                                    SharedPreferenceHelper().saveUserProfileUrl(
                                        "https://firebasestorage.googleapis.com/v0/b/hearus-4f2fe.appspot.com/o/assets%2Fhu_white.png?alt=media&token=6bddb58c-fd3f-4af7-8a17-3b2e7104af7d");

                                    // Geting FCM token...
                                    String fcmToken;
                                    FirebaseMessaging.instance
                                        .getToken()
                                        .then((token) async {
                                      print(token);
                                      fcmToken = token;
                                      await SharedPreferenceHelper()
                                          .saveUserFcmToken(token)
                                          .then((value) {
                                        if (value) {
                                          print('token saved successfully!');
                                        } else {
                                          print('token could not be saved!');
                                        }
                                      });
                                    }).whenComplete(() {
                                      DatabaseMethods()
                                          .addFcmToken(
                                              val.data()["id"], fcmToken, false)
                                          .whenComplete(() {
                                        print("fcm token added to firebase");
                                      });
                                    });
                                  }
                                }).whenComplete(() {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          settings:
                                              RouteSettings(name: "MyApp"),
                                          builder: (context) =>
                                              MyApp(auth: widget.auth)),
                                      (route) => false);
                                });
                              }
                            });
                          } else {
                            setState(() {
                              isLoading = false;
                              error = 'Some problem with the details entered!';
                            });
                          }
                        }),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  width: size.width,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Don\'t have an account ?   ',
                            style: GoogleFonts.alegreyaSans(
                                textStyle: TextStyle(
                                    fontSize: 17,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300)),
                            textAlign: TextAlign.center),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpUserPage()));
                          },
                          child: Text(
                            'SignUp',
                            style: GoogleFonts.alegreyaSans(
                              textStyle: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Register as a Listener ?  ',
                          style: GoogleFonts.alegreyaSans(
                              textStyle: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300)),
                          textAlign: TextAlign.center),
                      InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ListenerLoginNew(auth: widget.auth))),
                        child: Text(
                          'Click Here',
                          style: GoogleFonts.alegreyaSans(
                            textStyle: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: isLoading,
            child: Container(
                width: size.width,
                height: size.height,
                color: Colors.black38,
                child: LinearProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColor().buttonColor))),
          ),
        ],
      ),
    );
  }
}
