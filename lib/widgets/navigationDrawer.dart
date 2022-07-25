import 'package:HearUs/main.dart';
import 'package:HearUs/screens/volunteer.dart';

import 'package:HearUs/services/auth.dart';
import 'package:HearUs/style/colors.dart';

import 'package:HearUs/style/newFonts.dart';
import 'package:HearUs/util/modals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationDrawer extends StatefulWidget {
  final DataFromSharedPref userD;
  final AuthMethods auth;
  const NavigationDrawer(this.userD, this.auth);
  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  logoutFunc(context) {
    (widget.userD.myName != 'listener')
        ? widget.auth.signOutGoogle().whenComplete(() {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => MyApp(auth: widget.auth)),
                (route) => false);
          })
        : widget.auth.signOut().whenComplete(() {
            FirebaseFirestore.instance
                .collection("listeners")
                .doc(widget.userD.myUserId)
                .update({
              "isActive": false,
              "online": false,
            });
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => MyApp(auth: widget.auth)),
                (route) => false);
          });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final Email email = Email(
      body: 'This is user ${widget.userD.myUsername}. My problem is ....',
      subject: 'Reporting problem in Hear Us App',
      recipients: ['info@hearus.me'],
      isHTML: false,
    );

    String _url = 'https://play.google.com/store/apps/details?id=me.hearus.app';
    Widget navigationItem(String img, String itemText, IconData icon) {
      return Container(
        child: InkWell(
          onTap: () async {
            if (itemText == 'Rate us') {
              await canLaunch(_url)
                  ? await launch(_url)
                  : throw 'Could not launch $_url';
              print(widget.userD.myName);
            } else if (itemText == "Rules & Guidelines") {
              Navigator.of(context).pop();
              Fluttertoast.showToast(msg: 'Kindly go through the guides');
            } else if (itemText == "Volunteer as a Listener") {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings: RouteSettings(name: 'VolunteeringPage'),
                      builder: (context) => VolunteerScreen()));
            } else if (itemText == 'Share') {
              Share.share(
                  'Download the Hear Us app to talk to trained listeners 24*7 for FREE being completely anonymous.\n\nhttps://play.google.com/store/apps/details?id=me.hearus.app',
                  subject: 'Hear Us - Hear to hear you');
            } else if (itemText == 'Report a Problem') {
              await FlutterEmailSender.send(email);
            } else if (itemText == 'Logout') {
              logoutFunc(context);
            }
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            width: size.width,
            child: Row(
              children: [
                Container(
                    margin: EdgeInsets.only(right: 20),
                    width: 30,
                    height: 30,
                    child: (img != "")
                        ? Image.asset('assets/$img')
                        : Icon(
                            icon,
                            color: Colors.black,
                          )),
                Container(
                  constraints: BoxConstraints(maxWidth: size.width - 100),
                  child: Text(
                    '$itemText',
                    style: GoogleFonts.alegreya(
                      textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColor().textColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Drawer(
      child: SafeArea(
        child: Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(
            color: Color(0xFFF7F3F0),
          ),
          child: Column(
            children: <Widget>[
              Container(
                height: size.height * 0.2,
                width: size.width,
                decoration: BoxDecoration(
                  color: Color(0xFF7C9A92),
                ),
                child: Center(
                  child: Text(
                    'Hi, ${widget.userD.myUsername}!',
                    style: NewAppTextStyle().psychoListMainHeadingStyle,
                  ),
                ),
              ),
              navigationItem("", 'Rate us', Icons.star),
              (widget.userD.myName == "listener")
                  ? navigationItem(
                      "rules.png", 'Rules & Guidelines', Icons.star)
                  : navigationItem(
                      "volunteer.png", 'Volunteer as a Listener', Icons.star),
              navigationItem("", 'Share', Icons.share),
              navigationItem(
                  "report.png", 'Report a Problem', Icons.report_problem),
              navigationItem("", 'Logout', Icons.power_settings_new)
            ],
          ),
        ),
      ),
    );
  }
}
