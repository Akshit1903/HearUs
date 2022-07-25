import 'package:HearUs/util/modals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../style/colors.dart';
import '../style/fonts.dart';

Widget button1(text, color1, context, next, {Future Function() onPressed}) {
  return InkWell(
    onTap: () {
      next();
    },
    child: Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
          color: color1),
      child: Text(
        text,
        style: AppTextStyle().bodyStyleWhite,
        textAlign: TextAlign.center,
      ),
    ),
  );
}

Widget button2(text, color1, context, next, {Future Function() onPressed}) {
  return InkWell(
    onTap: () {
      next();
    },
    child: Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
          color: AppColor().mainBackColor),
      child: Text(
        text,
        style: AppTextStyle().bodyStyleWhite,
        textAlign: TextAlign.center,
      ),
    ),
  );
}

Widget buttonGradient(
    text, Color colorL, Color colorR, context, Function next) {
  return InkWell(
    onTap: () {
      next();
    },
    child: Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end:
              Alignment(0.8, 0.0), // 10% of the width, so there are ten blinds.
          colors: <Color>[colorL, colorR],
        ),
      ),
      child: Text(
        text,
        style: AppTextStyle().bodyStyleWhite,
        textAlign: TextAlign.center,
      ),
    ),
  );
}

Widget homeButton(
    buttonTitle, buttonSub, buttonText, img, context, Function() next,
    {bool isSvg = false}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    padding: EdgeInsets.all(10),
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(
        Radius.circular(20),
      ),
      color: Colors.white,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.6 - 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                child: Text(
                  buttonTitle,
                  style: AppTextStyle().headingStyle,
                  textAlign: TextAlign.left,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Text(
                  buttonSub,
                  style: AppTextStyle().bodyStyle,
                  textAlign: TextAlign.left,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: InkWell(
                  onTap: () {
                    next();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6 - 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color(0xFF253334),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '$buttonText',
                      style: AppTextStyle().bodyStyleWhite,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          child: (isSvg)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SvgPicture.asset(
                    'assets/$img',
                    fit: BoxFit.fitHeight,
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/$img',
                    fit: BoxFit.fitHeight,
                  ),
                ),
          height: 130,
          width: MediaQuery.of(context).size.width * 0.4 - 20,
          decoration: BoxDecoration(
            // image: DecorationImage(
            //   image: (isSvg)
            //       ? SvgPicture.asset('assets/$img')
            //       : AssetImage('assets/$img'),
            //   fit: BoxFit.fitHeight,
            // ),
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            // color: Colors.purple.shade100
          ),
        ),
      ],
    ),
  );
}

Widget iconButton(BuildContext context, img, txt, Function todo) {
  return Container(
    width: MediaQuery.of(context).size.width,
    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.all(Radius.circular(50)),
      border: Border.all(color: Colors.purpleAccent, width: 2),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          todo();
        },
        child: Center(
          child: ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/$img'),
                radius: 20,
              ),
              title: Text(
                '$txt',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white),
                textAlign: TextAlign.center,
              )),
        ),
      ),
    ),
  );
}

Widget actionButton(context, Function next, IconData icon, Color color1) {
  return Container(
    margin: EdgeInsets.only(left: 10),
    child: InkWell(
      splashColor: Colors.purple,
      onTap: next,
      child: Icon(
        icon,
        color: color1,
        size: 30,
      ),
    ),
  );
}

Route createRoute(double x, double y, Function next) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => next(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(x, y);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

String ampm = "am";
int getHour(int hour) {
  if (hour > 12) {
    ampm = 'pm';
    return (hour - 12);
  } else {
    ampm = 'am';
    return hour;
  }
}

String getMin(int min) {
  if (min < 10) {
    return ("0$min");
  } else {
    return ("$min");
  }
}

PreferredSizeWidget appBarNormal(text) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 10,
    shadowColor: AppColor().buttonColor.withOpacity(0.3),
    leadingWidth: 30,
    iconTheme: IconThemeData(color: Colors.black),
    title: Text(
      '$text',
      style: AppTextStyle().headingStyle,
    ),
  );
}

PreferredSizeWidget appBarMain(DataFromSharedPref us, BuildContext context) {
  return AppBar(
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    backgroundColor: Colors.transparent,
    leadingWidth: 30,
    actions: [
      Container(
        margin: EdgeInsets.only(right: 10),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFF253334),
          child: Container(
              padding: EdgeInsets.all(6),
              child: Image.asset(
                'assets/hu_white.png',
                fit: BoxFit.fill,
              )),
        ),
      )
    ],
  );
}

Widget appBarGradient(
    String text, Color colorL, Color colorR, Widget child, context) {
  return Container(
    width: MediaQuery.of(context).size.width,
    padding: EdgeInsets.fromLTRB(10, 50, 10, 20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment(0.8, 0.0), // 10% of the width, so there are ten blinds.
        colors: <Color>[colorL, colorR],
      ),
    ),
    child: child,
  );
}
