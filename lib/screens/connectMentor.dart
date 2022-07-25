import 'dart:async';

import 'package:HearUs/screens/home.dart';

import 'package:HearUs/services/auth.dart';
import 'package:HearUs/services/database.dart';
import 'package:HearUs/style/fonts.dart';
import 'package:HearUs/util/modals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConnectMentor extends StatefulWidget {
  final DataFromSharedPref userData;
  final tag;
  final subscription;
  ConnectMentor({this.userData, this.tag, this.subscription});
  @override
  _ConnectMentorState createState() => _ConnectMentorState();
}

class _ConnectMentorState extends State<ConnectMentor> {
  int maxMentees;
  String mentorUsername = '';
  DateTime timeOfPayment;
  @override
  void initState() {
    super.initState();
    timeOfPayment = DateTime.now();
    startTime();
    FirebaseFirestore.instance
        .collection('mentors')
        .doc('categories')
        .get()
        .then((value) {
      setState(() {
        maxMentees = value.data()['maxMentees'];
      });
      print('maxMentees is $maxMentees');
    });
  }

  startTime() async {
    var duration = new Duration(seconds: 3);
    return new Timer(duration, route);
  }

  route() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FutureBuilder(
              future: DatabaseMethods().findMentor(widget.tag).then(
                (value) {
                  print("querysnap is ::: ${value.size}");
                  if (value.size != 0) {
                    print(
                        'Mentors of tag ${widget.tag} as present. There are ${value.size} mentors');
                    for (int i = 0; i < value.size; i++) {
                      if ((value.docs[i].data()["mentees"].length) <=
                          (maxMentees)) {
                        print("Mentor $i :::: ${value.docs[i].data()}");
                        mentorUsername = value.docs[i].data()["username"];
                        Map<String, dynamic> mentorInfo = {
                          "mentorUsername": mentorUsername,
                          "mentorFor": widget.tag,
                          "registeredOn": timeOfPayment,
                          "subscription": widget.subscription
                        };
                        DatabaseMethods().addMentorToUser(
                            widget.userData.myUserId, mentorInfo);
                        print("mentor usermane set as $mentorUsername");
                        DatabaseMethods().addUserAsMentee(
                            widget.userData.myUsername, mentorUsername);
                      }
                    }
                    if (mentorUsername == '') {
                      print('max limit reached. increasing limit by 1');
                      FirebaseFirestore.instance
                          .collection('mentors')
                          .doc('categories')
                          .update({'maxMentees': maxMentees + 1}).whenComplete(
                              () {
                        print('Limit Increased limit by 1');
                        // setState(() {
                        mentorUsername = value.docs[0].data()["username"];
                        print('mentor usermane set as $mentorUsername');
                        Map<String, dynamic> mentorInfo = {
                          "mentorUsername": mentorUsername,
                          "mentorFor": widget.tag,
                          "registeredOn": timeOfPayment,
                          "subscription": widget.subscription
                        };
                        DatabaseMethods().addMentorToUser(
                            widget.userData.myUserId, mentorInfo);
                        DatabaseMethods().addUserAsMentee(
                            widget.userData.myUsername, mentorUsername);
                        // });
                      });
                    }
                  }
                },
              ),
              builder: (context, AsyncSnapshot snapshot) {
                return HomePage(
                  auth: AuthMethods().authMethods,
                  userData: widget.userData,
                  initialPage: 0,
                );
              }),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          child: Text('Connecting you to a mentor...',
              style: AppTextStyle().headingStyle),
        ),
      ),
    );
  }
}
