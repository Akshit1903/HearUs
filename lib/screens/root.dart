import 'dart:async';
import 'package:HearUs/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:random_string/random_string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:HearUs/screens/onboardingPage.dart';
import 'package:HearUs/util/sharedPrefHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import '../main.dart';
import '../screens/login.dart';
import '../screens/errorPage.dart';
import '../services/auth.dart';
import '../style/colors.dart';
import '../style/fonts.dart';
import '../widgets/widgets.dart';

class RootPage extends StatefulWidget {
  final AuthMethods auth;
  RootPage({this.auth});
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
        setState(() => _connectionStatus = result.toString());
        break;
      case ConnectivityResult.none:
        _connectivitySubscription.cancel();
        setState(() => _connectionStatus = result.toString());
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                settings: RouteSettings(name: "Error Page"),
                builder: (context) => ErrorPage(
                    error:
                        'Please check your internet connectivity and restart the app!')),
            (route) => false);
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

  bool getStarted = false;
  Future<bool> getStartedBool() async {
    getStarted = await SharedPreferenceHelper().getGetStarted();
    return getStarted;
  }

  static const _url = 'https://hearus.me/termsOfService.html';
  void _launchURL() async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getStartedBool(),
        // initialData: false,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return (getStarted)
              ? Stack(
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
                            child: Text('Welcome',
                                style: AppTextStyle().headingStyle)),
                        Padding(
                            padding: EdgeInsets.all(0),
                            child: Text('Sign in to Continue',
                                style: AppTextStyle().bodyStyle)),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: button1('Sign in with Google',
                              AppColor().buttonColor, context, () {
                            setState(() {
                              isLoading = true;
                            });
                            widget.auth.Signin().then((user) {
                              setState(() {
                                isLoading = false;
                              });

                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      settings: RouteSettings(name: "MyApp"),
                                      builder: (context) =>
                                          MyApp(auth: widget.auth)),
                                  (route) => false);
                            });
                          }),
                        ),
                        Padding(
                            padding: EdgeInsets.all(10),
                            child: Text('Or', style: AppTextStyle().bodyStyle)),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: button1(
                              'Login as a Listener',
                              AppColor().buttonColor,
                              context,
                              () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        settings: RouteSettings(name: "Login"),
                                        builder: (context) =>
                                            LoginPage(auth: widget.auth)),
                                  )),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 10,
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('By signing in, you accept our ',
                                    style: AppTextStyle().termsStyle,
                                    textAlign: TextAlign.center),
                                InkWell(
                                    onTap: _launchURL,
                                    child: Text('Terms and Conditions',
                                        style: AppTextStyle().httpbodyStyle))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isLoading,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          color: Colors.black38,
                          child: LinearProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColor().buttonColor))),
                    ),
                  ],
                )
              : OnboardingPage(auth: widget.auth);
        },
      ),
    );
  }

  // ignore: non_constant_identifier_names, missing_return
  Future SignIn() {}
}
