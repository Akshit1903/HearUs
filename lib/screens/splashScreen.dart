import 'dart:async';

import 'package:HearUs/screens/home.dart';
import 'package:HearUs/screens/listenerHome.dart';
import 'package:HearUs/screens/loginNew.dart';
import 'package:HearUs/services/auth.dart';
import 'package:HearUs/util/modals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final AuthMethods auth;
  const SplashScreen(this.auth);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  DataFromSharedPref userData = new DataFromSharedPref();
  bool isLoad = false;

  void getData() {
    userData.getData().whenComplete(() => setState(() {
          isLoad = true;
        }));
  }

  @override
  void initState() {
    super.initState();
    startTime();
    getData();
  }

  startTime() async {
    var duration = new Duration(seconds: 3);
    return new Timer(duration, route);
  }

  route() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) {
        print(userData.myUserId);
        if (userData.myUserId != null) {
          if (userData.myName == 'listener')
            return ListenerHomePage(auth: widget.auth, userData: userData);
          else {
            print('taking to home page');
            return HomePage(auth: widget.auth, userData: userData);
          }
        } else if (userData.myUserId == null) {
          widget.auth.signOutGoogle();
          return LoginNew(auth: widget.auth);
        }
        return Scaffold(
            body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/backgMain.png'),
                  fit: BoxFit.cover)),
        ));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/backgMain.png'),
                    fit: BoxFit.cover)),
            child: Center(
              child: Container(
                height: size.height * 0.2,
                width: size.height * 0.2,
                child: Image.asset('assets/hu_white.png'),
              ),
            )));
  }
}
