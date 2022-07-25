import 'package:HearUs/screens/chatScreen.dart';
import 'package:HearUs/screens/mentorList.dart';
import 'package:HearUs/services/database.dart';
import 'package:HearUs/style/colors.dart';
import 'package:HearUs/style/fonts.dart';
import 'package:HearUs/widgets/navigationDrawer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/profile.dart';
import '../services/auth.dart';
import '../util/modals.dart';

import '../widgets/messages.dart';

class ListenerHomePage extends StatefulWidget {
  final DataFromSharedPref userData;
  final AuthMethods auth;
  ListenerHomePage({this.userData, this.auth});

  @override
  _ListenerHomePageState createState() => _ListenerHomePageState();
}

class _ListenerHomePageState extends State<ListenerHomePage>
    with WidgetsBindingObserver {
  bool change = true;
  bool isSearching = false;
  Stream usersStream, chatRoomsStream;
  QuerySnapshot listenerData;

  TextEditingController searchUsernameEditingController =
      TextEditingController();

  void setStateChanges() {
    setState(() {
      change = !change;
      print('setStateChanges working');
    });
  }

  Future<bool> getChangeBool() async {
    return change;
  }

  getChatRoomIdByUsernames(String a, String b) {
    return "$b\_$a";
  }

  onSearchClick() {
    print(searchUsernameEditingController.text);
    setState(() {
      isSearching = true;
      usersStream = FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: searchUsernameEditingController.text)
          .get()
          .asStream();
    });
  }

  Future<QuerySnapshot> qs;
  void getThisUserInfo(String username) {
    qs = DatabaseMethods().getUserInfo(username);
  }

  @override
  void initState() {
    print("${widget.userData.toString()}");
    super.initState();
    DatabaseMethods()
        .updateOnlineStatus("listeners", widget.userData.myUserId, true);
    WidgetsBinding.instance.addObserver(this);
  }

  bool onlineStatus = true;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onlineStatus = true;
      setState(() {});
      print("online status triggered should be online: $onlineStatus");
      DatabaseMethods().updateOnlineStatus(
          "listeners", widget.userData.myUserId, onlineStatus);
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      return;
    } else if (state == AppLifecycleState.paused) {
      onlineStatus = false;
      setState(() {});
      print("online status triggered should be offline: $onlineStatus");
      DatabaseMethods().updateOnlineStatus(
          "listeners", widget.userData.myUserId, onlineStatus);
    }
  }

  int selected = 1;
  Widget navigationBar(BuildContext context) {
    double sizeSelected = 30;
    double sizeNotSelected = 25;
    Widget navigationItem(String icon, String iconNot, int page) {
      return SizedBox(
        width: MediaQuery.of(context).size.width / 4,
        child: InkWell(
          onTap: () {
            setState(() {
              selected = page;
              print("page changed to $selected");
            });
          },
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
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      padding: EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 10,
      ),
      decoration: BoxDecoration(color: AppColor().mainBackColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          navigationItem('assets/guideSel.png', 'assets/guide.png', 0),
          navigationItem('assets/chatSel.png', 'assets/chat.png', 1),
          navigationItem('assets/personSel.png', 'assets/Profile.png', 2),
        ],
      ),
    );
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
                      '$random has left your chatRoom. \n\n It will resume only when $random requests again'),
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
                      return Material(
                          child: InkWell(
                              onTap: () {
                                var chatRoomId = getChatRoomIdByUsernames(
                                    widget.userData.myUsername, ds["username"]);
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
                                  color: Colors.white,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                      radius: 30,
                                      backgroundImage: (ds["imageUrl"] != null)
                                          ? NetworkImage(ds["imageUrl"])
                                          : NetworkImage(
                                              'https://cdn.pixabay.com/photo/2012/11/25/06/35/samuel-67197_960_720.jpg')),
                                  title: (ds["username"] != null)
                                      ? Text(ds["username"],
                                          style:
                                              AppTextStyle().tileHeadingStyle)
                                      : Text('name'),
                                ),
                              )));
                    },
                  )
                : Center(
                    child: LinearProgressIndicator(
                      backgroundColor: AppColor().mainBackColor,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColor().buttonColor),
                    ),
                  );
          });
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
      drawer: NavigationDrawer(widget.userData, widget.auth),
      body: SafeArea(
          child: (selected == 1)
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      ListView(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.only(top: 15),
                              child: isSearching
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            'ALL RESULTS',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        searchUsersList(),
                                      ],
                                    )
                                  : Container()),
                          Container(
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                            child: Text(
                              'Recent Chats',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFBEC2C2)),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.73,
                            width: MediaQuery.of(context).size.width,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              itemCount: 1,
                              itemBuilder: (BuildContext context, int index) {
                                return StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection("chatRooms")
                                        .orderBy("lastMessageTs",
                                            descending: true)
                                        .where("users",
                                            arrayContains:
                                                widget.userData.myUsername)
                                        .where("dontShow", isEqualTo: false)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        // print("snapshot ka data");
                                        // print("${widget.userData.myUsername}");
                                        // print(snapshot.data.docs);
                                        return (snapshot.data.docs.length == 0)
                                            ? Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    20, 200, 20, 0),
                                                child: Center(
                                                  child: Text(
                                                    'No recent chats available',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              )
                                            : FutureBuilder<bool>(
                                                future: getChangeBool(),
                                                builder: (context,
                                                    AsyncSnapshot<bool> snap) {
                                                  if (snap.hasData) {
                                                    if (snap.data) {
                                                      return ListView.builder(
                                                        shrinkWrap: true,
                                                        physics:
                                                            ScrollPhysics(),
                                                        itemCount: snapshot
                                                            .data.docs.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          DocumentSnapshot ds =
                                                              snapshot.data
                                                                  .docs[index];
                                                          return Message(
                                                              setStateChanges:
                                                                  setStateChanges,
                                                              lastMessage: ds[
                                                                  "lastMessage"],
                                                              isImage:
                                                                  ds["isImage"],
                                                              username: ds.id
                                                                  .replaceAll(
                                                                      widget
                                                                          .userData
                                                                          .myUsername,
                                                                      "")
                                                                  .replaceAll(
                                                                      "_", ""),
                                                              timeSent:
                                                                  (ds["lastMessageTs"])
                                                                      .toDate(),
                                                              myUsername: widget
                                                                  .userData
                                                                  .myUsername);
                                                        },
                                                      );
                                                    }
                                                  } else {
                                                    return Center(
                                                        child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: LinearProgressIndicator(
                                                          backgroundColor:
                                                              AppColor()
                                                                  .mainBackColor,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  AppColor()
                                                                      .buttonColor)),
                                                    ));
                                                  }
                                                  return Center(
                                                      child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: LinearProgressIndicator(
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                AppColor()
                                                                    .buttonColor)),
                                                  ));
                                                });
                                      } else {
                                        print('no data');
                                        return Container(
                                          padding: EdgeInsets.fromLTRB(
                                              20, 200, 20, 0),
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
                                    });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : (selected == 2)
                  ? ListenerProfile(
                      listenerUsername: widget.userData.myUsername,
                      profilePicUrl: widget.userData.myProfilePic,
                    )
                  : SingleChildScrollView(
                      child: MentorListPage(
                        userData: widget.userData,
                      ),
                    )),
    );
  }
}
