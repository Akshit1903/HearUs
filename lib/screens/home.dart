import 'package:HearUs/main.dart';
import 'package:HearUs/screens/dashboard/dashboard.dart';
import 'package:HearUs/screens/dashboard/sleep_home.dart';
import 'package:HearUs/screens/mentorDash.dart';
import 'package:HearUs/screens/mentorFirstScreen.dart';
import 'package:HearUs/screens/dashboard/tasks.dart';

import 'package:HearUs/style/colors.dart';
import 'package:HearUs/style/newFonts.dart';
import 'package:HearUs/widgets/navigationDrawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../screens/pschoList.dart';
import '../services/auth.dart';
import '../screens/listeners.dart';
import '../style/fonts.dart';
import '../util/modals.dart';
import '../widgets/widgets.dart';
import '../services/database.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final DataFromSharedPref userData;
  final AuthMethods auth;
  final int initialPage;
  HomePage({this.userData, this.auth, this.initialPage});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  // Text for the home buttons
  String button1title = 'Talk to a Listener';
  String button1sub = 'Chat with our trained empathetic listeners';
  String button2title = 'Book a Session';
  String button2sub = 'Counselling with licensed psychologists';
  String button3title = 'Growth Tools';
  String button3sub = 'Track your daily growth with a personal mentor';
  Future<DocumentSnapshot> userMapFuture;
  Future<DocumentSnapshot> blogAssets;
  @override
  void initState() {
    super.initState();
    // Initializing online status to firebase
    DatabaseMethods()
        .updateOnlineStatus("users", widget.userData.myUserId, true);
    userMapFuture = DatabaseMethods().getUserData(widget.userData.myUserId);
    blogAssets = DatabaseMethods().getBlogAssets();
    WidgetsBinding.instance.addObserver(this);
    selected = (widget.initialPage != null) ? widget.initialPage : 0;
  }

  bool onlineStatus = true;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onlineStatus = true;
      print("online status triggered should be online: $onlineStatus");
      DatabaseMethods()
          .updateOnlineStatus("users", widget.userData.myUserId, onlineStatus);
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      return;
    } else if (state == AppLifecycleState.paused) {
      onlineStatus = false;
      print("online status triggered should be offline: $onlineStatus");
      DatabaseMethods()
          .updateOnlineStatus("users", widget.userData.myUserId, onlineStatus);
    }
  }

  Widget feelButton(String icon, String iconVal, context) {
    Size size = MediaQuery.of(context).size;
    return AnimatedContainer(
      duration: Duration(milliseconds: 1000),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: InkWell(
        onTap: () {
          Map<String, dynamic> feelInfo = {
            "feel": iconVal,
            "date": DateTime.now()
          };
          DatabaseMethods().addFeelofDay(widget.userData.myUserId, feelInfo);
          showFeelInfo(context, iconVal, icon);
          Fluttertoast.showToast(
              msg: 'Thanks for sharing! :)', backgroundColor: Colors.black);
        },
        child: Column(
          children: [
            Container(
              height: size.height * 0.085,
              width: size.height * 0.085,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Image.asset('$icon'),
            ),
            Text(
              '$iconVal',
              style: AppTextStyle().bodyStyleWhite,
            ),
          ],
        ),
      ),
    );
  }

  int selected;
  Widget navigationBar(BuildContext context) {
    double sizeSelected = 30;
    double sizeNotSelected = 25;
    Widget navigationItem(String icon, String iconNot, int page) {
      return SizedBox(
        width: MediaQuery.of(context).size.width / 3.5,
        child: InkWell(
          onTap: () {
            setState(
              () {
                selected = page;
                print("page changed to $selected");
              },
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
            width: MediaQuery.of(context).size.width / 3,
            // decoration: BoxDecoration(border: Border.all()),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: (selected == page) ? sizeSelected : sizeNotSelected,
              width: (selected == page) ? sizeSelected : sizeNotSelected,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: (selected == page)
                        ? AssetImage('$icon')
                        : AssetImage('$iconNot')),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      decoration: BoxDecoration(color: AppColor().mainBackColor),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            navigationItem('assets/hu_white.png', 'assets/HearUs_grey.png', 0),
            navigationItem('assets/chatSel.png', 'assets/chat.png', 1),
            navigationItem('assets/personSel.png', 'assets/Profile.png', 2),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: NavigationDrawer(widget.userData, widget.auth),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Builder(
            builder: (context) => InkWell(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(left: 10),
                child: Image.asset(
                  'assets/hamMenu.png',
                ),
              ),
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 10),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF253334),
                child: Container(
                    padding: EdgeInsets.all(6),
                    child: Image.asset(
                      'assets/hu_white.png',
                      fit: BoxFit.fill,
                    )),
              ),
            )
          ],
        ),
        bottomNavigationBar: navigationBar(context),
        body: FutureBuilder<DocumentSnapshot>(
            future: userMapFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LinearProgressIndicator();
              }
              return SafeArea(
                child: (selected == 0)
                    ? Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Container(
                                height:
                                    MediaQuery.of(context).size.height - 148,
                                width: MediaQuery.of(context).size.width,
                                child: ListView(
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding:
                                          EdgeInsets.fromLTRB(10, 20, 10, 10),
                                      child: Text(
                                          "Welcome back, ${widget.userData.myUsername}",
                                          style: NewAppTextStyle()
                                              .psychoListMainHeadingStyle),
                                    ),
                                    StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(widget.userData.myUserId)
                                            .snapshots(),
                                        builder:
                                            (context, AsyncSnapshot snapshot) {
                                          if (snapshot.hasData) {
                                            if (snapshot.data
                                                    .data()
                                                    .containsKey("feelOfDay") ==
                                                false) {
                                              widget.auth
                                                  .signOutGoogle()
                                                  .whenComplete(() => Navigator
                                                      .pushAndRemoveUntil(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  MyApp(
                                                                      auth: widget
                                                                          .auth)),
                                                          (route) => false));
                                            }
                                            if (DateFormat('EEEE').format(
                                                    snapshot.data["feelOfDay"]
                                                            ["date"]
                                                        .toDate()) !=
                                                DateFormat('EEEE')
                                                    .format(DateTime.now())) {
                                              return AnimatedContainer(
                                                duration: Duration(
                                                    milliseconds: 1000),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              10, 0, 10, 10),
                                                      child: Text(
                                                          "How are you feeling today ?",
                                                          style: NewAppTextStyle()
                                                              .psychoListMainBodyStyle),
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          feelButton(
                                                              'assets/calm.png',
                                                              "Calm",
                                                              context),
                                                          feelButton(
                                                              'assets/Happy.png',
                                                              "Happy",
                                                              context),
                                                          feelButton(
                                                              'assets/Low.png',
                                                              "Low",
                                                              context),
                                                          feelButton(
                                                              'assets/anxious.png',
                                                              'Anxious',
                                                              context),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else
                                              return Container();
                                          }
                                          return LinearProgressIndicator(
                                              backgroundColor:
                                                  AppColor().mainBackColor,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      AppColor().buttonColor));
                                        }),
                                    homeButton(
                                        button1title,
                                        button1sub,
                                        'Enter Chatroom',
                                        'talktoListener.png',
                                        context, () {
                                      print(
                                          "username = ${widget.userData.myUsername}");
                                      print(
                                          "userId = ${widget.userData.myUserId}");
                                      setState(() {
                                        selected = 1;
                                      });
                                    }),
                                    homeButton(
                                      button2title,
                                      button2sub,
                                      'Book Now',
                                      'bookAppoint.png',
                                      context,
                                      () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              settings: RouteSettings(
                                                  name: "PsychoList"),
                                              builder: (context) =>
                                                  PsychoListPage(
                                                      userData:
                                                          widget.userData))),
                                    ),
                                    homeButton(button3title, button3sub,
                                        'Know more', 'mentor.png', context, () {
                                      setState(() {
                                        selected = 2;
                                      });
                                    }),
                                    if (snapshot.data.data()["showTasks"] !=
                                        null)
                                      if (snapshot.data.data()["showTasks"])
                                        homeButton(
                                            "Improve Performance",
                                            "Tasks to organise your day",
                                            'Go to tasks',
                                            'dashboard/performance.svg',
                                            context, () {
                                          setState(() {
                                            selected = 4;
                                          });
                                        }, isSvg: true),
                                    if (snapshot.data.data()["showSleep"] !=
                                        null)
                                      if (snapshot.data.data()["showSleep"])
                                        homeButton(
                                            "Sleep Tools",
                                            "Track and improve your sleep quality",
                                            'Enter sleep tools',
                                            'dashboard/sleep.svg',
                                            context, () {
                                          setState(() {
                                            selected = 5;
                                          });
                                        }, isSvg: true),
                                    SizedBox(
                                      height: 50,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      )
                    : (selected == 1)
                        ? ListenersPage(
                            userData: widget.userData,
                          )
                        : (selected == 2)
                            ? FutureBuilder<DocumentSnapshot>(
                                future: blogAssets,
                                builder: (context, snapshot2) {
                                  Widget toBeReturned = Container();
                                  if (snapshot2.connectionState ==
                                      ConnectionState.done) {
                                    toBeReturned = Dashboard(
                                        snapshot.data.data(),
                                        widget.userData,
                                        snapshot2.data.data());
                                  } else {
                                    toBeReturned = LinearProgressIndicator();
                                  }
                                  return toBeReturned;
                                })
                            : (selected == 3)
                                ? MentorFirstScreen()
                                : (selected == 4)
                                    ? Tasks(
                                        widget.userData.myUserId,
                                        snapshot.data.data()["taskList"],
                                        snapshot.data.data()["completedIndex"],
                                      )
                                    : (selected == 5)
                                        ? SleepHome(
                                            widget.userData.myUserId,
                                            snapshot.data
                                                .data()["yesterdaySleepData"],
                                          )
                                        : Container(),
              );
            }));
  }
}

showFeelInfo(BuildContext context, String feel, String feelIcon) {
  Map<String, String> emotions = {
    "Happy":
        "It’s a very good thing that you’re feeling happy. There can a lot of things on your mind right now and the best thing to do is share it with someone. Talking to others about your happiness can make them happy as well. Try to make someone’s day by small gestures such as go give your parents a hug. Small gestures can make you happier and make your close one’s day better too.\n\nBreak out of your routine and blend things up! It may be as simple as walking down a distinct street, anything to simply get off of autopilot and be present where you are. You can also share your happiness with one of our trained listener. They will be there to listen to whatever you feel like sharing and it will be totally confidential.",
    "Low":
        "When you’re feeling low there are many things that can help you get through that phase and make you feel a little better. One of the best and simplest ways to pick yourself up when you’re having a bad day is to get out of your comfort zone and do some exercise. It may sound very hectic but exercising can help you in a lot of ways. \nMoving your body can boost endorphins and stretch out any sore spots. Exercising can also help you build your physical health. Choose something you enjoy and try to start slowly if the thought of working out stresses you. \nEven just taking 10 minutes out of your day can be helpful for you. You don't have to do any hard exercises.\n\n Often when you start you will find that you want to keep going and do a longer session but even if you don't feel like doing longer workouts that's okay too. Walking always helps clear your head and shed negative energy. It is very therapeutic if you choose to walk at a scenic location",
    "Anxious":
        "When you’re feeling anxious the most effective thing to do is focus on your breathing. Deep breathing helps you calm down. While you may have heard about specific breathing exercises, you don’t need to be worried about trying to do a particular breathing exercise or anything like that. Instead just focus on evenly inhaling and exhaling. This will help you to slow down and take control of your mind.\nFocusing on your breathing may not sound like much, but it can help you a lot when you are feeling anxious. When you breathe deeply, your brain will send a message to your body to calm down, which will help you decrease your body’s overall stress response. Spend some time even a few minutes just on your breath. Take long, slow breaths, and try to remove all negative thoughts on each exhale. This will help you a lot when you're feeling anxious.",
    "Calm":
        "So you’re feeling calm, that’s good. You can do a lot of things right now because your mind is clear of any unwanted thoughts. The most important thing to do is just sit down and write whatever comes to your mind.  Writing your own thoughts is a very good habit. \n\nDon’t worry about making any spelling mistakes or incomplete sentences, just write about how you feel. Think about how grateful you are for all the things you have accomplished in life. It may be as small as spending time with your family. Make a plan to write your journal every day. You can also go out get some fresh air, make a cup of tea and just think about the happy times. Relax your body, stretch out a little.",
  };

  showModalBottomSheet(
      context: context,
      builder: (context) {
        return new Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(children: <Widget>[
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColor().buttonColor,
              ),
              child: Center(
                  child: Text('$feel',
                      style: AppTextStyle().tileHeadingStyleWhite)),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: 1,
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('${emotions[feel]}',
                            style: AppTextStyle().bodyStyle),
                      ),
                    );
                  }),
            ),
          ]),
        );
      });
}
