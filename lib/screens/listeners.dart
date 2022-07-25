import 'dart:async';

import 'dart:math';
import 'package:HearUs/style/colors.dart';
import 'package:HearUs/style/fonts.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/chatScreen.dart';
import '../services/database.dart';
import '../util/modals.dart';
import '../widgets/chatRoomListTile.dart';
import '../widgets/widgets.dart';

class ListenersPage extends StatefulWidget {
  final DataFromSharedPref userData;
  ListenersPage({this.userData});

  @override
  _ListenersPageState createState() => _ListenersPageState();
}

class _ListenersPageState extends State<ListenersPage> {
  bool isSearching = false, stateChange = true;
  Stream usersStream, chatRoomsStream;
  QuerySnapshot listenerData;
  TextEditingController searchUsernameEditingController =
      TextEditingController();

  void setStateChanges() {
    setState(() {
      stateChange = !stateChange;
      print('messages should ${(stateChange) ? 'be' : 'not be'} displayed');
    });
  }

  // getPriceMoreListener() async {
  //   FirebaseFirestore.instance
  //       .collection('mentors')
  //       .doc('categories')
  //       .get()
  //       .then((value) {
  //     priceMoreListener = value.data()["priceMoreListeners"];
  //   });
  // }

  // int priceMoreListener;

  Future<bool> getChangeBool() async {
    return stateChange;
  }

  getChatRoomIdByUsernames(String listener, String user) {
    return "$listener\_$user";
  }

  // Searching a listener on pressing button
  onSearchClick() {
    print(searchUsernameEditingController.text);
    setState(() {
      isSearching = true;
      usersStream = FirebaseFirestore.instance
          .collection("listeners")
          .where("username", isEqualTo: searchUsernameEditingController.text)
          // In order to distinguish between listeners and mentors as both are in the same collection - listeners have this imageUrl while mentor have another
          // This image Url is not called in the app as we now are using asset image for that, still as it was provided earlier could be used here
          .where("imageUrl",
              isEqualTo:
                  'https://cdn.pixabay.com/photo/2012/11/25/06/35/samuel-67197_960_720.jpg')
          .get()
          .asStream();
    });
  }

  QuerySnapshot qs;
  void getThisUserInfo(String username) async {
    qs = await DatabaseMethods().getListenerInfo(username);
  }

  getChatRooms() async {
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  onScreenLoaded() async {
    getChatRooms();
    print("${widget.userData.myUsername}");
    listenerData = await DatabaseMethods().getInstantListener2();
    print("listenerData ${listenerData.docs}");
  }

  @override
  void initState() {
    super.initState();
    onScreenLoaded();
    print("username = ${widget.userData.myUsername}");
    print("userId = ${widget.userData.myUserId}");
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _showCannotChatDialog(context, String random) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Alert'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'You have already left chat with $random. \n\n Try with some other user.'),
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

    int generateRandomNumber(int length) {
      var random = new Random();
      return random.nextInt(length);
    }

    instantChatWithListener() async {
      int sslength = listenerData.docs.length;
      String randomUsername;
      print(generateRandomNumber(sslength));

      Map<String, dynamic> randomListener =
          listenerData.docs[generateRandomNumber(sslength)].data();
      randomUsername = randomListener["username"];
      print(randomUsername);

      var chatRoomId =
          getChatRoomIdByUsernames(randomUsername, widget.userData.myUsername);
      DatabaseMethods()
          .createChatRoom(
              chatRoomId, widget.userData.myUsername, randomUsername)
          .then((value) {
        print("value came out to e $value");
        if (value == 'SHOW') {
          setStateChanges();
          Navigator.push(
            context,
            MaterialPageRoute(
              settings: RouteSettings(name: "ChatScreen"),
              builder: (context) => ChatScreen(
                listener: randomListener,
                setStateChanges: setStateChanges,
                chatRoomId: chatRoomId,
              ),
            ),
          );
        } else if (value == 'DONTSHOW') {
          _showCannotChatDialog(context, randomUsername);
        } else {
          setStateChanges();
          Navigator.push(
            context,
            MaterialPageRoute(
              settings: RouteSettings(name: "ChatScreen"),
              builder: (context) => ChatScreen(
                  listener: randomListener,
                  setStateChanges: setStateChanges,
                  chatRoomId: chatRoomId),
            ),
          );
        }
      });
    }

    Widget searchUsersList() {
      return StreamBuilder(
          stream: usersStream,
          builder: (context, snapshot) {
            return snapshot.hasData
                ? ListView.builder(
                    scrollDirection: Axis.vertical,
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> ds =
                          snapshot.data.docs[index].data();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Material(
                            child: InkWell(
                                onTap: () {
                                  var chatRoomId = getChatRoomIdByUsernames(
                                      ds["username"],
                                      widget.userData.myUsername);
                                  print(chatRoomId);
                                  DatabaseMethods()
                                      .createChatRoom(
                                          chatRoomId,
                                          widget.userData.myUsername,
                                          ds["username"])
                                      .then((value) {
                                    print("value came out to e $value");
                                    if (value == 'SHOW') {
                                      setStateChanges();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          settings:
                                              RouteSettings(name: "ChatScreen"),
                                          builder: (context) => ChatScreen(
                                              listener: ds,
                                              setStateChanges: setStateChanges,
                                              chatRoomId: chatRoomId),
                                        ),
                                      );
                                    } else if (value == 'DONTSHOW') {
                                      _showCannotChatDialog(
                                          context, ds["username"]);
                                    } else {
                                      setStateChanges();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          settings:
                                              RouteSettings(name: "ChatScreen"),
                                          builder: (context) => ChatScreen(
                                              listener: ds,
                                              setStateChanges: setStateChanges,
                                              chatRoomId: chatRoomId),
                                        ),
                                      );
                                    }
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColor().mainBackColor,
                                  ),
                                  child: ListTile(
                                    tileColor: Colors.transparent,
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundColor:
                                          Color(0xFF253334).withOpacity(0.7),
                                      child: Container(
                                          padding: EdgeInsets.all(12),
                                          child: Image.asset(
                                            'assets/hu_white.png',
                                            fit: BoxFit.fill,
                                          )),
                                    ),
                                    title: (ds["username"] != null)
                                        ? Text(ds["username"],
                                            style:
                                                AppTextStyle().tileHeadingStyle)
                                        : Text('name'),
                                  ),
                                ))),
                      );
                    },
                  )
                : LinearProgressIndicator(
                    backgroundColor: AppColor().mainBackColor,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColor().buttonColor));
          });
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 20),
              decoration: BoxDecoration(
                color: Color(0xFFBEC2C2).withOpacity(0.2),
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  isSearching
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                isSearching = false;
                                searchUsernameEditingController.clear();
                              });
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(),
                  Expanded(
                    child: TextField(
                      controller: searchUsernameEditingController,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      decoration: InputDecoration(
                          suffixIcon: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: InkWell(
                              onTap: () {
                                if (searchUsernameEditingController != null) {
                                  onSearchClick();
                                }
                              },
                              child: Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          border: InputBorder.none,
                          hintText: 'Enter Listener ID',
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 16),
                          contentPadding: EdgeInsets.fromLTRB(20, 15, 10, 0)),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 0),
              child: isSearching
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'All results',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFBEC2C2)),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        searchUsersList(),
                      ],
                    )
                  : Container(),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Text(
                    'Recent Chats',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFBEC2C2)),
                  ),
                  Spacer(),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.57,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                children: <Widget>[
                  Container(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("chatRooms")
                            .orderBy("lastMessageTs", descending: true)
                            .where("users",
                                arrayContains: widget.userData.myUsername)
                            .where("dontShow", isEqualTo: false)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            // print(widget.userData.myUsername);
                            // print(snapshot.data.docs);
                            // print(snapshot.data.docs[0]);
                            // final Map<String, dynamic> doc =
                            //     snapshot.data.docs[0].data()
                            //         as Map<String, dynamic>;
                            //print(doc);
                            return (snapshot.data.docs.length == 0)
                                ? Container(
                                    padding:
                                        EdgeInsets.fromLTRB(20, 200, 20, 0),
                                    child: Center(
                                      child: Text(
                                        'No recent chats available',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )
                                : FutureBuilder<bool>(
                                    future: getChangeBool(),
                                    builder:
                                        (context, AsyncSnapshot<bool> snap) {
                                      if (snap.hasData) {
                                        if (snap.data) {
                                          return ListView.builder(
                                            shrinkWrap: true,
                                            physics: ScrollPhysics(),
                                            itemCount:
                                                snapshot.data.docs.length,
                                            itemBuilder: (context, index) {
                                              DocumentSnapshot ds =
                                                  snapshot.data.docs[index];
                                              return ChatRoomListTile(
                                                setStateChanges:
                                                    setStateChanges,
                                                lastMessage: ds["lastMessage"],
                                                isImage: ds["isImage"],
                                                username: ds.id
                                                    .replaceAll(
                                                        widget.userData
                                                            .myUsername,
                                                        "")
                                                    .replaceAll("_", ""),
                                                timeSent: (ds["lastMessageTs"])
                                                    .toDate(),
                                                myUsername:
                                                    widget.userData.myUsername,
                                              );
                                            },
                                          );
                                        }
                                      }
                                      return LinearProgressIndicator(
                                          backgroundColor:
                                              AppColor().mainBackColor,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColor().buttonColor));
                                    });
                          } else {
                            print('no data');
                            return Container(
                              padding: EdgeInsets.fromLTRB(20, 200, 20, 0),
                              child: Center(
                                child: Text(
                                  'No recent chats available',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }
                        }),
                  )
                ],
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 10,
          child: Container(
            width: MediaQuery.of(context).size.width - 40,
            child: button1('CONNECT NOW', Color(0xFF7C9A92), context, () {
              // print('Free chats taken : $countFreeChats');
              instantChatWithListener();
            }),
          ),
        )
      ],
    );
  }
}
