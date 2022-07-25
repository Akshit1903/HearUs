import 'package:HearUs/screens/mentorProfile.dart';
import 'package:HearUs/screens/psycho.dart';
import 'package:HearUs/style/colors.dart';

import 'package:HearUs/style/newFonts.dart';
import 'package:HearUs/widgets/listenerActivitySwitch.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../style/fonts.dart';
import '../util/modals.dart';

class MentorListPage extends StatefulWidget {
  final DataFromSharedPref userData;
  MentorListPage({this.userData});

  @override
  _MentorListPageState createState() => _MentorListPageState();
}

class _MentorListPageState extends State<MentorListPage> {
  Widget mentorTile(DocumentSnapshot ds) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: "PsychoProfile"),
          builder: (context) => PsychoProfile(dsa: ds, us: widget.userData),
        ),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Color(0xFFF7F3F0),
          borderRadius: BorderRadius.all(Radius.circular(13)),
        ),
        child: Row(
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // borderRadius: BorderRadius.all(Radius.circular(15)),
                // color: AppColor().gradientLeftColor.withOpacity(0.3),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    ds["imgUrl"],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width - 140,
                  child: Text(
                    ds["name"],
                    style: AppTextStyle().psychoListHeadStyle,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 6.0),
                  width: MediaQuery.of(context).size.width - 140,
                  child: Text(
                    ds['subProfile'],
                    style: AppTextStyle().psychoListbodyStyle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.userData.myUserId);
    return SafeArea(
      child: Container(
          // padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 20,
            padding: EdgeInsets.all(10),
            child: Text("${widget.userData.myUsername}, need help?",
                style: NewAppTextStyle().psychoListMainHeadingStyle),
          ),
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                // width: MediaQuery.of(context).size.width - 20,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: Text("Here are some guides",
                    style: NewAppTextStyle().psychoListMainBodyStyle),
              ),
              Spacer(),
              ListenerActivitySwitch(widget.userData.myUserId),
              IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                              title: Text("What does the switch mean?"),
                              content: Text(
                                  "Turning on the switch will flag you as an active listener, which will help us decide in matching the user to you."),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("OK")),
                              ],
                            ));
                  },
                  icon: Icon(Icons.info)),
              SizedBox(
                width: 20,
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            height: MediaQuery.of(context).size.height - 240,
            child: FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection("mentors")
                  .doc('categories')
                  .get(),
              builder: (context, snapshot) {
                return snapshot.hasData
                    ? Container(
                        height: MediaQuery.of(context).size.height,
                        child: ListView.builder(
                            padding: EdgeInsets.only(bottom: 75, top: 10),
                            // reverse: true,
                            itemCount: snapshot.data["guides"].length,
                            itemBuilder: (context, index) {
                              // DocumentSnapshot ds =
                              //     snapshot.data["guides"][index].data();
                              return InkWell(
                                onTap: () {
                                  showAnswer(context,
                                      snapshot.data["guides"][index]["ans"]);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF7F3F0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(13)),
                                  ),
                                  // height: 100,
                                  constraints: BoxConstraints(
                                      minHeight: 70,
                                      maxWidth:
                                          MediaQuery.of(context).size.width),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Icon(Icons.add,
                                            color: Color(0xFF1E1C61)),
                                      ),
                                      Container(
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                85),
                                        child: Text(
                                          snapshot.data["guides"][index]
                                              ["ques"],
                                          style: AppTextStyle()
                                              .psychoListHeadStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                              backgroundColor: AppColor().mainBackColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColor().buttonColor)),
                        ],
                      );
              },
            ),
          ),
        ],
      )),
    );
  }
}

showAnswer(BuildContext context, String answer) {
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return new Container(
          height: MediaQuery.of(context).size.height * 0.3,
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(children: <Widget>[
            Container(
              // margin: EdgeInsets.symmetric(vertical: 5),
              height: 40,
              decoration: BoxDecoration(
                color: AppColor().buttonColor,
                // borderRadius: BorderRadius.all(Radius.circular(20)),
              ),

              child: Center(
                  child: Text('Answer',
                      style: AppTextStyle().tileHeadingStyleWhite)),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: 1,
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text('$answer',
                                style: TextStyle(fontSize: 17))));
                  }),
            )
          ]),
        );
      });
}
