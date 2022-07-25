import 'dart:async';

import 'package:HearUs/screens/mentorFirstScreen.dart';
import 'package:HearUs/screens/splashScreen.dart';
import 'package:HearUs/util/addData.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/auth.dart';
import 'style/colors.dart';
import 'util/modals.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import './screens/dialScreen/dial_screen.dart';
import './services/agora.dart';
import './services/sleep_timer.dart';

/// Define a top-level named handler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
///

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(MyApp(auth: new AuthMethods()));
}

class MyApp extends StatefulWidget {
  final AuthMethods auth;
  MyApp({this.auth});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DataFromSharedPref userData = new DataFromSharedPref();
  bool isLoad = false;
  void getDatafrmSP() {
    userData.getData().whenComplete(() => setState(() {
          isLoad = true;
        }));
  }

  final String playStoreUrl =
      'https://play.google.com/store/apps/details?id=me.hearus.app';

  versionCheck(context) async {
    //Get Current installed version of app
    final PackageInfo info = await PackageInfo.fromPlatform();
    double currentVersion =
        double.parse(info.version.trim().replaceAll(".", ""));
    print(' current version is $currentVersion');
    //Get Latest version info from firebase config
    final RemoteConfig remoteConfig = RemoteConfig.instance;

    try {
      // Using default duration to force fetching from remote server.
      await remoteConfig.fetch();
      await remoteConfig.activate();
      String forceUpdate =
          remoteConfig.getString('force_update_current_version');
      double newVersion = double.parse(
          remoteConfig.getString('$forceUpdate').trim().replaceAll(".", ""));
      print(remoteConfig.getString(forceUpdate));
      print('New version is $newVersion');
      if (newVersion > currentVersion) {
        _showVersionDialog(context);
      }
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }
  }

  _showVersionDialog(context) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "New Update Available";
        String message =
            "There is a newer version of app available please update it now.";
        String btnLabel = "Update Now";
        String btnLabelCancel = "Later";
        return new AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(btnLabel),
              onPressed: () => _launchURL(playStoreUrl),
            ),
            TextButton(
              child: Text(btnLabelCancel),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    try {
      versionCheck(context);
    } catch (e) {
      print(e);
    }
    getDatafrmSP();
    print("UserId at MyApp is ${userData.myUserId}");
    print(" Username at MyApp is ${userData.myUsername}");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: 'launch_background',
              ),
            ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Agora>(create: (ctx) => Agora()),
        ChangeNotifierProvider<SleepTimer>(create: (ctx) => SleepTimer()),
      ],
      // create: (ctx) => Agora(),
      child: MaterialApp(
        theme: ThemeData(
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          primaryColor: Colors.white,
          indicatorColor: AppColor().buttonColor,
          focusColor: AppColor().buttonColor,
          iconTheme: IconThemeData(color: Colors.white),
          textTheme: GoogleFonts.alegreyaSansTextTheme(
            Theme.of(context).textTheme,
          ),
          scaffoldBackgroundColor: AppColor().mainBackColor,
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(secondary: AppColor().mainBackColor),
        ),
        debugShowCheckedModeBanner: false,
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        home: SplashScreen(widget.auth),
        routes: {
          DialScreen.routeName: (ctx) => DialScreen(),
        },
        // AddData()
      ),
    );
  }
}
