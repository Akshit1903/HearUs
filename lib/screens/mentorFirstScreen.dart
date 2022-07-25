import 'package:HearUs/screens/mentorSelection.dart';

import 'package:HearUs/style/fonts.dart';
import 'package:HearUs/util/modals.dart';
import 'package:HearUs/widgets/widgets.dart';
import 'package:flutter/material.dart';

class MentorFirstScreen extends StatelessWidget {
  final DataFromSharedPref userData;
  MentorFirstScreen({this.userData});
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<String> whyMentor = [
      'ace important examinations like Board Exams, JEE, NEET',
      'get over tough times such as failure, breakups',
      'improve self esteem and boost self-confidence',
    ];
    List<String> whoMentor = [
      'clear vision and roadmap for success',
      'best insights and personally curated do\'s and dont\'s',
      'expert advice and feedback',
      'right mindset and lifestyle changes'
    ];
    List<String> courseOfAction = [
      'Appointment of mentor followed by induction session where your problems and current progress will be discussed.',
      'Goal setting and Intention setting to give you the starting push to your journey.',
      'Time table setting and necessary lifestyle changes personally curated according to you',
      'Regular interaction and discussion with mentor. The mentor will be available 24/7 for your guidance.',
      'Twice a week feedback sessions and growth tracking with growth tracking tools.'
    ];
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 148,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            decoration: BoxDecoration(
              color: Color(0xFFF7F3F0),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(42), topRight: Radius.circular(42)),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                      margin: EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                        constraints: BoxConstraints(maxWidth: size.width),
                        child: Text(
                          "Every great achiever is inspired by a great mentor",
                          textAlign: TextAlign.center,
                          style: AppTextStyle().headingStyle,
                        ),
                      ),
                    ),
                    Container(
                      height: size.height - 350,
                      width: size.width,
                      child: ListView(
                        children: <Widget>[
                          Text(
                            'Get one-on-one personalised mentorship from our experienced mentors and navigate a success path to your destination.',
                            style: AppTextStyle().bodyStyle,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Who is this Mentorship Program for?\nThe Hear Us Mentorship Program is for anyone who want\'s to ',
                            style: AppTextStyle().bodyStyle,
                          ),
                          for (int i = 0; i < whyMentor.length; i++)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0, vertical: 5),
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
                                    whyMentor[i],
                                    style: AppTextStyle().psychoListbodyStyle,
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Who are the mentors?\nOur Mentors are experienced peers who have already overcome or achieved tough life situations which you are preparing for and are best suited to guide you in your success journey.\n\nThey will provide you with',
                            style: AppTextStyle().bodyStyle,
                          ),
                          for (int i = 0; i < whoMentor.length; i++)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0, vertical: 5),
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
                                    whoMentor[i],
                                    style: AppTextStyle().psychoListbodyStyle,
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'The Course of Action:',
                            style: AppTextStyle().bodyStyle,
                          ),
                          for (int i = 0; i < courseOfAction.length; i++)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0, vertical: 5),
                                  child: Text(
                                    '${i + 1}',
                                    style: AppTextStyle().bodyStyle,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(bottom: 5),
                                  width: MediaQuery.of(context).size.width - 80,
                                  child: Text(
                                    courseOfAction[i],
                                    style: AppTextStyle().psychoListbodyStyle,
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'At Hear Us, we always guarantee you to provide the best mentor suited for you because:\n\"A mediocre mentor tells, A good mentor explains, A superior mentor demonstrated but the greatest mentor inspires\"\nand Hear Us is here to INSPIRE.',
                            style: AppTextStyle().bodyStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 10,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: button1(
                        'APPOINT A MENTOR',
                        Color(0xFF7C9A92),
                        context,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                settings:
                                    RouteSettings(name: "MentorSelectionPage"),
                                builder: (context) =>
                                    MentorSelectionPage(userData: userData)))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
