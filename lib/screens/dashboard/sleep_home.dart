import 'dart:math';

import 'package:HearUs/services/database.dart';
import 'package:HearUs/services/sleep_timer.dart';
import 'package:HearUs/style/fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class SleepHome extends StatefulWidget {
  String userId;
  Map<String, dynamic> yesterdaySleepData;
  SleepHome(
    this.userId,
    this.yesterdaySleepData,
  );
  @override
  _SleepHomeState createState() => _SleepHomeState();
}

class _SleepHomeState extends State<SleepHome> {
  StopWatchTimer sleepTimer;
  Size size;
  bool isTimerOn = false;
  bool isPaused = false;
  bool isMusicOn = false;
  bool isMusicPaused = false;
  bool playMusicLoading = false;
  bool nextMusicLoading = false;
  AudioPlayer audioPlayer;
  List<Reference> musicList = [];
  String nowPlaying = "hello";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sleepTimer = Provider.of<SleepTimer>(context).sleepTimerInstance;
    if (sleepTimer.isRunning) {
      isTimerOn = true;
    }
    size = MediaQuery.of(context).size;
    audioPlayer = AudioPlayer();
  }

  Future<void> play(String url) async {
    int result = await audioPlayer.play(url, isLocal: false);
    if (result == 1) {
      await audioPlayer.setReleaseMode(ReleaseMode.LOOP);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: size.width,
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color.fromRGBO(78, 85, 103, 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                StreamBuilder<int>(
                  stream: sleepTimer.rawTime,
                  initialData: 0,
                  builder: (context, snap) {
                    final value = snap.data;
                    final displayTime = StopWatchTimer.getDisplayTime(value);
                    return Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            width: size.width,
                            // height: double.infinity,
                            child: FittedBox(
                              child: Text(
                                // displayTime.substring(0, 5),
                                displayTime.substring(0, 8),
                                style: TextStyle(
                                    color: Colors.white,
                                    // fontSize: 100,
                                    fontFamily: 'Helvetica',
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        if (!isTimerOn)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Color.fromRGBO(111, 89, 135, 1),
                            ),
                            padding: EdgeInsets.all(4),
                            child: TextButton.icon(
                              icon: SvgPicture.asset(
                                  "assets/dashboard/sleep/start.svg"),
                              onPressed: () {
                                sleepTimer.onExecute
                                    .add(StopWatchExecute.start);
                                setState(() {
                                  isTimerOn = true;
                                });
                              },
                              label: Text(
                                "Start sleep timer",
                                style: AppTextStyle().bodyStyleWhite,
                              ),
                            ),
                          ),
                        if (isTimerOn)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isPaused)
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Color.fromRGBO(111, 89, 135, 1),
                                  ),
                                  padding: EdgeInsets.all(4),
                                  child: IconButton(
                                    icon: SvgPicture.asset(
                                        "assets/dashboard/sleep/start.svg"),
                                    onPressed: () {
                                      sleepTimer.onExecute
                                          .add(StopWatchExecute.start);
                                      setState(() {
                                        isPaused = false;
                                      });
                                    },
                                  ),
                                ),
                              if (!isPaused)
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Color.fromRGBO(111, 89, 135, 1),
                                  ),
                                  padding: EdgeInsets.all(4),
                                  child: IconButton(
                                    icon: SvgPicture.asset(
                                        "assets/dashboard/sleep/pause.svg"),
                                    onPressed: () {
                                      sleepTimer.onExecute
                                          .add(StopWatchExecute.stop);
                                      setState(() {
                                        isPaused = true;
                                      });
                                    },
                                  ),
                                ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Color.fromRGBO(111, 89, 135, 1),
                                ),
                                padding: EdgeInsets.all(4),
                                child: IconButton(
                                  icon: SvgPicture.asset(
                                      "assets/dashboard/sleep/reset.svg"),
                                  onPressed: () async {
                                    sleepTimer.onExecute
                                        .add(StopWatchExecute.reset);
                                    setState(() {
                                      isTimerOn = false;
                                      isPaused = false;
                                    });
                                    await DatabaseMethods()
                                        .setYesterdaySleepData(
                                            StopWatchTimer.getDisplayTimeHours(
                                                value),
                                            StopWatchTimer.getDisplayTimeMinute(
                                                value),
                                            widget.userId);
                                  },
                                ),
                              ),
                            ],
                          )
                      ],
                    );
                  },
                )
              ],
            ),
          ),
          Container(
            width: size.width,
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color.fromRGBO(78, 85, 103, 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 7,
                      child: Text(
                        "Relaxing sounds that help you sleep.",
                        style: AppTextStyle().headingStyleWhite,
                      ),
                    ),
                    Spacer(),
                    Flexible(
                      flex: 3,
                      child:
                          SvgPicture.asset("assets/dashboard/sleep/music.svg"),
                    ),
                  ],
                ),
                if (isMusicOn)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Now Playing: $nowPlaying",
                      style: AppTextStyle().bodyStyleWhite,
                    ),
                  ),
                if (!isMusicOn)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Color.fromRGBO(111, 89, 135, 1),
                    ),
                    padding: EdgeInsets.all(4),
                    child: (!playMusicLoading)
                        ? TextButton.icon(
                            icon: SvgPicture.asset(
                                "assets/dashboard/sleep/start.svg"),
                            label: Text(
                              "Play Music",
                              style: AppTextStyle().bodyStyleWhite,
                            ),
                            onPressed: () async {
                              setState(() {
                                playMusicLoading = true;
                              });
                              if (musicList.length == 0) {
                                FirebaseStorage storage =
                                    FirebaseStorage.instance;
                                final result = await storage
                                    .ref()
                                    .child("assets")
                                    .child("audio")
                                    .listAll();
                                musicList = result.items;
                              }
                              int musicIndex =
                                  Random().nextInt(musicList.length);
                              nowPlaying = musicList[musicIndex].name;
                              // await listExample();
                              await play(
                                  await musicList[musicIndex].getDownloadURL());
                              setState(() {
                                isMusicOn = true;
                                playMusicLoading = false;
                              });
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 20),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                  ),
                if (isMusicOn)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isMusicPaused)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Color.fromRGBO(111, 89, 135, 1),
                          ),
                          padding: EdgeInsets.all(4),
                          child: IconButton(
                            icon: SvgPicture.asset(
                                "assets/dashboard/sleep/start.svg"),
                            onPressed: () async {
                              int result = await audioPlayer.resume();
                              setState(() {
                                isMusicPaused = false;
                              });
                            },
                          ),
                        ),
                      if (!isMusicPaused)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Color.fromRGBO(111, 89, 135, 1),
                          ),
                          padding: EdgeInsets.all(4),
                          child: IconButton(
                            icon: SvgPicture.asset(
                                "assets/dashboard/sleep/pause.svg"),
                            onPressed: () async {
                              int result = await audioPlayer.pause();
                              setState(() {
                                isMusicPaused = true;
                              });
                            },
                          ),
                        ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Color.fromRGBO(111, 89, 135, 1),
                        ),
                        padding: EdgeInsets.all(4),
                        child: IconButton(
                          icon: SvgPicture.asset(
                              "assets/dashboard/sleep/reset.svg"),
                          onPressed: () async {
                            int result = await audioPlayer.stop();
                            nowPlaying = "";
                            setState(() {
                              isMusicOn = false;
                              isMusicPaused = false;
                            });
                          },
                        ),
                      ),
                      if (!isMusicPaused)
                        SizedBox(
                          width: 10,
                        ),
                      if (!isMusicPaused)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Color.fromRGBO(111, 89, 135, 1),
                          ),
                          padding: EdgeInsets.all(4),
                          child: (!nextMusicLoading)
                              ? IconButton(
                                  icon: SvgPicture.asset(
                                      "assets/dashboard/sleep/next.svg"),
                                  onPressed: () async {
                                    setState(() {
                                      nextMusicLoading = true;
                                    });
                                    int musicIndex =
                                        Random().nextInt(musicList.length);
                                    final url = await musicList[musicIndex]
                                        .getDownloadURL();
                                    await play(url);
                                    setState(() {
                                      nextMusicLoading = false;
                                      nowPlaying = musicList[musicIndex].name;
                                    });
                                  },
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(7.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                    ],
                  )
              ],
            ),
          ),
          Container(
            width: size.width,
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color.fromRGBO(78, 85, 103, 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 7,
                      child: Text(
                        (widget.yesterdaySleepData != null)
                            ? (widget.yesterdaySleepData["hour"] != "0" &&
                                    widget.yesterdaySleepData["minute"] !=
                                        "0" &&
                                    DateTime.parse(
                                            widget.yesterdaySleepData["time"])
                                        .isAfter(
                                      DateTime.now().subtract(
                                        Duration(days: 1),
                                      ),
                                    ))
                                ? "You slept for ${widget.yesterdaySleepData["hour"]} hrs and ${widget.yesterdaySleepData["minute"]} minutes yesterday."
                                : "We haven't recorded your sleep data yet!"
                            : "We haven't recorded your sleep data yet!",
                        style: AppTextStyle().headingStyleWhite,
                      ),
                    ),
                    Spacer(),
                    Flexible(
                      flex: 3,
                      child:
                          SvgPicture.asset("assets/dashboard/sleep/record.svg"),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
