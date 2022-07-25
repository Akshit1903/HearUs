import 'dart:io';

import 'package:HearUs/services/database.dart';
import 'package:HearUs/style/colors.dart';
import 'package:HearUs/style/fonts.dart';
import 'package:HearUs/util/fcm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class AfterImagePickedScreen extends StatefulWidget {
  final BuildContext context;
  final String chatroom;
  final PickedFile pickedFile;
  final String imageName;
  final File filePath;
  final String sendBy;
  final Map<String, dynamic> sendTo;
  AfterImagePickedScreen(
      {this.context,
      this.chatroom,
      this.sendBy,
      this.filePath,
      this.imageName,
      this.pickedFile,
      this.sendTo});
  @override
  _AfterImagePickedScreenState createState() => _AfterImagePickedScreenState();
}

class _AfterImagePickedScreenState extends State<AfterImagePickedScreen> {
  TextEditingController messageTextEditingController = TextEditingController();
  String chatRoomId, messageId;
  String myUsername;

  FirebaseFirestore _firebase = FirebaseFirestore.instance;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  bool isLoading = false;
  addImage(bool sendClicked) async {
    setState(() {
      isLoading = true;
    });

    String message = messageTextEditingController.text;

    var lastMessageTs = DateTime.now();

    var imageStatus = await _firebaseStorage
        .ref()
        .child("chat/${widget.imageName}")
        .putFile(widget.filePath)
        .then((value) => value);

    String imageUrl = await imageStatus.ref.getDownloadURL();

    Map<String, dynamic> messageInfoMap = {
      "Message": message,
      "MessageSentBy": widget.sendBy,
      "ts": lastMessageTs,
      "isImage": true,
      "msgImageUrl": imageUrl,
    };
    if (messageId == "") {
      messageId = randomAlphaNumeric(12);
    }

    sendPushMessage(widget.sendTo['fcmToken'], widget.sendBy,
        widget.sendTo['username'], "${widget.sendBy} sent you a photo");

    Map<String, dynamic> lastMessageInfoMap = {
      "lastMessage": message,
      "isImage": true,
      "lastMessageSentBy": widget.sendBy,
      "lastMessageTs": lastMessageTs,
    };

    DatabaseMethods()
        .updateLastMessageSent(widget.chatroom, lastMessageInfoMap)
        .whenComplete(() {
      DatabaseMethods().addMessage(widget.chatroom, messageInfoMap);
      if (sendClicked) {
        setState(() {
          isLoading = false;
        });

        // remove the text in the message input field
        messageTextEditingController.clear();
        // make message id blank to get regenerated on next message send
        messageId = "";
        Navigator.pop(context);
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: PreferredSize(
          preferredSize: Size(size.width, 70),
          child: Container(
            width: size.width,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(widget.sendTo["imageUrl"]),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    '${widget.sendTo['username']}',
                    style: AppTextStyle().bodyStyleWhite,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            Container(
              height: size.height,
              width: size.width,
              child: Image.file(
                widget.filePath,
                height: size.height * 0.5,
                width: size.width,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width - 20,
                  child: TextField(
                    controller: messageTextEditingController,
                    style: TextStyle(fontSize: 17, color: Colors.white),
                    decoration: InputDecoration(
                        suffixIcon: FloatingActionButton(
                          onPressed: () {
                            addImage(true);
                          },
                          backgroundColor: AppColor().buttonColor,
                          child:
                              Icon(Icons.send, color: Colors.white, size: 25),
                        ),
                        border: InputBorder.none,
                        hintText: 'Write a message',
                        hintStyle: TextStyle(color: Colors.white),
                        contentPadding: EdgeInsets.fromLTRB(20, 17, 10, 0)),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: isLoading,
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.black38,
                  child: Center(child: CircularProgressIndicator())),
            ),
          ],
        ),
      ),
    );
  }
}
