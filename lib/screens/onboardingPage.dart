import 'package:HearUs/screens/root.dart';
import 'package:HearUs/services/auth.dart';
import 'package:HearUs/style/fonts.dart';
import 'package:HearUs/util/onboardingUtils.dart';
import 'package:HearUs/util/sharedPrefHelper.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  final AuthMethods auth;
  OnboardingPage({this.auth});
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  List<OnboardingContent> _content = OnBoardingUtil.getOnboarding();
  int pageIndex = 0;

  PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (int page) {
                setState(() {
                  pageIndex = page;
                });
              },
              children: List.generate(
                _content.length,
                (index) => Container(
                    width: size.width,
                    height: size.height,
                    child: Stack(
                      children: [
                        Column(
                          children: <Widget>[
                            SizedBox(
                              height: 40,
                            ),
                            Container(
                                height: size.height * 0.15,
                                width: size.height * 0.15,
                                child: Image.asset('assets/HearUs.png')),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 50, 20, 17),
                              child: Text(
                                "${_content[index].message}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 27,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: (index == 0)
                                  ? size.height * 0.03
                                  : size.height * 0.011,
                            ),
                            Stack(
                              children: <Widget>[
                                Container(
                                  width: size.width,
                                  child: Image.asset(
                                    'assets/${_content[index].backImg}',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  child: Container(
                                      child: Image.asset(
                                    'assets/${_content[index].img}',
                                    fit: BoxFit.cover,
                                  )),
                                )
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 10,
                          child: Container(
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                            width: size.width,
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      _content.length,
                                      (index) => Container(
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        height: 10,
                                        width: 10,
                                        decoration: BoxDecoration(
                                          color: (index == pageIndex)
                                              ? Colors.black
                                              : Colors.grey,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                      ),
                                    ),
                                  )),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Visibility(
                                    visible: (pageIndex == 1),
                                    child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            SharedPreferenceHelper()
                                                .saveGetStarted(true);
                                          });
                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  settings: RouteSettings(
                                                      name: "Root"),
                                                  builder: (context) =>
                                                      RootPage(
                                                        auth: widget.auth,
                                                      )),
                                              (route) => false);
                                        },
                                        child: Text('Get Started',
                                            style: AppTextStyle()
                                                .chatSenderStyle)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
