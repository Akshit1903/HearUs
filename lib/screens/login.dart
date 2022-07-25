import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../main.dart';
import '../services/auth.dart';
import '../style/colors.dart';
import '../style/fonts.dart';
import '../widgets/widgets.dart';

class ListenerState {
  bool isListener = false;
  bool getisListener() {
    return isListener;
  }
}

class LoginPage extends StatefulWidget {
  final AuthMethods auth;
  LoginPage({this.auth});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String error = '';

  bool isLoading = false;

  // text field state
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/HearUs.png'))),
              ),
              SizedBox(
                height: 50,
              ),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('Welcome Listener',
                      style: AppTextStyle().headingStyle)),
              Padding(
                  padding: EdgeInsets.all(0),
                  child: Text('Login to Continue',
                      style: AppTextStyle().bodyStyle)),
              SizedBox(
                height: 20,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0, 5),
                              blurRadius: 5,
                              color: AppColor().buttonColor.withOpacity(0.3)),
                        ],
                      ),
                      child: TextFormField(
                        validator: (val) =>
                            val.isEmpty ? 'Enter an email' : null,
                        onChanged: (val) {
                          setState(() => email = val);
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Email',
                          contentPadding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0, 5),
                              blurRadius: 5,
                              color: AppColor().buttonColor.withOpacity(0.3)),
                        ],
                      ),
                      child: TextFormField(
                        obscureText: true,
                        validator: (val) => val.length < 6
                            ? 'Enter a password 6+ chars long'
                            : null,
                        onChanged: (val) {
                          setState(() => password = val);
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter Password',
                            contentPadding: EdgeInsets.fromLTRB(20, 0, 10, 0)),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child:
                          button1('Continue', AppColor().buttonColor, context,
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
                                      settings: RouteSettings(name: "MyApp"),
                                      builder: (context) =>
                                          MyApp(auth: widget.auth)),
                                  (route) => false);
                            }
                          });
                        } else {
                          setState(() {
                            isLoading = false;
                            error = 'Some problem with the details entered!';
                          });
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Visibility(
            visible: isLoading,
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black38,
                child: LinearProgressIndicator(
                    backgroundColor: AppColor().mainBackColor,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColor().buttonColor))),
          ),
        ],
      ),
    );
  }
}
