// ignore_for_file: unused_import, unused_field, unused_element, non_constant_identifier_names

import 'dart:async';

import 'package:HearUs/main.dart';
import 'package:HearUs/screens/errorPage.dart';
import 'package:HearUs/screens/listenerLoginNew.dart';
import 'package:HearUs/services/auth.dart';
import 'package:HearUs/services/database.dart';
import 'package:HearUs/services/google_sign_in.dart';
import 'package:HearUs/style/colors.dart';
import 'package:HearUs/style/fonts.dart';
import 'package:HearUs/util/sharedPrefHelper.dart';

import 'package:HearUs/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginNew extends StatefulWidget {
  final AuthMethods auth;
  LoginNew({this.auth});
  @override
  _LoginNewState createState() => _LoginNewState();
}

class _LoginNewState extends State<LoginNew> {
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
        setState(() => _connectionStatus = result.toString());
        break;
      case ConnectivityResult.none:
        _connectivitySubscription.cancel();
        setState(() => _connectionStatus = result.toString());
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                settings: RouteSettings(name: "Error Page"),
                builder: (context) => ErrorPage(
                    error:
                        'Please check your internet connectivity and restart the app!')),
            (route) => false);
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

  String newNickname = '';
  String whereHearInfo = '';
  String accessCode = "";

  void continueSignIn(user, value, userImage) {
    print("Saving the credentials in SharedPreferences...");
    SharedPreferenceHelper().saveUserId(user.id);
    SharedPreferenceHelper().saveUserEmail(user.email);
    print("accessCode final: $accessCode");
    if (newNickname == '') {
      SharedPreferenceHelper().saveUserName(value.data()["username"]);
      print("Registered Username saved ${value.data()["username"]}");
      Map<String, dynamic> userInfoMap = {
        "email": user.email,
        "username": value.data()["username"],
        "imageUrl": userImage,
        "online": true,
        "accessCode": accessCode,
        "hasMentor": (value.data()["hasMentor"] == null)
            ? false
            : value.data()["hasMentor"],
        "paidMoreListeners": (value.data()["paidMoreListeners"] == null)
            ? false
            : value.data()["paidMoreListeners"],
        "whereInfo": (value.data()["whereInfo"] == null ||
                value.data()["whereInfo"] == '')
            ? whereHearInfo
            : value.data()["whereInfo"],
        "typing": false,
        "feelOfDay": {
          "feel": 'happy',
          "date": DateTime.now().subtract(
            Duration(days: 1),
          ),
        }
      };

      // Geting FCM token...
      String fcmToken;
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .get()
          .then((value) {
        if (value.data()["hasMentor"] == null ||
            value.data()["paidMoreListeners"] == null ||
            value.data()["feelOfDay"] == null ||
            value.data()["whereInfo"] == null) {
          DatabaseMethods()
              .updateUserInfoToDB(user.id, userInfoMap)
              .whenComplete(() {
            FirebaseMessaging.instance.getToken().then((token) async {
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
                  .addFcmToken(value.data()["id"], fcmToken, false)
                  .whenComplete(() {
                print("fcm token added to firebase");
              });
            }).whenComplete(
              () {
                setState(() {
                  isLoading = false;
                });
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        settings: RouteSettings(name: "MyApp"),
                        builder: (context) => MyApp(auth: widget.auth)),
                    (route) => false);
              },
            );
          });
        } else {
          FirebaseMessaging.instance.getToken().then((token) async {
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
                .addFcmToken(value.data()["id"], fcmToken, false)
                .whenComplete(() {
              print("fcm token added to firebase");
            });
          }).whenComplete(
            () {
              setState(() {
                isLoading = false;
              });
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      settings: RouteSettings(name: "MyApp"),
                      builder: (context) => MyApp(auth: widget.auth)),
                  (route) => false);
            },
          );
        }
      });
    } else {
      SharedPreferenceHelper().saveUserName(newNickname).whenComplete(() {
        print("Registered Username saved $newNickname");
      });
      Map<String, dynamic> userInfoMap2 = {
        "email": user.email,
        "username": newNickname,
        "imageUrl": userImage,
        "online": true,
        "hasMentor": false,
        "whereInfo": whereHearInfo,
        "typing": false,
        "accessCode": accessCode,
        // "paidMoreListeners": false,
        "feelOfDay": {
          "feel": 'happy',
          "date": DateTime.now().subtract(
            Duration(days: 1),
          ),
        }
      };
      print('Userinfo map is :  ${userInfoMap2.toString()}');
      String fcmToken;
      FirebaseMessaging.instance.getToken().then((token) async {
        print(token);
        fcmToken = token;
        await SharedPreferenceHelper().saveUserFcmToken(token).then((value) {
          if (value) {
            print('token saved successfully!');
          } else {
            print('token could not be saved!');
          }
        });
      }).whenComplete(() {
        DatabaseMethods()
            .addUserInfoToDB(user.id, userInfoMap2)
            .whenComplete(() {
          print("User added to database. Now added its fcm token");
          DatabaseMethods().addFcmToken(user.id, fcmToken, false);
        });
      }).whenComplete(
        () {
          setState(() {
            isLoading = false;
          });
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  settings: RouteSettings(name: "MyApp"),
                  builder: (context) => MyApp(auth: widget.auth)),
              (route) => false);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final _formKey = GlobalKey<FormState>();
    void todoAfterEnterNicknamePop(user, value, userImage) {
      print('function todoAfterEnterNicknamePop called');
      Navigator.of(context).pop();
      continueSignIn(user, value, userImage);
    }

    Future<void> dialogEnterAllDetails() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Alert'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('This username has already been taken'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OKAY'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    showEnterNickname(BuildContext context, String nick, user, value, userImage,
        bool alreadyRegistered) {
      QuerySnapshot alUser;
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return new Container(
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: ListView.builder(
                    itemCount: 1,
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColor().buttonColor,
                                ),
                                child: Center(
                                    child: Text('Hear Us - Here to hear you',
                                        style: AppTextStyle()
                                            .tileHeadingStyleWhite)),
                              ),
                              SizedBox(height: 20),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text('Enter Nickname',
                                    style: AppTextStyle().psychoListHeadStyle),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 20, right: 20),
                                child: TextFormField(
                                  validator: (alreadyRegistered == false)
                                      ? (val) => val.isEmpty
                                          ? 'This field is required'
                                          : null
                                      : null,
                                  onChanged: (val) {
                                    setState(() {
                                      newNickname = val;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    focusColor: AppColor().buttonColor,
                                    hintText: '$nick ',
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                    'Choosing different nickname will delete earlier chats',
                                    style: AppTextStyle().bodyStyle),
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                    'Where did you come to know about Hear Us',
                                    style: AppTextStyle().psychoListHeadStyle),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: TextFormField(
                                  validator: (val) => val.isEmpty
                                      ? 'This field is required'
                                      : null,
                                  onChanged: (val) {
                                    setState(() {
                                      whereHearInfo = val;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    focusColor: AppColor().buttonColor,
                                    hintText:
                                        'eg. Friends-family, LinkedIn, Instagram, other, etc. ',
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text('Have an access code?',
                                    style: AppTextStyle().psychoListHeadStyle),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: TextFormField(
                                  onChanged: (val) {
                                    accessCode = val;
                                    print("accessCode $accessCode");
                                  },
                                  decoration: InputDecoration(
                                    focusColor: AppColor().buttonColor,
                                    hintText: 'Enter here',
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: button1(
                                    'DONE', AppColor().buttonColor, context,
                                    () async {
                                  print(
                                      "alreadyRegistered:  ${alreadyRegistered.toString()}");
                                  print(
                                      'newNickname ${newNickname.toString()}');
                                  if (_formKey.currentState.validate()) {
                                    alUser = await FirebaseFirestore.instance
                                        .collection('users')
                                        .where('username',
                                            isEqualTo: newNickname)
                                        .get();
                                    // await DatabaseMethods()
                                    //     .updateUserAccessCode(
                                    //         user.id, accessCode);
                                    print(alUser.size.toString());
                                    if (alUser.size.toString() == '0')
                                      todoAfterEnterNicknamePop(
                                          user, value, userImage);
                                    else {
                                      dialogEnterAllDetails();
                                    }
                                  }
                                }),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ]),
                      );
                    }));
          });
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    'assets/backgMain.png',
                  ),
                  fit: BoxFit.cover),
            ),
            child: Container(
              height: size.height,
              width: size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: size.height * 0.2,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Image.asset('assets/hu_white.png',
                        fit: BoxFit.fitHeight),
                  ),
                  Container(
                      child: Text(
                    'WELCOME',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.alegreya(
                        textStyle: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  )),
                  Container(
                      child: Text(
                    'Hear Us - Here to Hear you',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.alegreyaSans(
                        textStyle: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.normal)),
                  )),
                  Container(
                      padding:
                          EdgeInsets.fromLTRB(20, size.height * 0.20, 20, 0),
                      child: button1(
                          'LOGIN WITH GOOGLE', AppColor().buttonColor, context,
                          () {
                        setState(() {
                          isLoading = true;
                        });

                        widget.auth.Signin().then((user) {
                          String userImage =
                              'https://firebasestorage.googleapis.com/v0/b/hearus-4f2fe.appspot.com/o/assets%2Fhu_white.png?alt=media&token=6bddb58c-fd3f-4af7-8a17-3b2e7104af7d';
                          if (user != null) {
                            print("User has logged in (user != null)");
                            print("userid is ${user.id}");
                            print("user email is ${user.email}");

                            // Checking if the user is already registered...
                            print(
                                "Checking if the user is already registered...");
                            FirebaseFirestore.instance
                                .collection("users")
                                .doc(user.id)
                                .get()
                                .then(
                              (value) {
                                if (value.exists) {
                                  print(
                                      "The user has all ready signed in once ${value.data().toString()}");
                                  print(
                                      "Registered `userid `from user.id is ${user.id}");
                                  print(
                                      "Registered username from firebase is ${value.data()["username"]}");
                                  print(
                                      "Registered userid from firebase is ${value.data()["id"]}");
                                  showEnterNickname(
                                      context,
                                      value.data()["username"],
                                      user,
                                      value,
                                      userImage,
                                      true);
// Saving the credentials in SharedPreferences...

                                } else {
                                  // The user has not registered earlier
                                  print("The user has not registered earlier");
                                  showEnterNickname(context, newNickname, user,
                                      value, userImage, false);
                                }
                              },
                            );
                          }
                        });
                      })),
                ],
              ),
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
                      Text('Registered as a Listener ?  ',
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
        ],
      ),
    );
  }
}
