import 'package:HearUs/style/fonts.dart';
import 'package:flutter/material.dart';

class AnxietyBlog extends StatelessWidget {
  String blogContent;
  AnxietyBlog(this.blogContent);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              //height: MediaQuery.of(context).size.height - 150,
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
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                          constraints: BoxConstraints(maxWidth: size.width),
                          child: Text(
                            "Reduce Anxiety",
                            textAlign: TextAlign.center,
                            style: AppTextStyle().headingStyle,
                          ),
                        ),
                      ),
                      Image.asset(
                        "assets/dashboard/anxiety.jpg",
                        width: size.width,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        // height : size.height - 350,
                        width: size.width,
                        child: Column(
                          children: <Widget>[
                            // Text(
                            //   "Have you ever noticed that having a single scheduled meeting wrecks up your entire day?",
                            //   style: AppTextStyle().bodyStyleBold,
                            // ),
                            // SizedBox(
                            //   height: 20,
                            // ),
                            Text(
                              blogContent,
                              style: AppTextStyle().bodyStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
