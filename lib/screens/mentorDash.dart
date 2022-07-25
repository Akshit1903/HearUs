import 'package:HearUs/screens/chatScreen.dart';
import 'package:HearUs/screens/mentorQuestions.dart';
import 'package:HearUs/services/database.dart';
import 'package:HearUs/style/newFonts.dart';
import 'package:HearUs/util/modals.dart';
import 'package:HearUs/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MentorDash extends StatefulWidget {
  final Map<String, dynamic> userData;
  final DataFromSharedPref usPrev;
  // final String mentor;
  // final DateTime timeOfPayment;

  MentorDash(
      {
      // this.mentor, this.timeOfPayment,
      this.userData,
      this.usPrev});
  @override
  _MentorDashState createState() => _MentorDashState();
}

class _MentorDashState extends State<MentorDash> {
  @override
  void initState() {
    super.initState();

    chatRoomId = getChatRoomIdByUsernames(
        widget.userData["mentor"][0]["mentorUsername"],
        widget.userData["username"]);

    getMentor();
  }

  String chatRoomId;
  Map<String, dynamic> mentorInfo;
  Future getMentor() async {
    await FirebaseFirestore.instance
        .collection('listeners')
        .where(
          'username',
          isEqualTo: widget.userData["mentor"][0]["mentorUsername"],
        )
        .get()
        .then((value) {
      mentorInfo = value.docs[0].data();
    });
  }

  bool stateChange = true;
  Future<bool> getChangeBool() async {
    return stateChange;
  }

  void setStateChanges() {
    setState(() {
      stateChange = !stateChange;
      print('messages should ${(stateChange) ? 'be' : 'not be'} displayed');
    });
  }

  getChatRoomIdByUsernames(String mentor, String user) {
    return "$mentor\_$user";
  }

  String button1title = 'Talk to your Mentor';
  String button1sub = 'Get one-to-one personalized mentoring';

  String button2title = 'Check your progress';
  String button2sub = 'Answer to a few questions and check your progress';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      height: size.height,
      width: size.width,
      child: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height - 148,
            width: MediaQuery.of(context).size.width,
            child: ListView(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                  child: Text("Welcome back, ${widget.userData["username"]}",
                      style: NewAppTextStyle().psychoListMainHeadingStyle),
                ),
                homeButton(button1title, button1sub, 'Enter Chatroom',
                    'talktoListener.png', context, () {
                  print("username = ${widget.userData["username"]}");
                  print("userId = ${widget.userData["id"]}");
                  setStateChanges();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(name: "ChatScreen"),
                      builder: (context) => ChatScreen(
                          listener: mentorInfo,
                          setStateChanges: setStateChanges,
                          chatRoomId: chatRoomId),
                    ),
                  ).whenComplete(() {
                    DatabaseMethods().createChatRoom(
                      chatRoomId,
                      widget.userData["username"],
                      widget.userData["mentor"][0]["mentorUsername"],
                    );
                  });
                }),
                homeButton(button2title, button2sub, "Get Started",
                    'mentor.png', context, () {
                  if (!widget.userData.containsKey('mentorQuestions')) {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.usPrev.myUserId)
                        .update({
                      "mentorQuestions": [
                        {"quesNo": -1, "rating": 0, "DateTime": DateTime.now()}
                      ]
                    });
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MentorQuestions(
                                us: widget.usPrev,
                              )));
                }),
              ],
            ),
          )
        ],
      ),
    );
  }
}
