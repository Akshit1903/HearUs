import 'dart:math';
import 'package:HearUs/screens/dashboard/sleep_home.dart';
import 'package:HearUs/services/database.dart';
import 'package:HearUs/services/sleep_timer.dart';
import 'package:HearUs/style/fonts.dart';
import 'package:HearUs/widgets/widgets.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:audioplayers/audioplayers.dart';

class BetterSleep extends StatefulWidget {
  String userId;
  Map<String, dynamic> yesterdaySleepData;
  BetterSleep(this.userId, this.yesterdaySleepData);
  @override
  _BetterSleepState createState() => _BetterSleepState();
}

class _BetterSleepState extends State<BetterSleep> {
  Widget sleep1() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              //height: MediaQuery.of(context).size.height - 155,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              decoration: BoxDecoration(
                color: Color(0xFFF7F3F0),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(42),
                    topRight: Radius.circular(42)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                    margin: EdgeInsets.only(top: 20),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                      constraints: BoxConstraints(maxWidth: size.width),
                      child: Text(
                        "Better Sleep",
                        textAlign: TextAlign.center,
                        style: AppTextStyle().headingStyle,
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    "assets/dashboard/sleep.svg",
                    width: size.width,
                  ),
                  Column(
                    children: <Widget>[
                      // Text(
                      //   "Have you ever noticed that having a single scheduled meeting wrecks up your entire day?",
                      //   style: AppTextStyle().bodyStyleBold,
                      // ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Our sleep assistance features include smart alarms, screen avoidance along with peaceful white noise and natural sounds to help you fall asleep quicker. The smart alarm feature wakes you up when your sleep is the lightest. By getting up when your body is ready rather than being jolted awake from a deep slumber, you can avoid feeling groggy and grumpy during the first hour you're up. Getting good quality sleep is an important part of your overall health. The CDC has declared that insufficient sleep is a public health epidemic and that chronic sleep deprivation contributes to illnesses such as diabetes, hypertension, obesity and depression. You can use our sleep tracker to track your sleep hours over time which may in turn help you to find out what has been causing your sleep problems. Start tracking now!",
                        style: AppTextStyle().bodyStyle,
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 40,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: button2(
                            'START TRACKING', Color(0xFF7C9A92), context, () {
                          setState(() {
                            sleepIndex++;
                          });
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget sleep2() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 150,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            decoration: BoxDecoration(
              color: Color(0xFFF7F3F0),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(42), topRight: Radius.circular(42)),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                      margin: EdgeInsets.only(top: 20),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                        constraints: BoxConstraints(maxWidth: size.width),
                        child: Text(
                          "We need to ask you a few questions to know your sleep habits better.",
                          textAlign: TextAlign.center,
                          style: AppTextStyle().headingStyle,
                        ),
                      ),
                    ),
                    SvgPicture.asset(
                      "assets/dashboard/sleep/sleep2.svg",
                      width: size.width,
                    ),
                    // Container(
                    // height : size.height - 350,
                    // width: size.width,
                    // child: Column(
                    //   children: <Widget>[
                    // Text(
                    //   "Have you ever noticed that having a single scheduled meeting wrecks up your entire day?",
                    //   style: AppTextStyle().bodyStyleBold,
                    // ),
                    // SizedBox(
                    //   height: 20,
                    // ),
                    // Text(
                    //   "Our sleep assistance features include smart alarms, screen avoidance along with peaceful white noise and natural sounds to help you fall asleep quicker. The smart alarm feature wakes you up when your sleep is the lightest. By getting up when your body is ready rather than being jolted awake from a deep slumber, you can avoid feeling groggy and grumpy during the first hour you're up. Getting good quality sleep is an important part of your overall health. The CDC has declared that insufficient sleep is a public health epidemic and that chronic sleep deprivation contributes to illnesses such as diabetes, hypertension, obesity and depression. You can use our sleep tracker to track your sleep hours over time which may in turn help you to find out what has been causing your sleep problems. Start tracking now!",
                    //   style: AppTextStyle().bodyStyle,
                    // ),
                    //   ],
                    // ),
                    // ),
                  ],
                ),
                Positioned(
                  bottom: 10,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: button2('NEXT', Color(0xFF7C9A92), context, () {
                      setState(() {
                        sleepIndex++;
                      });
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sleep3() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 150,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            decoration: BoxDecoration(
              color: Color(0xFFF7F3F0),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(42), topRight: Radius.circular(42)),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                      margin: EdgeInsets.only(top: 20),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                        constraints: BoxConstraints(maxWidth: size.width),
                        child: Text(
                          "What is your age?",
                          textAlign: TextAlign.center,
                          style: AppTextStyle().headingStyle,
                        ),
                      ),
                    ),
                    Center(
                      child: NumberPicker(
                        selectedTextStyle: GoogleFonts.alegreya(
                          textStyle: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        textStyle: GoogleFonts.alegreya(
                          textStyle: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        value: _age,
                        minValue: 0,
                        maxValue: 100,
                        onChanged: (value) => setState(() => _age = value),
                      ),
                    ),
                    SvgPicture.asset(
                      "assets/dashboard/sleep/sleep3.svg",
                      width: size.width,
                    ),
                  ],
                ),
                Positioned(
                  bottom: 10,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: button2('NEXT', Color(0xFF7C9A92), context, () {
                      setState(() {
                        sleepIndex++;
                      });
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sleep4() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 150,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            decoration: BoxDecoration(
              color: Color(0xFFF7F3F0),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(42), topRight: Radius.circular(42)),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                      margin: EdgeInsets.only(top: 20),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                        constraints: BoxConstraints(maxWidth: size.width),
                        child: Text(
                          "Around what time do you usually fall asleep?",
                          textAlign: TextAlign.center,
                          style: AppTextStyle().headingStyle,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        TimeOfDay picked = await showTimePicker(
                            context: context, initialTime: sleepTime);
                        if (picked != null && picked != sleepTime) {
                          setState(() {
                            sleepTime = picked;
                          });
                        }
                      },
                      child: Center(
                        child: Text(
                          "${DateFormat.jm().format(DateTime(now.year, now.month, now.day, sleepTime.hour, sleepTime.minute))}",
                          style: GoogleFonts.alegreya(
                            textStyle: TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SvgPicture.asset(
                      "assets/dashboard/sleep/sleep4.svg",
                      width: size.width,
                    ),
                  ],
                ),
                Positioned(
                  bottom: 10,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: button2('NEXT', Color(0xFF7C9A92), context, () {
                      setState(() {
                        sleepIndex++;
                      });
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sleep5() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 150,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            decoration: BoxDecoration(
              color: Color(0xFFF7F3F0),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(42), topRight: Radius.circular(42)),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                      margin: EdgeInsets.only(top: 20),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                        constraints: BoxConstraints(maxWidth: size.width),
                        child: Text(
                          "Around what time do you usually wake up?",
                          textAlign: TextAlign.center,
                          style: AppTextStyle().headingStyle,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        TimeOfDay picked = await showTimePicker(
                            context: context, initialTime: usuallyWakeUpTime);
                        if (picked != null && picked != usuallyWakeUpTime) {
                          setState(() {
                            usuallyWakeUpTime = picked;
                          });
                        }
                      },
                      child: Center(
                        child: Text(
                          "${DateFormat.jm().format(DateTime(now.year, now.month, now.day, usuallyWakeUpTime.hour, usuallyWakeUpTime.minute))}",
                          style: GoogleFonts.alegreya(
                            textStyle: TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SvgPicture.asset(
                      "assets/dashboard/sleep/sleep5.svg",
                      width: size.width,
                    ),
                  ],
                ),
                Positioned(
                  bottom: 10,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: button2('NEXT', Color(0xFF7C9A92), context, () {
                      setState(() {
                        sleepIndex++;
                      });
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sleep6() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 150,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            decoration: BoxDecoration(
              color: Color(0xFFF7F3F0),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(42), topRight: Radius.circular(42)),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                      margin: EdgeInsets.only(top: 20),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                        constraints: BoxConstraints(maxWidth: size.width),
                        child: Text(
                          "What time would you like to consistently wake up at?",
                          textAlign: TextAlign.center,
                          style: AppTextStyle().headingStyle,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        TimeOfDay picked = await showTimePicker(
                            context: context, initialTime: likeToWakeUpTime);
                        if (picked != null && picked != likeToWakeUpTime) {
                          setState(() {
                            likeToWakeUpTime = picked;
                          });
                        }
                      },
                      child: Center(
                        child: Text(
                          "${DateFormat.jm().format(DateTime(now.year, now.month, now.day, likeToWakeUpTime.hour, likeToWakeUpTime.minute))}",
                          style: GoogleFonts.alegreya(
                            textStyle: TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SvgPicture.asset(
                      "assets/dashboard/sleep/sleep5.svg",
                      width: size.width,
                    ),
                  ],
                ),
                Positioned(
                  bottom: 10,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: button2('NEXT', Color(0xFF7C9A92), context, () {
                      setState(() {
                        sleepIndex++;
                      });
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sleep7() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SingleChildScrollView(
            child: Container(
              // width: MediaQuery.of(context).size.width,
              // height: MediaQuery.of(context).size.height - 150,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                        margin: EdgeInsets.only(top: 20),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                          constraints: BoxConstraints(maxWidth: size.width),
                          child: Text(
                            "How much time does it usually take you to fall asleep after hitting the bed?",
                            textAlign: TextAlign.center,
                            style: AppTextStyle().headingStyle,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          NumberPicker(
                            selectedTextStyle: GoogleFonts.alegreya(
                              textStyle: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            textStyle: GoogleFonts.alegreya(
                              textStyle: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            value: timeToSleepHour,
                            minValue: 0,
                            maxValue: 4,
                            onChanged: (value) =>
                                setState(() => timeToSleepHour = value),
                          ),
                          Text(
                            ":",
                            style: GoogleFonts.alegreya(
                              textStyle: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                          NumberPicker(
                            selectedTextStyle: GoogleFonts.alegreya(
                              textStyle: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            textStyle: GoogleFonts.alegreya(
                              textStyle: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            value: timeToSleepMinute,
                            minValue: 0,
                            maxValue: 50,
                            step: 10,
                            onChanged: (value) =>
                                setState(() => timeToSleepMinute = value),
                          ),
                        ],
                      ),
                      SvgPicture.asset(
                        "assets/dashboard/sleep/sleep6.svg",
                        width: size.width,
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 10,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: button2('NEXT', Color(0xFF7C9A92), context, () {
                        setState(() {
                          sleepIndex++;
                        });
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sleep8() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 150,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            decoration: BoxDecoration(
              color: Color(0xFFF7F3F0),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(42), topRight: Radius.circular(42)),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                      margin: EdgeInsets.only(top: 20),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                        constraints: BoxConstraints(maxWidth: size.width),
                        child: Text(
                          "Congrats!",
                          textAlign: TextAlign.center,
                          style: AppTextStyle().headingStyle,
                        ),
                      ),
                    ),
                    Text(
                      "You have taken the first step towards improving your sleep. You can access your sleep information and settings from the sleep dashboard.",
                      style: GoogleFonts.alegreyaSans(
                        textStyle: TextStyle(
                            fontSize: 20,
                            // fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SvgPicture.asset(
                      "assets/dashboard/sleep/sleep7.svg",
                      width: size.width,
                    ),
                  ],
                ),
                Positioned(
                  bottom: 10,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child:
                        button2('FINISH', Color(0xFF7C9A92), context, () async {
                      await DatabaseMethods().setSleepData({
                        "age": _age,
                        "sleepTime": DateTime(now.year, now.month, now.day,
                                sleepTime.hour, sleepTime.minute)
                            .toIso8601String(),
                        "usuallyWakeUpTime": DateTime(
                                now.year,
                                now.month,
                                now.day,
                                usuallyWakeUpTime.hour,
                                usuallyWakeUpTime.minute)
                            .toIso8601String(),
                        "likeToWakeUpTime": DateTime(
                                now.year,
                                now.month,
                                now.day,
                                likeToWakeUpTime.hour,
                                likeToWakeUpTime.minute)
                            .toIso8601String(),
                        "timeToSleepHour": timeToSleepHour,
                        "timeToSleepMinute": timeToSleepMinute,
                      }, widget.userId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text("Thank you! Your data has been recorded"),
                        ),
                      );
                      setState(() {
                        sleepIndex++;
                      });
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> listExample() async {
    FirebaseStorage storage = FirebaseStorage.instance;

    final result = await storage.ref().child("assets").child("audio").listAll();
    print(result.items);
    result.items.forEach((Reference ref) {
      print('Found file: $ref');
      print(ref.getDownloadURL());
      print(ref.name);
    });

    result.prefixes.forEach((Reference ref) {
      print('Found directory: $ref');
    });
  }

  Size size;

  int sleepIndex = 0;
  int _age = 18;
  final now = DateTime.now();
  TimeOfDay sleepTime = TimeOfDay(hour: 23, minute: 0);
  TimeOfDay usuallyWakeUpTime = TimeOfDay(hour: 7, minute: 0);
  TimeOfDay likeToWakeUpTime = TimeOfDay(hour: 6, minute: 0);
  int timeToSleepHour = 0;
  int timeToSleepMinute = 30;

  @override
  void didChangeDependencies() {
    size = MediaQuery.of(context).size;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      // scrollBehavior: ScrollBehavior,
      /// [PageView.scrollDirection] defaults to [Axis.horizontal].
      /// Use [Axis.vertical] to scroll vertically.
      index: sleepIndex,
      children: <Widget>[
        sleep1(),
        sleep2(),
        sleep3(),
        sleep4(),
        sleep5(),
        sleep6(),
        sleep7(),
        sleep8(),
        SleepHome(widget.userId, widget.yesterdaySleepData),
      ],
    );
  }
}
