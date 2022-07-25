import 'package:HearUs/services/database.dart';
import 'package:HearUs/style/colors.dart';
import 'package:HearUs/style/fonts.dart';
import 'package:HearUs/util/modals.dart';
import 'package:HearUs/util/onboardingUtils.dart';
import 'package:HearUs/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class MentorQuestions extends StatefulWidget {
  final DataFromSharedPref us;
  MentorQuestions({this.us});
  @override
  _MentorQuestionsState createState() => _MentorQuestionsState();
}

class _MentorQuestionsState extends State<MentorQuestions> {
  int pageIndex = 0;
  int rating = 0;
  int newRating;
  DocumentSnapshot mentorCat;
  List<MentorQuestionsContent> _content =
      MentorQuestionsContentUtil.mentorQuestions();
  PageController _controller;
  @override
  void initState() {
    super.initState();
    _controller = PageController();
    scoreGenerate();
    getMentorCat();
    print('progressQuestions: ${progressQuestions.toString()}');
    print('score is $score');
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  int score = 0;
  scoreGenerate() async {
    score = await DatabaseMethods().generateScore(widget.us.myUserId);
  }

  List<dynamic> progressQuestions = [];
  Future getMentorCat() async {
    mentorCat = await FirebaseFirestore.instance
        .collection('mentors')
        .doc('categories')
        .get();
    print('progressQuestions: ${mentorCat.data()["progressQuestions"]}');
    progressQuestions = await mentorCat.data()["progressQuestions"];
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: appBarMain(widget.us, context),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
            color: Color(0xFFF7F3F0).withOpacity(0.1),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: Column(
          children: [
            Container(
              width: size.width,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FutureBuilder(
                        future: scoreGenerate(),
                        builder: (context, snapshot) {
                          return Container(
                            child: Text(
                              'Your Score: $score / 40',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }),
                  ]),
            ),
            FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.us.myUserId)
                    .get(),
                builder: (context, snapshot) {
                  print(
                      "progressQuestions.length :  ${progressQuestions.length}");
                  if (snapshot.hasData) {
                    if (snapshot.data["mentorQuestions"].last["quesNo"] !=
                            (progressQuestions.length - 1) ||
                        (snapshot.data["mentorQuestions"].last["quesNo"] ==
                                (progressQuestions.length - 1)) &&
                            snapshot.data["mentorQuestions"].last["DateTime"]
                                .toDate()
                                .isBefore(
                                    DateTime.now().subtract(Duration(days: 3))))
                      return Expanded(
                        child: PageView(
                          controller: _controller,
                          onPageChanged: (int page) {
                            setState(() {
                              pageIndex = page;
                              rating = 0;
                              newRating = 0;
                            });
                          },
                          children: List.generate(
                            progressQuestions.length,
                            (index) => Container(
                              child: Stack(
                                children: [
                                  Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 40,
                                      ),
                                      // Container(
                                      //     height: size.height * 0.15,
                                      //     width: size.height * 0.15,
                                      //     child: Image.asset('assets/HearUs.png')),
                                      Container(
                                        width: size.width,
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 50, 20, 17),
                                        child: Text(
                                          "${progressQuestions[index]}",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 27,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        padding: EdgeInsets.only(
                                            bottom: (size.height * 0.3) - 40),
                                        width: size.width,
                                        constraints: BoxConstraints(
                                          maxWidth: size.width,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            for (int i = 1; (i <= 10); i++)
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5),
                                                child: InkWell(
                                                    child: (i <= rating)
                                                        ? Column(
                                                            children: [
                                                              Icon(
                                                                Icons.circle,
                                                                color: Colors
                                                                    .white,
                                                                size: 25,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            8.0),
                                                                child: Text(
                                                                  i.toString(),
                                                                  style: AppTextStyle()
                                                                      .bodyStyleWhite,
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        : Column(
                                                            children: [
                                                              Icon(
                                                                Icons.circle,
                                                                color: Colors
                                                                    .grey
                                                                    .shade900,
                                                                size: 25,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            8.0),
                                                                child: Text(
                                                                  i.toString(),
                                                                  style: AppTextStyle()
                                                                      .bodyStyleWhite,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                    onTap: () {
                                                      setState(() {
                                                        rating = i;
                                                        Map<String, dynamic>
                                                            quesrating = {
                                                          "quesNo": index,
                                                          "rating": i,
                                                          "DateTime":
                                                              DateTime.now()
                                                        };
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(widget
                                                                .us.myUserId)
                                                            .update({
                                                          "mentorQuestions":
                                                              FieldValue
                                                                  .arrayUnion([
                                                            quesrating
                                                          ])
                                                        });
                                                      });
                                                      if (pageIndex == 3)
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                'Thanks for the feedback! Press DONE');
                                                      _controller.animateToPage(
                                                          index + 1,
                                                          duration: Duration(
                                                              milliseconds:
                                                                  500),
                                                          curve: Curves.easeIn);
                                                    }),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            bottom: 40, right: 10),
                                        width: size.width,
                                        constraints: BoxConstraints(
                                          maxWidth: size.width,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            (pageIndex != 3)
                                                ? Container()
                                                : Container(
                                                    child: InkWell(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Fill out the questionnaire again in 3 days");
                                                    },
                                                    child: Text('DONE',
                                                        style: AppTextStyle()
                                                            .bodyStyleWhite),
                                                  ))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    child: Container(
                                      padding:
                                          EdgeInsets.fromLTRB(20, 10, 20, 20),
                                      width: size.width,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: <Widget>[
                                          Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                                child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: List.generate(
                                                _content.length,
                                                (index) => Container(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 5),
                                                  height: 10,
                                                  width: 10,
                                                  decoration: BoxDecoration(
                                                    color: (index == pageIndex)
                                                        ? Colors.black
                                                        : Colors.grey,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                  ),
                                                ),
                                              ),
                                            )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );

                    return Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10, vertical: size.height * 0.3),
                      child: Center(
                        child: Text(
                            'Your next Questionaire will be on ${DateFormat('EEEE').format(snapshot.data["mentorQuestions"].last["DateTime"].toDate().add(Duration(days: 3)))}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.bold)),
                      ),
                    );
                  }
                  return LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColor().buttonColor));
                }),
          ],
        ),
      ),
    );
  }
}
