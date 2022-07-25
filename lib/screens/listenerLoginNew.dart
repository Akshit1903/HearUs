import 'package:HearUs/main.dart';
import 'package:HearUs/services/auth.dart';
import 'package:HearUs/style/colors.dart';
import 'package:HearUs/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ListenerState {
  bool isListener = false;
  bool getisListener() {
    return isListener;
  }
}

class ListenerLoginNew extends StatefulWidget {
  final AuthMethods auth;
  ListenerLoginNew({this.auth});
  @override
  _ListenerLoginNewState createState() => _ListenerLoginNewState();
}

class _ListenerLoginNewState extends State<ListenerLoginNew> {
  final _formKey = GlobalKey<FormState>();
  String error = '';

  bool isLoading = false;

  // text field state
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: size.height,
              width: size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: size.height * 0.12,
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Image.asset('assets/hu_white.png',
                        fit: BoxFit.fitHeight),
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Text(
                        'Listener Sign In',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.alegreya(
                            textStyle: TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      )),
                  Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Text(
                        'Hear Us - Here to Hear you',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.alegreyaSans(
                            textStyle: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.normal)),
                      )),
                  SizedBox(
                    height: size.height * 0.1,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(),
                          child: TextFormField(
                            style: GoogleFonts.alegreyaSans(
                              textStyle: TextStyle(
                                color: Color(0xFFBEC2C2),
                              ),
                            ),
                            validator: (val) =>
                                val.isEmpty ? 'Enter an email' : null,
                            onChanged: (val) {
                              setState(() => email = val);
                            },
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                hintStyle: GoogleFonts.alegreyaSans(
                                  textStyle: TextStyle(
                                    color: Color(0xFFBEC2C2),
                                  ),
                                ),
                                hintText: 'Enter Email',
                                contentPadding:
                                    EdgeInsets.fromLTRB(20, 10, 10, 10)),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: TextFormField(
                            style: GoogleFonts.alegreyaSans(
                              textStyle: TextStyle(
                                color: Color(0xFFBEC2C2),
                              ),
                            ),
                            obscureText: true,
                            validator: (val) => val.length < 6
                                ? 'Enter a password 6+ chars long'
                                : null,
                            onChanged: (val) {
                              setState(() => password = val);
                            },
                            decoration: InputDecoration(
                                hintStyle: GoogleFonts.alegreyaSans(
                                  textStyle: TextStyle(
                                    color: Color(0xFFBEC2C2),
                                  ),
                                ),
                                hintText: 'Enter Password',
                                contentPadding:
                                    EdgeInsets.fromLTRB(20, 0, 10, 0)),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child:
                              button1('LOGIN', AppColor().buttonColor, context,
                                  () async {
                            setState(() {
                              isLoading = true;
                            });
                            if (_formKey.currentState.validate()) {
                              print("email : $email password: $password");
                              await widget.auth
                                  .signInWithEmailAndPassword(email, password)
                                  .then((value) {
                                if (value == null) {
                                  setState(() {
                                    isLoading = false;
                                    ListenerState().isListener = false;
                                    error =
                                        'Could not sign in with those credentials';
                                  });
                                } else {
                                  setState(() {
                                    isLoading = false;
                                    ListenerState().isListener = true;
                                  });
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          settings:
                                              RouteSettings(name: "MyApp"),
                                          builder: (context) =>
                                              MyApp(auth: widget.auth)),
                                      (route) => false);
                                }
                              });
                            } else {
                              setState(() {
                                isLoading = false;
                                error =
                                    'Some problem with the details entered!';
                              });
                            }
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: isLoading,
              child: Container(
                width: size.width,
                height: size.height,
                color: Colors.black38,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      LinearProgressIndicator(
                        backgroundColor: AppColor().mainBackColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColor().buttonColor),
                      ),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
