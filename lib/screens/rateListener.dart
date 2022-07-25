import 'package:HearUs/style/colors.dart';
import 'package:HearUs/style/fonts.dart';
import 'package:HearUs/util/modals.dart';
import 'package:flutter/material.dart';
import '../services/database.dart';
import 'feedback.dart';

class RateListener extends StatefulWidget {
  final Map<String, dynamic> listener;
  final String chatRoomid;
  RateListener({this.listener, this.chatRoomid});
  @override
  _RateListenerState createState() => _RateListenerState();
}

class _RateListenerState extends State<RateListener> {
  int rating = 0;
  int newRating;
  int getNewRating() {
    return ((((widget.listener["rate"]) * (widget.listener["rateNo"])) +
                rating) /
            (widget.listener["rateNo"] + 1))
        .round();
  }

  @override
  void initState() {
    print('username : ${widget.listener["username"]}');
    print('profilePic : ${widget.listener["imageUrl"]}');
    print('rate : ${widget.listener["rate"]}');
    print('rateNo : ${widget.listener["rateNo"]}');
    super.initState();
  }

  DataFromSharedPref userData = new DataFromSharedPref();
  bool isLoad = false;

  void getData() {
    userData.getData().whenComplete(() => setState(() {
          isLoad = true;
        }));
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _showMyDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Alert'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Please give your feedback'),
                  // Text('To resume the chat you would have to request again.'),
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

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircleAvatar(
                  radius: 50,
                  backgroundImage: (widget.listener["imageUrl"] != null)
                      ? NetworkImage("${widget.listener["imageUrl"]}")
                      : AssetImage('assets/back1.jpg')),
            ),
            Container(
              child: (widget.listener["username"] != null)
                  ? Text(
                      "${widget.listener["username"]}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    )
                  : Text(''),
            ),
            SizedBox(height: 50),
            Text('Rate Listener', style: AppTextStyle().tileHeadingStyleWhite),
            SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width - 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = 1; (i <= 5); i++)
                    IconButton(
                        padding: EdgeInsets.all(0),
                        icon: (i <= rating)
                            ? Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 30,
                              )
                            : Icon(
                                Icons.star_border_outlined,
                                color: Colors.grey,
                                size: 30,
                              ),
                        onPressed: () {
                          setState(() {
                            rating = i;
                            newRating = getNewRating();
                          });
                          print("OLDrating: ${widget.listener["rate"]}");
                          print("rateNo: ${widget.listener["rateNo"]}");
                          print("rating: $rating");
                          print("newRating: $newRating");
                        }),
                ],
              ),
            ),
            Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                child: InkWell(
                  onTap: () {
                    print("newRating: $newRating");
                    if (newRating != null) {
                      DatabaseMethods()
                          .updateRating(widget.listener["id"], newRating,
                              (widget.listener["rateNo"] + 1))
                          .whenComplete(() {
                        DatabaseMethods()
                            .updateDontShowtoTRUE(widget.chatRoomid);
                      }).whenComplete(
                        () {
                          Navigator.of(context).pop();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  settings: RouteSettings(name: "FeedbackPage"),
                                  builder: (context) => FeedbackScreen()),
                              (route) => false);
                        },
                      );
                    } else {
                      _showMyDialog();
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                      color: AppColor().buttonColor,
                    ),
                    child: Text(
                      "Submit and leave chat",
                      style: AppTextStyle().bodyStyleWhite,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
