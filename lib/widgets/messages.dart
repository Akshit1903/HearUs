import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../screens/chatScreen.dart';
import '../services/database.dart';
import '../style/fonts.dart';
import '../widgets/widgets.dart';

class Message extends StatefulWidget {
  final String lastMessage, username, myUsername;
  final Function setStateChanges;
  final DateTime timeSent;
  final bool isImage;
  Message(
      {this.setStateChanges,
      this.lastMessage,
      this.username,
      this.myUsername,
      this.timeSent,
      this.isImage});

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  List<Map<String, dynamic>> queryList = [];
  Future<List<Map<dynamic, dynamic>>> getThisUserInfo() async {
    List<DocumentSnapshot> templist;
    await DatabaseMethods().getUserInfo(widget.username).then((value) {
      templist = value.docs;
    });

    print(templist);

    queryList = templist
        .map((DocumentSnapshot querySnapshot) {
          return querySnapshot.data;
        })
        .cast<Map>()
        .toList();

    setState(() {});
    print(queryList.toString());
    return queryList;
  }

  @override
  void initState() {
    // getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: widget.username)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return (snapshot.data.docs.length != 0)
              ? Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                          // color: Colors.white,
                          ),
                      child: ListTile(
                          onTap: () {
                            widget.setStateChanges();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                settings: RouteSettings(name: "ChatScreen"),
                                builder: (context) => ChatScreen(
                                  listener: snapshot.data.docs[0].data(),
                                  setStateChanges: widget.setStateChanges,
                                  chatRoomId:
                                      "${widget.myUsername}\_${widget.username}",
                                ),
                              ),
                            );
                          },
                          leading: Stack(
                            children: [
                              CircleAvatar(
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
                              Visibility(
                                visible: snapshot.data.docs[0]["online"],
                                child: Positioned(
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 8,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 7,
                                      backgroundColor: Colors.green,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Text('${widget.username}',
                              style: AppTextStyle().tileHeadingStyle),
                          subtitle: (snapshot.data.docs[0]
                                  .data()
                                  .containsKey("typing"))
                              ? (snapshot.data.docs[0]["typing"] == false)
                                  ? Container(
                                      constraints:
                                          BoxConstraints(maxHeight: 34),
                                      child: Text(widget.lastMessage,
                                          style:
                                              AppTextStyle().lastMessageStyle),
                                    )
                                  : Container(
                                      constraints:
                                          BoxConstraints(maxHeight: 34),
                                      child: Text('typing...',
                                          style:
                                              AppTextStyle().lastMessageStyle),
                                    )
                              : Container(
                                  constraints: BoxConstraints(maxHeight: 34),
                                  child: Text(widget.lastMessage,
                                      style: AppTextStyle().lastMessageStyle),
                          ),
                          trailing: (widget.timeSent.isBefore(DateTime.now()
                                      .subtract(Duration(days: 1))) ==
                                  false)
                              ? Text(
                                  '${getHour(widget.timeSent.hour)}: ${getMin(widget.timeSent.minute)} $ampm',
                                  style: AppTextStyle().lastMessageStyle,
                                )
                              : (widget.timeSent.isBefore(DateTime.now()
                                      .subtract(Duration(days: 7))))
                                  ? Text(
                                      '${DateFormat('dd/mm/yy').format(widget.timeSent)}',
                                      style: AppTextStyle().lastMessageStyle,
                                    )
                                  : Text(
                                      '${DateFormat('EEEE').format(widget.timeSent)}',
                                      style: AppTextStyle().lastMessageStyle,
                                    )),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 1,
                      color: Color(0xFFBEC2C2).withOpacity(0.3),
                    )
                  ],
                )
              : Container();
        }
        return Container();
      },
    );
  }
}
