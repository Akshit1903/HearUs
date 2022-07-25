import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../screens/chatScreen.dart';
import '../style/fonts.dart';
import '../widgets/widgets.dart';

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, username, myUsername;
  final DateTime timeSent;
  final Function setStateChanges;
  final bool isImage;
  ChatRoomListTile(
      {this.setStateChanges,
      this.lastMessage,
      this.isImage,
      this.username,
      this.myUsername,
      this.timeSent});

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("listeners")
          .where("username", isEqualTo: widget.username)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                    // color: Color(0xFF7C9A92),
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
                                  '${widget.username}\_${widget.myUsername}'),
                        ),
                      );
                    },
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFF253334).withOpacity(0.7),
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
                    subtitle:
                        (snapshot.data.docs[0].data().containsKey("typing"))
                            ? (snapshot.data.docs[0]["typing"] == false)
                                ? Container(
                                    constraints: BoxConstraints(maxHeight: 34),
                                    child: Text(widget.lastMessage,
                                        style: AppTextStyle().lastMessageStyle),
                                  )
                                : Container(
                                    constraints: BoxConstraints(maxHeight: 34),
                                    child: Text('typing...',
                                        style: AppTextStyle().lastMessageStyle),
                                  )
                            : Container(
                                constraints: BoxConstraints(maxHeight: 34),
                                child: Text(widget.lastMessage,
                                    style: AppTextStyle().lastMessageStyle),
                              ),
                    trailing: (widget.timeSent.isBefore(
                                DateTime.now().subtract(Duration(days: 1))) ==
                            false)
                        ? Text(
                            '${getHour(widget.timeSent.hour)}: ${getMin(widget.timeSent.minute)} $ampm',
                            style: AppTextStyle().lastMessageStyle,
                          )
                        : (widget.timeSent).isBefore(
                                DateTime.now().subtract(Duration(days: 7)))
                            ? Text(
                                '${DateFormat('DD/MM/YY').format(widget.timeSent)}',
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
          );
        }
        return Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                  ),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 1,
              color: Color(0xFFBEC2C2).withOpacity(0.3),
            )
          ],
        );
      },
    );
  }
}
