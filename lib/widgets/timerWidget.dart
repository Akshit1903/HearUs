import 'dart:async';

import 'package:HearUs/main.dart';

import 'package:HearUs/services/auth.dart';
import 'package:HearUs/util/modals.dart';
import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final Function setStateChanges;
  final AuthMethods auth;
  TimerWidget({@required this.setStateChanges, this.auth});
  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  int timeLim = 180;
  Timer _timer;
  bool runTimer = true;
  showTimer() {
    const dur = Duration(seconds: 1);
    _timer = new Timer.periodic(
      dur,
      (Timer timer) {
        if (runTimer == false || timeLim == 0) {
          print('timer is complete');
          widget.setStateChanges();
          _showMyDialog();
          setState(() {
            timer.cancel();
            runTimer = false;
          });
        } else {
          setState(() {
            timeLim = timeLim - 1;
          });
        }
      },
    );
  }

  DataFromSharedPref userData = new DataFromSharedPref();
  bool isLoad = false;

  void getData() {
    userData.getData().whenComplete(() => setState(() {
          isLoad = true;
        }));
  }

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
                Text(
                    'Listener is unavailable at the moment. Please try another listener.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        settings: RouteSettings(name: "MyApp"),
                        builder: (context) => MyApp(
                              auth: widget.auth,
                            )),
                    (route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    showTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: BoxConstraints(maxHeight: 100),
        decoration: BoxDecoration(
          color: Color(0xFFF4F3F2).withOpacity(0.84),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        width: MediaQuery.of(context).size.width - 20,
        padding: EdgeInsets.all(10),
        child: Center(
          child: Text(
            'Please wait for the listener to join. \nIf the listener seems busy try another listener in $timeLim (s)',
            textAlign: TextAlign.center,
            style: TextStyle(
                letterSpacing: 0.5,
                color: Color(0xFF1E1C61),
                fontSize: 17,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
