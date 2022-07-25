import 'package:HearUs/screens/payment.dart';
import 'package:HearUs/style/colors.dart';
import 'package:HearUs/style/fonts.dart';
import 'package:HearUs/util/modals.dart';
import 'package:HearUs/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MentorSelectionPage extends StatefulWidget {
  final DataFromSharedPref userData;
  MentorSelectionPage({this.userData});
  @override
  _MentorSelectionPageState createState() => _MentorSelectionPageState();
}

class _MentorSelectionPageState extends State<MentorSelectionPage> {
  String selectedCat = "";
  int selectedCatInt = -1;
  String mentorshipDuration = "";
  int selectedDuration = -1;
  int priceSelected;
  Widget categoryButton(String text, int i) {
    bool selected = false;
    if (selectedCatInt == i) {
      selected = true;
    } else
      selected = false;
    return Container(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedCat = text;
            selectedCatInt = i;
            stepNo = 2;
          });
          print("selected category is $selectedCat");
          print("selected category Integer is $selectedCatInt");
          Fluttertoast.showToast(
              msg: "$selectedCat is selected", backgroundColor: Colors.black);
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          decoration: BoxDecoration(
              color: (selected)
                  ? AppColor().buttonColor
                  : AppColor().mainBackColor),
          child: Text(
            text,
            style: AppTextStyle().bodyStyleWhite,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget durationButton(String duration, int price, int i) {
    bool selected = false;
    if (selectedDuration == i) {
      selected = true;
    } else
      selected = false;
    return Container(
      child: InkWell(
        onTap: () {
          setState(() {
            mentorshipDuration = duration;
            selectedDuration = i;
            priceSelected = price;
            // stepNo = 3;
          });
          print("selected duration is $mentorshipDuration");
          print("selected duration Integer is $selectedDuration");
          print("selected price is $priceSelected");
          Fluttertoast.showToast(
              msg:
                  "Mentorship for $mentorshipDuration is selected \nPayable Price: Rs.$priceSelected",
              backgroundColor: Colors.black);
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          decoration: BoxDecoration(
              color: (selected)
                  ? AppColor().buttonColor
                  : AppColor().mainBackColor),
          child: Text(
            "$duration        Rs.${price.toString()}",
            style: AppTextStyle().bodyStyleWhite,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  int stepNo = 0;
  String emailUser = '';
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    Future<void> dialogEnterDetails() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Alert'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Please enter both the details'),
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
        appBar: appBarMain(widget.userData, context),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 90,
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
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 5),
                            margin: EdgeInsets.only(top: 20),
                            decoration: BoxDecoration(),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 10),
                              constraints: BoxConstraints(maxWidth: size.width),
                              child: Text(
                                'Appoint a Mentor',
                                textAlign: TextAlign.center,
                                style: AppTextStyle().headingStyle,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              stepNo = 1;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            width: size.width,
                            constraints: BoxConstraints(maxWidth: size.width),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1, color: AppColor().mainBackColor)),
                            child: Text(
                              'Step 1 : Select the category you want the mentor for.',
                              style: AppTextStyle().psychoListHeadStyle,
                            ),
                          ),
                        ),
                        (stepNo == 1)
                            ? FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('mentors')
                                    .doc('categories')
                                    .get(),
                                builder: (context,
                                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                        child: LinearProgressIndicator(
                                            backgroundColor:
                                                AppColor().mainBackColor,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AppColor().buttonColor)));
                                  } else {
                                    return AnimatedContainer(
                                        decoration: BoxDecoration(),
                                        curve: Curves.decelerate,
                                        duration: Duration(milliseconds: 1000),
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
                                        constraints: BoxConstraints(
                                            maxHeight: size.height - 490),
                                        child: ListView.builder(
                                            itemCount: snapshot
                                                .data["categories"].length,
                                            scrollDirection: Axis.vertical,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return categoryButton(
                                                  snapshot.data["categories"]
                                                      [index],
                                                  index);
                                            }));
                                  }
                                })
                            : Container(),
                        InkWell(
                          onTap: () {
                            setState(() {
                              stepNo = 2;
                            });
                          },
                          child: Visibility(
                            visible: (stepNo != 1 ||
                                (stepNo == 1) && (selectedCatInt != -1)),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 2000),
                              margin: EdgeInsets.symmetric(vertical: 10),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              width: size.width,
                              constraints: BoxConstraints(maxWidth: size.width),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1,
                                      color: AppColor().mainBackColor)),
                              child: Text(
                                'Step 2 : Select Duration of mentorship',
                                style: AppTextStyle().psychoListHeadStyle,
                              ),
                            ),
                          ),
                        ),
                        (stepNo == 2)
                            ? FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('mentors')
                                    .doc('categories')
                                    .get(),
                                builder: (context,
                                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                        child: LinearProgressIndicator(
                                            backgroundColor:
                                                AppColor().mainBackColor,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AppColor().buttonColor)));
                                  } else {
                                    return AnimatedContainer(
                                        duration: Duration(milliseconds: 1000),
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
                                        constraints: BoxConstraints(
                                            maxHeight: size.height - 490),
                                        child: ListView.builder(
                                            itemCount: snapshot
                                                .data["duration"].length,
                                            scrollDirection: Axis.vertical,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return durationButton(
                                                  snapshot.data["duration"]
                                                      [index]["duration"],
                                                  snapshot.data["duration"]
                                                      [index]["price"],
                                                  index);
                                            }));
                                  }
                                })
                            : Container(),
                      ],
                    ),
                    Positioned(
                      bottom: 10,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 40,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: button1(
                            'PROCEED FOR PAYMENT', Color(0xFF7C9A92), context,
                            () {
                          if (selectedCat != '' && selectedDuration != null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    settings:
                                        RouteSettings(name: "PaymentRazorpay"),
                                    builder: (context) => PaymentRazorpay(
                                          userData: widget.userData,
                                          amount: priceSelected,
                                          paymentfor: '$selectedCat Mentor',
                                        )));
                          } else {
                            dialogEnterDetails();
                          }
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
