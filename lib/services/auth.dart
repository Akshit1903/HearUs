import 'package:HearUs/screens/signUpUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/database.dart';
import '../util/sharedPrefHelper.dart';
import 'google_sign_in.dart';
import '';

class AuthMethods {
  AuthMethods authMethods;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User> getCurrentUser() async {
    // ignore: await_only_futures
    return await _auth.currentUser;
  }

  // Future<User> signInWithGoogle() async {
  //   print('start sign in with google');

  //   final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

  //   final GoogleSignInAuthentication googleSignInAuthentication =
  //       await googleSignInAccount.authentication;

  //   final AuthCredential credential = GoogleAuthProvider.credential(
  //       idToken: googleSignInAuthentication.idToken,
  //       accessToken: googleSignInAuthentication.accessToken);

  //   final UserCredential userCredential =
  //       await _auth.signInWithCredential(credential);

  //   final User user = userCredential.user;
  //   return user;
  // }

  // ignore: non_constant_identifier_names
  Future Signin() async {
    // print("adi");
    final user = await GoogleSignApi.login();
    return user;
  }

  Future<DocumentSnapshot> signInGoogleComplete(user) async {
    DocumentSnapshot flag;
    return await DatabaseMethods().checkUserExist(user.id).then((value) async {
      String userImage =
          "https://firebasestorage.googleapis.com/v0/b/hearus-4f2fe.appspot.com/o/assets%2Fhu_white.png?alt=media&token=6bddb58c-fd3f-4af7-8a17-3b2e7104af7d";
      if (value.exists) {
        flag = value;
        print(
            "The user has all ready signed in once ${value.data().toString()}");
        print("Registered userid from user.id is ${user.id}");
        print(
            "Registered username from firebase is ${value.data()["username"]}");
        print("Registered userid from firebase is ${value.data()["id"]}");

        // Saving the credentials in SharedPreferences...
        print("Saving the credentials in SharedPreferences...");
        await SharedPreferenceHelper().saveUserId(user.id).whenComplete(() {
          print("Registered UserId saved ${user.id}");
        });
        await SharedPreferenceHelper()
            .saveUserName(value.data()["username"])
            .whenComplete(() {
          print("Registered Username saved ${value.data()["username"]}");
        });
        await SharedPreferenceHelper().saveUserProfileUrl(userImage);
        // Geting FCM token...
        String fcmToken;
        await FirebaseMessaging.instance.getToken().then((token) async {
          print("token $token");

          fcmToken = token;
          await SharedPreferenceHelper().saveUserFcmToken(token).then((value) {
            if (value) {
              print('token saved successfully!');
            } else {
              print('token could not be saved!');
            }
          });
        }).whenComplete(() async {
          await DatabaseMethods()
              .addFcmToken(value.data()["id"], fcmToken, false)
              .whenComplete(() {
            print("fcm token added to firebase");
          });
        });
      } else {
        String randomUsername = randomAlphaNumeric(12);
        // The user has not registered earlier
        print("The user has not registered earlier");

        // Saving the credentials in SharedPreferences...
        print("Saving the credentials in SharedPreferences...");
        await SharedPreferenceHelper().saveUserId(user.id).whenComplete(() {
          print("Registered UserId saved ${user.id}");
        });
        await SharedPreferenceHelper()
            .saveUserName(randomUsername)
            .whenComplete(() {
          print("Registered Username saved $randomUsername");
        });
        await SharedPreferenceHelper().saveUserProfileUrl(userImage);
        await SharedPreferenceHelper().saveDisplayName("users");
        Map<String, dynamic> userInfoMap = {
          "username": randomUsername,
          "id": user.id,
          "isListener": false,
          "imageUrl": userImage,
          "online": true,
          "hasMentor": false,
          "mentor": {
            "mentorUsername": '',
            "mentorFor": '',
          }
        };
        String fcmToken;
        FirebaseMessaging.instance.getToken().then((token) async {
          print(token);
          fcmToken = token;
          await SharedPreferenceHelper().saveUserFcmToken(token).then((value) {
            if (value) {
              print('token saved successfully!');
            } else {
              print('token could not be saved!');
            }
          });
        }).whenComplete(() {
          DatabaseMethods()
              .addUserInfoToDB(user.id, userInfoMap)
              .whenComplete(() {
            print("User added to database. Now added its fcm token");
            DatabaseMethods().addFcmToken(user.id, fcmToken, false);
          });
        });
      }
    }).whenComplete(() => flag);
  }

  Future<User> signUpUser(
      String username, String email, String password) async {
    UserCredential authCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User user = authCredential.user;
    if (user != null) {
      await SharedPreferenceHelper().saveDisplayName("users");
      await SharedPreferenceHelper().saveUserEmail(user.email);
      await SharedPreferenceHelper().saveUserId(user.uid);
      await SharedPreferenceHelper().saveUserName(username);
      await SharedPreferenceHelper().saveUserProfileUrl(
          'https://firebasestorage.googleapis.com/v0/b/hearus-4f2fe.appspot.com/o/assets%2Fhu_white.png?alt=media&token=6bddb58c-fd3f-4af7-8a17-3b2e7104af7d');
      Map<String, dynamic> newUserInfoMap = {
        "email": user.email,
        "username": username,
        "imageUrl":
            'https://firebasestorage.googleapis.com/v0/b/hearus-4f2fe.appspot.com/o/assets%2Fhu_white.png?alt=media&token=6bddb58c-fd3f-4af7-8a17-3b2e7104af7d',
        "online": true,
        "hasMentor": false,
        "feelOfDay": {
          "feel": 'happy',
          "date": DateTime.now().subtract(Duration(days: 1)),
        },
      };
      DatabaseMethods().addUserInfoToDB(user.uid, newUserInfoMap);
    } else {
      print('couldnot sign up the user');
    }
    return user;
  }

  Future<User> signInUser(
      String email, String password, BuildContext context) async {
    UserCredential authCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    User user = authCredential.user;
    if (user != null) {
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              settings: RouteSettings(name: "SignUpUser"),
              builder: (context) => SignUpUserPage(
                    auth: authMethods,
                  )));
    }
    return user;
  }

  Future<User> signInWithEmailAndPassword(String email, String password) async {
    UserCredential authCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    User user = authCredential.user;
    String usernamefrmEmail;
    usernamefrmEmail = user.email.substring(0, user.email.indexOf('@'));
    if (user != null) {
      await SharedPreferenceHelper().saveDisplayName("listener");
      await SharedPreferenceHelper().saveUserEmail(user.email);
      await SharedPreferenceHelper().saveUserId(user.uid);
      await SharedPreferenceHelper().saveUserName(usernamefrmEmail);
      await SharedPreferenceHelper().saveUserProfileUrl(
          'https://cdn.pixabay.com/photo/2012/11/25/06/35/samuel-67197_960_720.jpg');

      Map<String, dynamic> listenerInfoMap = {
        "email": user.email,
        "username": usernamefrmEmail,
        "imageUrl":
            'https://cdn.pixabay.com/photo/2012/11/25/06/35/samuel-67197_960_720.jpg',
        "rate": 3,
        "rateNo": 1,
        "online": true,
        "isActive": false,
        "isListener": true,
        "id": user.uid
      };

      String fcmToken;
      FirebaseMessaging.instance.getToken().then((token) async {
        print(token);
        fcmToken = token;
        await SharedPreferenceHelper().saveUserFcmToken(token).then((value) {
          if (value) {
            print('token saved successfully!');
          } else {
            print('token could not be saved!');
          }
        });
      }).whenComplete(() {
        DatabaseMethods()
            .addListenerInfoToDB(user.uid, listenerInfoMap)
            .whenComplete(
                () => DatabaseMethods().addFcmToken(user.uid, fcmToken, true));
      });

      print("Listener added to the database with values");
      print("${user.email}");
      print("$usernamefrmEmail");
      print("rate : 3");
      print(fcmToken);
    }
    return user;
  }

  Future signOut() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      DatabaseMethods().removeFcmToken(prefs.getString('USERKEY'), true);
      print(SharedPreferenceHelper.userDisplayKey);
      print(SharedPreferenceHelper.userIdKey);
      prefs.clear();
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future signOutGoogle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DatabaseMethods().removeFcmToken(prefs.getString('USERKEY'), false);
    prefs.clear();
    _auth.signOut();
    googleSignIn.signOut();
    print('sign out done');
  }
}
