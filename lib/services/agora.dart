import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import './auth.dart';
import 'dart:convert';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart';
import 'package:agora_rtc_engine/rtc_remote_view.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

const APP_ID = "e6ff91cb78314130abfbcbcbde53967b";

class Agora with ChangeNotifier {
  // var token =
  //     "006e6ff91cb78314130abfbcbcbde53967bIADiZ1wpyzKpkjDPEMlyGsyfq8WaVdvsWLQolNM+tc6iUMRVHEsAAAAAEADaKj8PKhrgYQEAAQAqGuBh";
  bool _joined = false;

  int remoteUid = 0;

  bool _switch = false;
  RtcEngine _engine;
  String token;
  bool get getJoined {
    return _joined;
  }

  final stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onChange: (value) => print('onChange $value'),
    onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
    onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
  );

  String channelName = 'hearus';
  String firebaseUid;
  String baseUrl = "https://hearus-agora-auth.herokuapp.com/tokenserver/";
  bool isListener;

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  Agora([
    this.channelName,
    this.firebaseUid,
    this.isListener = true,
  ]);

  Future<int> getAgoraUid() async {
    //final _currentUser = await _auth.currentUser.uid

    final _uid = firebaseUid;
    var _newUid = "";
    print(_uid);
    for (int i = 0; i < _uid.length; i++) {
      try {
        int.parse(_uid[i]);
        _newUid = "$_newUid${_uid[i]}";
      } catch (e) {}
    }
    return BigInt.parse(_newUid).toInt();
  }

  // Init the app
  Future<void> initPlatformState() async {
    // Get microphone permission
    await [Permission.microphone].request();

    // Create RTC client instance
    RtcEngineContext context = RtcEngineContext(APP_ID);
    _engine = await RtcEngine.createWithContext(context);
    // Define event handling logic
    // _engine.setEventHandler(RtcEngineEventHandler(
    //     joinChannelSuccess: (String channel, int uid, int elapsed) {
    //   print('joinChannelSuccess $channel $uid');

    //   _joined = true;
    //   notifyListeners();
    // }, userJoined: (int uid, int elapsed) {
    //   print('userJoined $uid');
    //   remoteUid = uid;
    //   notifyListeners();
    // }, userOffline: (int uid, UserOfflineReason reason) {
    //   print('userOffline $uid $reason');
    //   print(reason);
    //   remoteUid = 0;
    //   notifyListeners();
    // }));
    // Join channel with channel name as hearus

    final _agoraUid = !isListener ? 2 : 1;
    final _firebaseUid = firebaseUid;
    final _userType = isListener ? 'listener' : 'user';
    final _tokenFieldName = "${_userType}_token";
    final url = baseUrl + channelName;

    if (!isListener) {
      print(url);
      final response = await http.get(
        Uri.parse(url),
      );
      print("token map");
      print(json.decode(response.body));
      print(response.statusCode);
      if (response.statusCode == 200) {
        print(token);
      } else {
        print('Failed to fetch the token');
      }
    }
    final temp = await _db.collection("chatRooms").doc(channelName).get();
    token = temp.data()[_tokenFieldName];
    print("token $token");

    print("final uid$_agoraUid");

    print("details $token $channelName $_agoraUid");
    await _engine.joinChannel(
      token,
      channelName,
      null,
      _agoraUid,
    );
    stopWatchTimer.execute;
    print(await _engine.getCallId());
  }

//   Future<void> getToken() async {
//     final uid = await AuthMethods().getAgoraUid();
//    final response = await http.get(
//      Uri.parse(baseUrl + '/rtc/' + widget.channelName + '/publisher/uid/' + uid.toString()
//           // To add expiry time uncomment the below given line with the time in seconds
//           // + '?expiry=45'
//           ),
//     );

//     if (response.statusCode == 200) {
//         token = response.body;
//         token = jsonDecode(token)['rtcToken'];

//     } else {
//       print('Failed to fetch the token');
//     }
//  }

  Future<RtcEngine> get getEngine async {
    RtcEngine engineDub =
        await RtcEngine.createWithContext(RtcEngineContext(APP_ID));
    return engineDub;
  }

  bool isAlone() {
    return remoteUid == 0;
  }

  void setRemoteUid(int uid) {
    remoteUid = uid;
    notifyListeners();
  }

  int get getRemoteUid {
    print(remoteUid);
    return remoteUid;
  }
}
