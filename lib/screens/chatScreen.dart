import 'dart:async';
import 'dart:io';

import 'package:HearUs/services/agora.dart';
import 'package:HearUs/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:ntp/ntp.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import '../style/colors.dart';
import '../screens/pickImage.dart';
import '../screens/rateListener.dart';
import '../services/database.dart';

import '../style/fonts.dart';
import '../widgets/timerWidget.dart';
import '../widgets/widgets.dart';
import '../util/fcm.dart';
import '../util/sharedPrefHelper.dart';
import './dialScreen/dial_screen.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> listener;
  final Function setStateChanges;
  final String chatRoomId;
  ChatScreen({this.listener, this.setStateChanges, @required this.chatRoomId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isLoadingDeclineCall = false;
  bool _isLoadingAcceptCall = false;
  int limit = 20;
  //List<String> backendMessage = ["#"];
  String messageId;
  Stream messageStream;
  Stream callStream;
  String myName, myProfilePic, myUsername, myEmail, myUserId;
  bool typingStatus = false;
  TextEditingController messageTextEditingController = TextEditingController();
  AuthMethods authMethods = AuthMethods();
  bool _isCallButtonLoading = false;

  getMyInfoFromSharedPref() async {
    myProfilePic = await SharedPreferenceHelper().getUserProfilePic();
    myUsername = await SharedPreferenceHelper().getUserName();
    myUserId = await SharedPreferenceHelper().getUserId();
    myName = await SharedPreferenceHelper().getDisplayName();
    print("myName $myName");
    if (myName == null || myName == "myName") {
      final userMap = await FirebaseFirestore.instance
          .collection("users")
          .doc(myUserId)
          .get();
      print(userMap.data());
      final isListener = userMap.data()["isListener"];
      myName = isListener ? "listener" : "users";
      await SharedPreferenceHelper().saveDisplayName(myName);
    }
  }

  verifyUser(String myUserId) async {
    final db = FirebaseFirestore.instance;
    final response = await db.collection("users").doc(myUserId).get();
    if (!response.exists) {
      db.collection("users").doc(myUserId).set({"uid": myUserId});
    }
  }

  Map<String, dynamic> latestMessageMap;
  addMessage() async {
    print("button tap");

    if (messageTextEditingController.text != "") {
      String message = messageTextEditingController.text;

      var lastMessageTs = await NTP.now();
      if (myUsername == null) {
        print("username was null, firebase is called");
        final value = await FirebaseFirestore.instance
            .collection("listeners")
            .doc(myUserId)
            .get();

        myUsername = value["username"];
        await SharedPreferenceHelper().saveUserName(myUsername);
      }
      Map<String, dynamic> lastMessageInfoMap = {
        "lastMessage": message,
        "lastMessageSentBy": myUsername,
        "lastMessageTs": lastMessageTs,
        "isImage": false,
        "dontShow": false,
        "callActive": false,
        "userTyping": false,
        "listenerTyping": false,
      };

      Map<String, dynamic> messageInfoMap = {
        "Message": message,
        "MessageSentBy": myUsername,
        "ts": lastMessageTs,
        "msgImageUrl": "",
        "isImage": false,
      };
      setState(() {
        latestMessageMap = messageInfoMap;
      });

      // if (messageId == "") {
      //   messageId = randomAlphaNumeric(12);
      // }
      messageTextEditingController.clear();

      print(widget.chatRoomId);
      String coll = (myName == 'listener') ? 'listeners' : 'users';
      await DatabaseMethods().addMessage(widget.chatRoomId, messageInfoMap);
      await DatabaseMethods()
          .updateTypingStatus(coll, widget.chatRoomId, false);
      await DatabaseMethods()
          .updateLastMessageSent(widget.chatRoomId, lastMessageInfoMap);

      messageId = "";
      await sendPushMessage(widget.listener['fcmToken'], myUsername,
          widget.listener['username'], message);
    }
  }

  var manualMessages = {
    'callMade': "Call Initiated",
    'callEnded': "Call Ended",
  };

  manualMessageSender(String message) {
    Map<String, dynamic> messageInfoMap = {
      "Message": message,
      "MessageSentBy": myUsername,
      "ts": DateTime.now(),
      "msgImageUrl": "",
      "isImage": false,
    };
    setState(() {
      latestMessageMap = messageInfoMap;
    });

    if (messageId == "") {
      messageId = randomAlphaNumeric(12);
    }

    DatabaseMethods()
        .addMessage(widget.chatRoomId, messageInfoMap)
        .whenComplete(() {
      messageId = "";
    });
  }

  Widget chatMessageTile(messageDS, bool sendByMe, [bool isLocal = false]) {
    DateTime timeSent;
    if (messageDS == null) {
      return Container();
    }
    timeSent = isLocal ? messageDS["ts"] : messageDS["ts"].toDate();
    if (sendByMe) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 70,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFF1C1E22),
                    borderRadius: BorderRadius.only(
                      topRight: (messageDS['isImage'])
                          ? Radius.circular(30)
                          : Radius.circular(15),
                      topLeft: (messageDS['isImage'])
                          ? Radius.circular(30)
                          : Radius.circular(15),
                      bottomRight: Radius.circular(0),
                      bottomLeft: (messageDS['isImage'])
                          ? Radius.circular(30)
                          : Radius.circular(15),
                    ),
                  ),
                  child: Column(
                    children: [
                      Visibility(
                        visible: messageDS["isImage"],
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(25),
                            topLeft: Radius.circular(25),
                            bottomRight: Radius.circular(0),
                            bottomLeft: Radius.circular(25),
                          ),
                          child: Image.network(
                            '${messageDS["msgImageUrl"]}',
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace stackTrace) {
                              return Icon(Icons.photo_album,
                                  size: 25, color: Colors.white30);
                            },
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext ctx, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return LinearProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.green),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      (messageDS["Message"] != "")
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                messageDS["Message"],
                                textAlign: TextAlign.left,
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                    letterSpacing: 0.45,
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            )
                          : Container()
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${getHour(timeSent.hour)}:${getMin(timeSent.minute)} $ampm',
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Color(0xFF253334),
                  child: Container(
                      padding: EdgeInsets.all(5),
                      child: Image.asset(
                        'assets/hu_white.png',
                        fit: BoxFit.fill,
                      )),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    // width: MediaQuery.of(context).size.width - 70,
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 70,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF101418),
                      borderRadius: BorderRadius.only(
                        topRight: (messageDS['isImage'])
                            ? Radius.circular(30)
                            : Radius.circular(15),
                        bottomRight: (messageDS['isImage'])
                            ? Radius.circular(30)
                            : Radius.circular(15),
                        topLeft: Radius.circular(0),
                        bottomLeft: (messageDS['isImage'])
                            ? Radius.circular(30)
                            : Radius.circular(15),
                      ),
                    ),
                    child: Column(
                      children: [
                        Visibility(
                          visible: messageDS["isImage"],
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                topLeft: Radius.circular(0),
                                bottomRight: Radius.circular(30),
                                bottomLeft: Radius.circular(30)),
                            child: Image.network(
                              '${messageDS["msgImageUrl"]}',
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace stackTrace) {
                                return Icon(
                                  Icons.photo_album,
                                  size: 25,
                                  color: Colors.grey,
                                );
                              },
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext ctx, Widget child,
                                  ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return LinearProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.green),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        (messageDS["Message"] != "")
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  messageDS["Message"],
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.roboto(
                                    textStyle: TextStyle(
                                      letterSpacing: 0.45,
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              )
                            : Container()
                      ],
                    )),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '${getHour(timeSent.hour)}:${getMin(timeSent.minute)} $ampm',
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget chatMessageTileTemp(messageDS) {
    if (messageDS == null) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 70,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF1C1E22),
                  borderRadius: BorderRadius.only(
                    topRight: (messageDS['isImage'])
                        ? Radius.circular(30)
                        : Radius.circular(15),
                    topLeft: (messageDS['isImage'])
                        ? Radius.circular(30)
                        : Radius.circular(15),
                    bottomRight: Radius.circular(0),
                    bottomLeft: (messageDS['isImage'])
                        ? Radius.circular(30)
                        : Radius.circular(15),
                  ),
                ),
                child: Column(
                  children: [
                    Visibility(
                      visible: messageDS["isImage"],
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(25),
                          topLeft: Radius.circular(25),
                          bottomRight: Radius.circular(0),
                          bottomLeft: Radius.circular(25),
                        ),
                        child: Image.network(
                          '${messageDS["msgImageUrl"]}',
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace stackTrace) {
                            return Icon(Icons.photo_album,
                                size: 25, color: Colors.white30);
                          },
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext ctx, Widget child,
                              ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return LinearProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.green),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    (messageDS["Message"] != "")
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              messageDS["Message"],
                              textAlign: TextAlign.left,
                              style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                  letterSpacing: 0.45,
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '${getHour(DateTime.now().hour)}:${getMin(DateTime.now().minute)} $ampm',
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey),
                ),
              ),
            ),
            Icon(
              Icons.timer,
              size: 15,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
      ],
    );
  }

  bool showTimer = false;

  getAndSetMessages() async {
    messageStream =
        await DatabaseMethods().getChaTRoomMessages(widget.chatRoomId, limit);
    setState(() {});
  }

  doThisOnLaunch() async {
    await getMyInfoFromSharedPref();
    getAndSetMessages();
  }

  PickedFile _pickedFile;
  PickedFile get pickedFile => _pickedFile;
  String _imageName = "";
  String get imageName => _imageName;
  File _filePath;
  File get filePath => _filePath;

  Future<void> pickImage() async {
    final imagePicker = ImagePicker();

    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      _pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
      if (_pickedFile != null) {
        _filePath = File(_pickedFile.path);
        _imageName = _filePath.uri.path.split('/').last;
        print(_filePath);
        print(_imageName);
        Navigator.push(
            context,
            MaterialPageRoute(
                settings: RouteSettings(name: "PickImageScreen"),
                builder: (context) => AfterImagePickedScreen(
                    chatroom: widget.chatRoomId,
                    context: context,
                    pickedFile: _pickedFile,
                    filePath: _filePath,
                    imageName: _imageName,
                    sendTo: widget.listener,
                    sendBy: myUsername)));
      } else {
        print("Please pick Image");
      }
    } else {
      print('Permission Granted');
    }
  }

  @override
  void initState() {
    doThisOnLaunch();

    super.initState();
    showTimer = widget.listener['isListener'] ? true : false;
    //print(widget.listener);
  }

  List<DocumentSnapshot> messageMap;
  DocumentSnapshot lastMesssageByUserMap;

  @override
  Widget build(BuildContext context) {
    final agora = Provider.of<Agora>(context);
    Widget chatMessage() {
      return StreamBuilder(
        stream: messageStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            messageMap = snapshot.data.docs;

            if (messageMap.length == 0) {
              return Center(
                child: Container(
                  child: FittedBox(
                    child: Text(
                      "Start a new conversation!",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width * 0.7,
                ),
              );
            }

            // if (messageMap != null) print(messageMap[1]['MessageSentBy']);
            int i = 1;
            if (messageMap.length > 1) {
              if (messageMap != null) {
                while (i < messageMap.length) {
                  if (messageMap[i]["MessageSentBy"] == myUsername) {
                    lastMesssageByUserMap = messageMap[i];
                    break;
                  }
                  i++;
                }
              }
            }
          } else {
            return LinearProgressIndicator();
          }

          if (latestMessageMap != null &&
              lastMesssageByUserMap !=
                  null) if (latestMessageMap['Message'] ==
              lastMesssageByUserMap['Message']) {
            latestMessageMap = null;
          }
          if (messageMap != null) {
            if (messageMap[0]['Message'] == manualMessages["callMade"]) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {});
              });
            }
          }

          return snapshot.hasData
              ? Column(
                  children: [
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification notification) {
                          if (notification.metrics.atEdge) {
                            if (notification.metrics.pixels != 0) {
                              limit += 10;
                              print("limit $limit");
                              getAndSetMessages();
                            }
                          }
                          return true;
                        },
                        child: ListView.builder(
                            padding: EdgeInsets.only(bottom: 10, top: 10),
                            reverse: true,
                            itemCount: messageMap.length,
                            itemBuilder: (context, index) {
                              if (myUsername !=
                                  messageMap[index]["MessageSentBy"])
                                showTimer = false;

                              DocumentSnapshot ds = messageMap[index];
                              // print(ds.data());
                              // if (backendMessage
                              //     .contains(ds.data()[0]["Message"])) {
                              //   return Column();
                              // }
                              if (ds.data()["Message"] ==
                                  manualMessages["callMade"]) {
                                return Center(
                                    child: Container(
                                  padding: EdgeInsets.all(7),
                                  margin: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1C1E22),
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    "${manualMessages["callMade"]}: ${getHour(ds["ts"].toDate().hour)}:${getMin(ds["ts"].toDate().minute)} $ampm",
                                    style: TextStyle(
                                      color: Colors.green[200],
                                    ),
                                  ),
                                ));
                              }
                              if (ds.data()["Message"] ==
                                  manualMessages["callEnded"]) {
                                return Center(
                                    child: Container(
                                  padding: EdgeInsets.all(7),
                                  margin: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1C1E22),
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    "${manualMessages["callEnded"]}: ${getHour(ds["ts"].toDate().hour)}:${getMin(ds["ts"].toDate().minute)} $ampm",
                                    style: TextStyle(
                                      color: Colors.red[200],
                                    ),
                                  ),
                                ));
                              }
                              // print(ds.data()["Message"] == manualMessages[0]);
                              // print(ds.data()["Message"]);
                              // print(manualMessages[]);
                              return Column(
                                // alignment: Alignment.bottomCenter,
                                children: [
                                  chatMessageTile(
                                      ds, myUsername == ds["MessageSentBy"]),
                                  if (myName == "users")
                                    Visibility(
                                      visible: (showTimer &&
                                          index == 0 &&
                                          !widget.listener["email"]
                                              .toString()
                                              .contains('mentor')),
                                      child: Column(
                                        children: [
                                          Container(
                                            // height:
                                            // MediaQuery.of(context).size.height * 0.4,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: TimerWidget(
                                              setStateChanges:
                                                  widget.setStateChanges,
                                              auth: authMethods,
                                            ),
                                          ),
                                          SizedBox(
                                            // height: latestMessageMap != null &&
                                            //         latestMessageMap["Message"] !=
                                            //             messageMap.first["Message"]
                                            //     ? 0
                                            //     : 0,
                                            height: 0,
                                          )
                                        ],
                                      ),
                                    ),
                                ],
                              );
                            }),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    FutureBuilder(
                        future: DatabaseMethods()
                            .getCallActiveStatus(widget.chatRoomId),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            SizedBox();
                          }
                          return snap.hasData
                              ? myName == 'listener'
                                  ? Container(
                                      margin: EdgeInsets.only(
                                          left: 16, right: 16, bottom: 0),
                                      height: snap.data ? 200 : 0,
                                      width: MediaQuery.of(context).size.width,
                                      child: (snap.data)
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                  "${widget.listener["username"]} is trying to call you",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20),
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    _isLoadingAcceptCall
                                                        ? TextButton.icon(
                                                            onPressed: null,
                                                            icon: Icon(
                                                              Icons.call,
                                                              color:
                                                                  Colors.grey,
                                                              size: 40,
                                                            ),
                                                            label: Text(
                                                              "Accept",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ))
                                                        : TextButton.icon(
                                                            onPressed:
                                                                () async {
                                                              setState(() {
                                                                _isLoadingAcceptCall =
                                                                    true;
                                                              });
                                                              Navigator.of(
                                                                      context)
                                                                  .pushNamed(
                                                                      DialScreen
                                                                          .routeName,
                                                                      arguments: {
                                                                    "name": widget
                                                                            .listener[
                                                                        "username"],
                                                                    "chatRoomId":
                                                                        widget
                                                                            .chatRoomId,
                                                                    "callEndMessage":
                                                                        manualMessages[
                                                                            "callEnded"],
                                                                    "callEndFunction":
                                                                        manualMessageSender
                                                                  });
                                                              // await verifyUser(
                                                              //     myUserId);
                                                              await Agora(
                                                                      widget
                                                                          .chatRoomId,
                                                                      myUserId,
                                                                      myName ==
                                                                          'listener')
                                                                  .initPlatformState();
                                                              await DatabaseMethods()
                                                                  .toggleCallActiveStatus(
                                                                      widget
                                                                          .chatRoomId,
                                                                      true);

                                                              // await sendPushMessage(
                                                              //     widget.listener[
                                                              //         'fcmToken'],
                                                              //     myUsername,
                                                              //     widget.listener[
                                                              //         'username'],
                                                              //     "Incoming Call");
                                                              // print("almost thereeee");
                                                              // setState(() {
                                                              //   _isLoadingAcceptCall =
                                                              //       false;
                                                              // });
                                                              setState(() {
                                                                _isLoadingAcceptCall =
                                                                    false;
                                                              });
                                                            },
                                                            icon: Icon(
                                                              Icons.call,
                                                              color:
                                                                  Colors.green,
                                                              size: 40,
                                                            ),
                                                            label:
                                                                Text("Accept")),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    _isLoadingDeclineCall
                                                        ? TextButton.icon(
                                                            onPressed: null,
                                                            icon: Icon(
                                                              Icons.call_end,
                                                              color:
                                                                  Colors.grey,
                                                              size: 40,
                                                            ),
                                                            label:
                                                                Text("Decline"))
                                                        : TextButton.icon(
                                                            onPressed:
                                                                () async {
                                                              print("lessgoo");
                                                              setState(() {
                                                                _isLoadingDeclineCall =
                                                                    true;
                                                              });
                                                              final engine =
                                                                  await Agora()
                                                                      .getEngine;

                                                              await Agora(
                                                                      widget
                                                                          .chatRoomId,
                                                                      myUserId,
                                                                      myName ==
                                                                          'listener')
                                                                  .initPlatformState();
                                                              await DatabaseMethods()
                                                                  .toggleCallActiveStatus(
                                                                      widget
                                                                          .chatRoomId,
                                                                      false);

                                                              await manualMessageSender(
                                                                  manualMessages[
                                                                      "callEnded"]);

                                                              Future.delayed(
                                                                      Duration
                                                                          .zero)
                                                                  .then((e) {
                                                                engine
                                                                    .leaveChannel();
                                                              });

                                                              setState(() {
                                                                _isLoadingDeclineCall =
                                                                    false;
                                                              });

                                                              print("donee");
                                                            },
                                                            icon: Icon(
                                                              Icons.call_end,
                                                              color: Colors.red,
                                                              size: 40,
                                                            ),
                                                            label:
                                                                Text("Decline"),
                                                          )
                                                  ],
                                                ),
                                              ],
                                            )
                                          : Container(),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF101418),
                                        border: Border.all(),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(30),
                                        ),
                                      ),
                                    )
                                  : Container()
                              : Container();
                        }),
                    SizedBox(
                      height: latestMessageMap != null &&
                              latestMessageMap["Message"] !=
                                  messageMap.first["Message"]
                          ? 0
                          : 40,
                    ),
                    Container(
                      height: latestMessageMap != null &&
                              latestMessageMap["Message"] !=
                                  messageMap.first["Message"]
                          ? 130
                          : 0,
                      width: MediaQuery.of(context).size.width,
                      child: chatMessageTileTemp(latestMessageMap),
                    ),
                    // SizedBox(
                    //   height: 65,
                    // ),
                  ],
                )
              : LinearProgressIndicator(
                  backgroundColor: AppColor().mainBackColor,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColor().buttonColor));
        },
      );
    }

    Future<void> _showMyDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Leave chat?'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Do you really want to leave the chat.'),
                  // Text('To resume the chat you would have to request again.'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Rate Listener'),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          settings: RouteSettings(name: "RateListener"),
                          builder: (context) => RateListener(
                                listener: widget.listener,
                                chatRoomid: widget.chatRoomId,
                              )));
                },
              ),
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    callEndFlagFalse() async {
      await DatabaseMethods().toggleCallActiveStatus(widget.chatRoomId, false);
    }

    return WillPopScope(
        onWillPop: () async {
          widget.setStateChanges();
          DatabaseMethods().updateTypingStatus(
              (myName == 'listener') ? 'listeners' : 'users',
              widget.chatRoomId,
              false);
          return true;
        },
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, 70),
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(20, 40, 20, 10),
              // width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color(0xFF253335),
                // boxShadow: [
                //   BoxShadow(
                //       offset: Offset(5, 5), color: Colors.black26, blurRadius: 10),
                // ],
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      widget.setStateChanges();
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 5),
                  Container(
                    child: StreamBuilder2(
                        streams: Tuple2(
                            FirebaseFirestore.instance
                                .collection((widget.listener['isListener'])
                                    ? 'listeners'
                                    : 'users')
                                .doc(widget.listener['id'])
                                .snapshots(),
                            FirebaseFirestore.instance
                                .collection("chatRooms")
                                .doc(widget.chatRoomId)
                                .snapshots()),
                        builder: (context, snapshot) {
                          // if (snapshot.item2.hasData) {
                          //   print("convo map${snapshot.item2.data.data()}");
                          // }
                          //print("online data");
                          //print(snapshot.item1.data.data());
                          //print(
                          //'snapshot.item1.data.data()[]:${snapshot.item1.data.data()['online']}');

                          return Expanded(
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 600),
                              child: Row(children: <Widget>[
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Color(0xFF253334),
                                      child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Image.asset(
                                            'assets/hu_white.png',
                                            fit: BoxFit.fill,
                                          )),
                                    ),
                                    (snapshot.item1.hasData)
                                        ? (snapshot.item1.data.data() != null)
                                            ? (snapshot.item1.data
                                                    .data()
                                                    .containsKey("online"))
                                                ? (snapshot.item1.data
                                                        .data()['online'])
                                                    ? Positioned(
                                                        right: 0,
                                                        child: CircleAvatar(
                                                          radius: 6,
                                                          backgroundColor:
                                                              Colors.white,
                                                          child: CircleAvatar(
                                                            radius: 5,
                                                            backgroundColor:
                                                                Colors.green,
                                                          ),
                                                        ),
                                                      )
                                                    : Container()
                                                : Container()
                                            : Container()
                                        : Container(),
                                  ],
                                ),
                                SizedBox(width: 10),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedContainer(
                                        duration: Duration(milliseconds: 1000),
                                        child: Text(
                                          widget.listener["username"],
                                          style: AppTextStyle()
                                              .tileHeadingStyleWhite,
                                        ),
                                      ),
                                      (snapshot.item1.hasData &&
                                              snapshot.item2.hasData)
                                          ? (snapshot.item1.data
                                                  .data()
                                                  .containsKey('online'))
                                              ? (snapshot.item1.data
                                                          .data()['online'] ==
                                                      true)
                                                  ? (myName == "listener")
                                                      ? (snapshot.item2.data
                                                                  .data() ==
                                                              null)
                                                          ? Container()
                                                          : (snapshot.item2.data
                                                                  .data()
                                                                  .containsKey(
                                                                      "userTyping"))
                                                              ? (snapshot.item2
                                                                          .data[
                                                                      'userTyping'])
                                                                  ? Text(
                                                                      'typing...',
                                                                      style: AppTextStyle()
                                                                          .subtitleStyleWhite,
                                                                    )
                                                                  : Text(
                                                                      'online',
                                                                      style: AppTextStyle()
                                                                          .subtitleStyleWhite,
                                                                    )
                                                              : Text(
                                                                  'online',
                                                                  style: AppTextStyle()
                                                                      .subtitleStyleWhite,
                                                                )
                                                      : (snapshot.item2.data
                                                                  .data() ==
                                                              null)
                                                          ? Container()
                                                          : (snapshot.item2.data
                                                                  .data()
                                                                  .containsKey(
                                                                      "listenerTyping"))
                                                              ? (snapshot.item2
                                                                          .data[
                                                                      'listenerTyping'])
                                                                  ? Text(
                                                                      'typing...',
                                                                      style: AppTextStyle()
                                                                          .subtitleStyleWhite,
                                                                    )
                                                                  : Text(
                                                                      'online',
                                                                      style: AppTextStyle()
                                                                          .subtitleStyleWhite,
                                                                    )
                                                              : Text(
                                                                  'online',
                                                                  style: AppTextStyle()
                                                                      .subtitleStyleWhite,
                                                                )
                                                  : Container()
                                              : Container()
                                          : Container()
                                    ]),
                                Spacer(),
                                if (myName != "listener" &&
                                    !_isCallButtonLoading)
                                  IconButton(
                                    icon: Icon(
                                      Icons.call,
                                      color: (snapshot.item1.hasData)
                                          ? (snapshot.item1.data
                                                      .data()['online'] ==
                                                  true)
                                              ? Color(0xFF3E8469)
                                              : Colors.grey
                                          : Colors.grey,
                                    ),
                                    onPressed: (snapshot.item1.hasData)
                                        ? (snapshot.item1.data.data()['online'])
                                            ? () async {
                                                setState(() {
                                                  _isCallButtonLoading = true;
                                                });
                                                Navigator.of(context).pushNamed(
                                                    DialScreen.routeName,
                                                    arguments: {
                                                      "name": widget
                                                          .listener["username"],
                                                      "chatRoomId":
                                                          widget.chatRoomId,
                                                      "callEndMessage":
                                                          manualMessages[
                                                              "callEnded"],
                                                      "callEndFunction":
                                                          manualMessageSender
                                                    });
                                                //   await verifyUser(myUserId);
                                                await Agora(
                                                        widget.chatRoomId,
                                                        myUserId,
                                                        myName == 'listener')
                                                    .initPlatformState();

                                                await manualMessageSender(
                                                    manualMessages["callMade"]);
                                                await DatabaseMethods()
                                                    .toggleCallActiveStatus(
                                                        widget.chatRoomId,
                                                        true);
                                                await sendPushMessage(
                                                    widget.listener['fcmToken'],
                                                    myUsername,
                                                    widget.listener['username'],
                                                    "Incoming Call");

                                                setState(() {
                                                  _isCallButtonLoading = false;
                                                });
                                              }
                                            : () {
                                                showDialog(
                                                    context: context,
                                                    builder: (ctx) {
                                                      return AlertDialog(
                                                        content: Text(
                                                            "Listener is currently busy, kindly wait for them to be online"),
                                                        title: Text(
                                                            "Listener not currently online!"),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text("OK"))
                                                        ],
                                                      );
                                                    });
                                              }
                                        : () {
                                            showDialog(
                                                context: context,
                                                builder: (ctx) {
                                                  return AlertDialog(
                                                    title: Text(
                                                        "An error occurred!"),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text("OK"),
                                                      )
                                                    ],
                                                  );
                                                });
                                          },
                                  ),
                                if (myName != "listener" &&
                                    _isCallButtonLoading)
                                  IconButton(
                                    onPressed: null,
                                    icon: Icon(
                                      Icons.call,
                                      color: Colors.grey,
                                    ),
                                  )
                              ]),
                            ),
                          );
                          // : Container();
                        }),
                  ),
                  // (widget.listener["isListener"] &&
                  //         !widget.listener["email"].contains('mentor'))
                  //     ? InkWell(
                  //         onTap: () {
                  //           print('Leave button working');
                  //           _showMyDialog();
                  //         },
                  //         child: Container(
                  //           padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  //           decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.all(
                  //               Radius.circular(20),
                  //             ),
                  //             color: Colors.red,
                  //           ),
                  //           child: Text('LEAVE',
                  //               style: GoogleFonts.lato(
                  //                 textStyle: TextStyle(
                  //                     fontSize: 15,
                  //                     fontWeight: FontWeight.bold,
                  //                     color: Colors.white),
                  //               )),
                  //         ),
                  //       )
                  //     : Container(),
                ],
              ),
            ),
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: <Widget>[
                chatMessage(),
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: Color(0xFF7C9A92),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        if (myName != "listener")
                          Container(
                            width: 40,
                            child: IconButton(
                              icon: Icon(
                                Icons.cancel_rounded,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                print('Leave button working');
                                _showMyDialog();
                              },
                            ),
                          ),
                        Container(
                          width: myName == "listener"
                              ? MediaQuery.of(context).size.width - 20
                              : MediaQuery.of(context).size.width - 60,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.45),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          child: TextField(
                            maxLines: 6,
                            controller: messageTextEditingController,
                            onChanged: (text) async {
                              String coll = (myName == 'listener')
                                  ? 'listeners'
                                  : 'users';
                              typingStatus = true;
                              print(
                                  "The user is listener  : ${widget.listener["isListener"]}");
                              print("The user id is : $myUserId");
                              if (messageTextEditingController.text == "") {
                                typingStatus = false;
                              }
                              DatabaseMethods().updateTypingStatus(
                                  coll, widget.chatRoomId, typingStatus);
                              print(messageTextEditingController.text);
                              setState(() {});
                            },
                            style: TextStyle(fontSize: 17),
                            decoration: InputDecoration(
                                suffixIcon: InkWell(
                                  onTap: messageTextEditingController.text == ""
                                      ? null
                                      : () async {
                                          setState(() {
                                            Map<String, dynamic>
                                                messageInfoMap = {
                                              "Message":
                                                  messageTextEditingController
                                                      .text,
                                              "MessageSentBy": myUsername,
                                              "ts": DateTime.now(),
                                              "msgImageUrl": "",
                                              "isImage": false,
                                            };
                                            latestMessageMap = messageInfoMap;
                                          });
                                          await addMessage();
                                        },
                                  child: Icon(
                                    Icons.send,
                                    color:
                                        messageTextEditingController.text == ""
                                            ? Colors.grey
                                            : Color(0xFF3E8469),
                                    size: 25,
                                  ),
                                ),
                                border: InputBorder.none,
                                hintText: 'Send a message',
                                hintStyle: GoogleFonts.alegreyaSans(),
                                contentPadding:
                                    EdgeInsets.fromLTRB(20, 17, 10, 0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
