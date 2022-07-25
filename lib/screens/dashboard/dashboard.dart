import 'package:HearUs/screens/dashboard/anxiety_blog.dart';
import 'package:HearUs/screens/dashboard/betterSleep.dart';
import 'package:HearUs/screens/dashboard/tasks.dart';
import 'package:HearUs/screens/mentorFirstScreen.dart';
import 'package:HearUs/style/fonts.dart';
import 'package:HearUs/util/modals.dart';
import 'package:HearUs/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Dashboard extends StatefulWidget {
  Map<String, dynamic> userMap;
  DataFromSharedPref userData;
  Map<String, dynamic> blogAssets;
  Dashboard(this.userMap, this.userData, this.blogAssets);
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final gridList = [
    {
      "title": "Improve Performance",
      "path": "assets/dashboard/performance.svg",
      "r": 240,
      "g": 93,
      "b": 72,
      "function": "performance"
    },
    {
      "title": "Better Sleep",
      "path": "assets/dashboard/sleep.svg",
      "r": 78,
      "g": 85,
      "b": 103,
      "function": "sleep"
    },
    {
      "title": "Depression vs. \n Sadness",
      "path": "assets/dashboard/depression.svg",
      "r": 244,
      "g": 161,
      "b": 124,
      "function": "depression"
    },
    {
      "title": "What is Anxiety? \nHow to deal with it?",
      "path": "assets/dashboard/reduce_anxiety.svg",
      "r": 255,
      "g": 207,
      "b": 134,
      "function": "reduce_anxiety"
    },
    {
      "title":
          "Why are some people\n not comfortable in \nsharing their feelings?",
      "path": "assets/dashboard/share_feelings.svg",
      "r": 108,
      "g": 178,
      "b": 142,
      "function": "share_feelings"
    },
    {
      "title": "Reduce Stress",
      "path": "assets/dashboard/reduce_stress.svg",
      "r": 128,
      "g": 138,
      "b": 255,
      "function": "reduce_stress"
    },
  ];
  String selected = "dashboard";

  @override
  Widget build(BuildContext context) {
    final userMap = widget.userMap as Map<String, dynamic>;
    List taskList = widget.userMap["taskList"];
    print("taskList ${widget.userMap}");
    final size = MediaQuery.of(context).size;
    return (selected == "dashboard")
        ? Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Dashboard",
                    style: AppTextStyle().headingStyleWhite,
                    textAlign: TextAlign.start,
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      GridView.builder(
                        itemCount: gridList.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 4 / 5,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                        ),
                        //primary: false,
                        padding: const EdgeInsets.all(5),
                        // crossAxisSpacing: 10,
                        // mainAxisSpacing: 10,
                        // crossAxisCount: 2,
                        itemBuilder: (ctx, index) {
                          return GridTile(
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(
                                        gridList[index]["r"],
                                        gridList[index]["g"],
                                        gridList[index]["b"],
                                        1),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                  height: 300,
                                  width: 400,
                                  child: InkWell(
                                    onTap: () {
                                      // print(
                                      //     "userData ${widget.userData.myUserId}");
                                      setState(() {
                                        selected = gridList[index]["function"];
                                      });
                                      print("selected $selected");
                                    },
                                    splashColor: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(15),
                                    child: Column(
                                      children: [
                                        Flexible(
                                          flex: 3,
                                          child: SvgPicture.asset(
                                            gridList[index]["path"],
                                            fit: BoxFit.cover,
                                            width: 500,
                                          ),
                                        ),
                                        Flexible(
                                          flex: 1,
                                          child: FittedBox(
                                            fit: BoxFit.fitHeight,
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              child: Text(
                                                gridList[index]["title"],
                                                style:
                                                    AppTextStyle().headingStyle,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // if (index == gridList.length - 1)
                                        //   SizedBox(
                                        //     height: 40,
                                        //   ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 40,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // Positioned(
                      //   bottom: 0,
                      //   child: Container(
                      //     width: MediaQuery.of(context).size.width - 40,
                      //     padding: EdgeInsets.symmetric(vertical: 10),
                      //     child: button1('GET A HABIT COACH', Color(0xFF7C9A92),
                      //         context, () {}),
                      //   ),
                      // )
                    ],
                  ),
                ),
                Container(
                  //width: MediaQuery.of(context).size.width - 40,
                  padding: EdgeInsets.only(top: 5),
                  child: button1(
                      'GET A HABIT COACH', Color(0xFF7C9A92), context, () {
                    setState(() {
                      selected = "mentor";
                    });
                  }),
                ),
              ],
            ),
          )
        : (gridList[0]["function"] == selected)
            ? WillPopScope(
                onWillPop: () async {
                  setState(() {
                    selected = "dashboard";
                  });
                  return false;
                },
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          // height: MediaQuery.of(context).size.height - 150,
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          decoration: BoxDecoration(
                            color: Color(0xFFF7F3F0),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(42),
                                topRight: Radius.circular(42)),
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 5),
                                    margin: EdgeInsets.only(top: 20),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 10),
                                      constraints:
                                          BoxConstraints(maxWidth: size.width),
                                      child: Text(
                                        "Improve Performance",
                                        textAlign: TextAlign.center,
                                        style: AppTextStyle().headingStyle,
                                      ),
                                    ),
                                  ),
                                  SvgPicture.asset(
                                    "assets/dashboard/performance.svg",
                                    width: size.width,
                                  ),
                                  Container(
                                    // height : size.height - 350,
                                    width: size.width,
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          "Have you ever noticed that having a single scheduled meeting wrecks up your entire day?",
                                          style: AppTextStyle().bodyStyleBold,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          "Maintaining a list of your tasks is very important if you want to manage your time. Explicitly writing down important stuff takes the load of remembering it from your mind and frees it up to focus on other things. A task list acts like an external memory bank. Once you have written it down, you just have to remember that you have a list and the list remembers the tasks for you. It is a time-tested strategy. Along with the obvious memory aid, a task list helps you get your priorities straight and aids you in maintaining a laser sharp focus on things that are the most important.",
                                          style: AppTextStyle().bodyStyle,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              40,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: button2('GO TO TASKS',
                                              Color(0xFF7C9A92), context, () {
                                            setState(() {
                                              selected = "tasks";
                                            });
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Positioned(
                              //   bottom: 10,
                              //   child: Container(
                              //     width: MediaQuery.of(context).size.width - 40,
                              //     padding: EdgeInsets.symmetric(vertical: 10),
                              //     child: button2(
                              //         'GO TO TASKS', Color(0xFF7C9A92), context,
                              //         () {
                              //       setState(() {
                              //         selected = "tasks";
                              //       });
                              //     }),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : (selected == "tasks")
                ? WillPopScope(
                    onWillPop: () async {
                      setState(() {
                        selected = "dashboard";
                      });
                      return false;
                    },
                    child: Tasks(
                      widget.userData.myUserId,
                      taskList,
                      widget.userMap["completedIndex"],
                    ),
                  )
                : (gridList[1]["function"] == selected)
                    ? WillPopScope(
                        onWillPop: () async {
                          setState(() {
                            selected = "dashboard";
                          });
                          return false;
                        },
                        child: BetterSleep(widget.userData.myUserId,
                            widget.userMap["yesterdaySleepData"]),
                      )
                    : (gridList[3]["function"] == selected)
                        // ? AnxietyBlog(widget.blogAssets["anxiety_blog"])
                        ? WillPopScope(
                            onWillPop: () async {
                              setState(() {
                                selected = "dashboard";
                              });
                              return false;
                            },
                            child: Container(
                              child: Center(
                                child: Container(
                                  child: FittedBox(
                                    child: Text(
                                      "Coming Soon!",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                ),
                              ),
                            ),
                          )
                        : (selected == "mentor")
                            ? WillPopScope(
                                onWillPop: () async {
                                  setState(() {
                                    selected = "dashboard";
                                  });
                                  return false;
                                },
                                child: MentorFirstScreen())
                            : WillPopScope(
                                onWillPop: () async {
                                  setState(() {
                                    selected = "dashboard";
                                  });
                                  return false;
                                },
                                child: Container(
                                  child: Center(
                                    child: Container(
                                      child: FittedBox(
                                        child: Text(
                                          "Coming Soon!",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                    ),
                                  ),
                                ),
                              );
  }
}
