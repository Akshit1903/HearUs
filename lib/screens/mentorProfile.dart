import 'package:HearUs/screens/payment.dart';
import 'package:HearUs/style/colors.dart';
import 'package:HearUs/style/fonts.dart';
import 'package:HearUs/style/newFonts.dart';
import 'package:HearUs/util/modals.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/widgets.dart';

class MentorProfile extends StatefulWidget {
  final DocumentSnapshot dsa;
  final DataFromSharedPref us;
  MentorProfile({this.dsa, this.us});
  @override
  _MentorProfileState createState() => _MentorProfileState();
}

class _MentorProfileState extends State<MentorProfile> {
  @override
  void initState() {
    print(widget.dsa.data());
    super.initState();
  }

  about(BuildContext context, about) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (builder) {
          return Container(
            color: Colors.transparent,
            child: new Container(
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(30),
                    topRight: const Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0, // has the effect of softening the shadow
                    spreadRadius: 0.0, // has the effect of extending the shadow
                  )
                ],
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'MORE INFORMATION',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.purple),
                    ),
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
                                child:
                                    Text(about, textAlign: TextAlign.center)));
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget descriptionTile(
    List<dynamic> list,
    String titleText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              titleText,
              style: AppTextStyle().psychoListHeadStyle,
            )),
        for (int i = 0; i < list.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Color(0xFF7C9A92),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 1.5,
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Container(
                padding: EdgeInsets.only(bottom: 5),
                width: MediaQuery.of(context).size.width - 80,
                child: Text(
                  list[i],
                  style: AppTextStyle().psychoListbodyStyle,
                ),
              ),
            ],
          ),
        SizedBox(
          height: 15,
        ),
        Container(
          color: AppColor().buttonColor.withOpacity(0.1),
          height: 2,
          width: MediaQuery.of(context).size.width - 20,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> langs = widget.dsa.data()["languages"].toList();
    List<dynamic> avail = widget.dsa.data()["availability"].toList();
    List<dynamic> descrip = widget.dsa.data()["description"].toList();
    return Scaffold(
      appBar: appBarMain(widget.us, context),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 97,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              decoration: BoxDecoration(
                color: Color(0xFFF7F3F0),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(42),
                    topRight: Radius.circular(42)),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                        margin: EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(),
                        child: Row(
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                // borderRadius: BorderRadius.all(Radius.circular(15)),
                                color: AppColor()
                                    .gradientLeftColor
                                    .withOpacity(0.3),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    widget.dsa["imgUrl"],
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
                                  width:
                                      MediaQuery.of(context).size.width - 160,
                                  child: Text(
                                    widget.dsa["name"],
                                    style: AppTextStyle().psychoListHeadStyle,
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 160,
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    widget.dsa['subProfile'],
                                    style:
                                        NewAppTextStyle().psychoIntrobodyStyle,
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 160,
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    widget.dsa['address'],
                                    style:
                                        NewAppTextStyle().psychoIntrobodyStyle,
                                  ),
                                ),
                                Container(
                                  width: 150,
                                  child: Stack(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(top: 10),
                                        width: 100,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            for (int i = 1;
                                                i <= widget.dsa['rate'];
                                                i++)
                                              Icon(
                                                Icons.star,
                                                color: Color(0xFF000000),
                                                size: 20,
                                              ),
                                            for (int j = 1;
                                                j <= 5 - widget.dsa['rate'];
                                                j++)
                                              Icon(
                                                Icons.star_border_outlined,
                                                color: Color(0xFF000000),
                                                size: 20,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Languages',
                            style: AppTextStyle().psychoListHeadStyle,
                          )),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          height: 60,
                          child: ListView.builder(
                              physics: ScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: langs.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    langs[index],
                                    style: AppTextStyle().psychoListbodyStyle,
                                  ),
                                );
                              })),
                      Container(
                        color: AppColor().buttonColor.withOpacity(0.1),
                        height: 2,
                        width: MediaQuery.of(context).size.width - 20,
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 4),
                          height: MediaQuery.of(context).size.height - 420,
                          child: ListView.builder(
                              physics: ScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: 1,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    descriptionTile(descrip, "Description"),
                                    descriptionTile(avail, "Availability"),
                                  ],
                                );
                              })),
                    ],
                  ),
                  Positioned(
                    bottom: 10,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: button1(
                          'BOOK APPOINTMENT',
                          Color(0xFF7C9A92),
                          context,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  settings:
                                      RouteSettings(name: "PaymentRazorpay"),
                                  builder: (context) => PaymentRazorpay(
                                        ds: widget.dsa,
                                        userData: widget.us,
                                      )))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
