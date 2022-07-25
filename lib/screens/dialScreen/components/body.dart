import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import './dial_user_pic.dart';
import './rounded_button.dart';
import '../constants.dart';
import '../size_config.dart';
import 'package:flutter/material.dart';
import '../../../services/agora.dart';
import '../../../services/database.dart';
import '../call_timer.dart';

import 'dial_button.dart';

class Body extends StatefulWidget {
  String callerName;
  String chatRoomId;
  String callEndMessage;
  Function callEndFunction;
  Body(this.callerName, this.chatRoomId, this.callEndMessage,
      this.callEndFunction);
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool _audioEnabled = true;
  bool _isSpeaker = false;
  bool _isButton1Loading = false;
  bool _isButton2Loading = false;
  RtcEngine _engine;
  var _remoteUid = 0;

  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final agora = Provider.of<Agora>(context);
    final callTimer = agora.stopWatchTimer;
    var _joined = agora.getJoined;
    Future<void> _getEngine() async {
      _engine = await agora.getEngine;
    }

    Future<void> callCut() async {
      print(await _engine.getConnectionState());
      setState(() {
        _isLoading = true;
      });
      callTimer.onExecute.add(StopWatchExecute.stop);
      callTimer.onExecute.add(StopWatchExecute.reset);
      await _engine.leaveChannel();

      setState(() {
        _isLoading = false;
      });

      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });

      print(await _engine.getConnectionState());
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: FutureBuilder(
          future: _getEngine(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            _engine.setEventHandler(
              RtcEngineEventHandler(
                joinChannelSuccess: (String channel, int uid, int elapsed) {
                  print('joinChannelSuccess $channel $uid');
                  setState(() {
                    _joined = true;
                  });
                },
                userJoined: (int uid, int elapsed) {
                  agora.stopWatchTimer.onExecute.add(StopWatchExecute.start);
                  print('userJoined $uid');
                  setState(() {
                    _remoteUid = uid;
                  });
                },
                userOffline: (int uid, UserOfflineReason reason) async {
                  print('userOffline $uid $reason');
                  print("reason $reason");
                  setState(() {
                    _remoteUid = 0;
                  });
                  if (reason == UserOfflineReason.Quit) {
                    await callCut();
                  }
                },
              ),
            );
            print("_remoteUid $_remoteUid");
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Text(
                        widget.callerName,
                        style: Theme.of(context)
                            .textTheme
                            .headline4
                            .copyWith(color: Colors.white),
                      ),
                      Text(
                        _remoteUid == 0
                            ? "Calling…"
                            : _audioEnabled
                                ? "Active"
                                : "On Hold",
                        style: TextStyle(color: Colors.white60),
                      ),
                      // Text("haha"),
                      CallTimer(),
                      VerticalSpacing(),
                      DialUserPic(image: "assets/HearUs_grey.png"),
                      Spacer(),
                      Align(
                        alignment: Alignment.center,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            _isButton1Loading
                                ? CircularProgressIndicator()
                                : DialButton(
                                    iconSrc: "assets/icons/Icon Mic.svg",
                                    text: "Hold",
                                    press: () async {
                                      setState(() {
                                        _isButton1Loading = true;
                                      });
                                      if (_audioEnabled) {
                                        await _engine.disableAudio();
                                      } else {
                                        await _engine.enableAudio();
                                      }

                                      setState(() {
                                        _audioEnabled = !_audioEnabled;
                                        _isButton1Loading = false;
                                      });
                                    },
                                    isSelected: !_audioEnabled,
                                  ),
                            _isButton2Loading
                                ? CircularProgressIndicator()
                                : DialButton(
                                    iconSrc: "assets/icons/Icon Volume.svg",
                                    text: !_isSpeaker ? "Speaker" : "Earpiece",
                                    press: () async {
                                      setState(() {
                                        _isButton2Loading = true;
                                      });
                                      await _engine
                                          .setEnableSpeakerphone(!_isSpeaker);
                                      setState(() {
                                        _isSpeaker = !_isSpeaker;
                                        _isButton2Loading = false;
                                      });
                                    },
                                    isSelected: _isSpeaker,
                                  ),
                            DialButton(
                              iconSrc: "assets/icons/Icon Video.svg",
                              text: "Video",
                              press: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Coming Soon!')));
                              },
                            ),
                            // DialButton(
                            //   iconSrc: "assets/icons/Icon Message.svg",
                            //   text: "Message",
                            //   press: () {
                            //     Navigator.of(context).pop();
                            //   },
                            // ),
                            // DialButton(
                            //   iconSrc: "assets/icons/Icon User.svg",
                            //   text: "Add contact",
                            //   press: () {},
                            // ),
                            // DialButton(
                            //   iconSrc: "assets/icons/Icon Voicemail.svg",
                            //   text: "Voice mail",
                            //   press: () {},
                            // ),
                          ],
                        ),
                      ),
                      VerticalSpacing(),
                      _isLoading
                          ? CircularProgressIndicator(
                              color: Colors.red,
                            )
                          : RoundedButton(
                              iconSrc: "assets/icons/call_end.svg",
                              press: () async {
                                await DatabaseMethods().toggleCallActiveStatus(
                                    widget.chatRoomId, false);
                                await callCut();
                                await widget
                                    .callEndFunction(widget.callEndMessage);
                              },
                              color: kRedColor,
                              iconColor: Colors.white,
                            )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
