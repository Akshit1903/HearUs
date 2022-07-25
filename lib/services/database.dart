import 'package:cloud_firestore/cloud_firestore.dart';
import '../util/sharedPrefHelper.dart';

class DatabaseMethods {
  Future addUserInfoToDB(
      String userId, Map<String, dynamic> userInfoMap) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .get()
        .then((value) {
      if (!value.exists) {
        userInfoMap.addAll({
          'isListener': false,
          'id': userId,
          "typing": false,
        });
        return FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .set(userInfoMap);
      } else {
        FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .update(userInfoMap);
      }
    });
  }

  Future<int> generateScore(String userId) async {
    double score = 0;
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((value) {
      for (int i = 0; i < value["mentorQuestions"].length; i++) {
        print("mentorQuestions length is ${value["mentorQuestions"].length}");
        score += value["mentorQuestions"][i]["rating"];
      }
      score = (score) / ((value["mentorQuestions"].length - 1) / 4);
      print('The score is $score');
      return score.ceil();
    });
  }

  Future checkLastQuestionaire(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((value) {
      if (value["mentorQuestions"][["mentorQuestions"].length]["DateTime"]
              .add(Duration(days: 3)) ==
          DateTime.now()) return true;
    });
  }

  Future updateUserInfoToDB(
      String userId, Map<String, dynamic> userInfoMap) async {
    print('update in DB function called');
    print("userInfoMap $userInfoMap");
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .update(userInfoMap);
  }

  Future updateUserAccessCode(String userId, String accessCode) async {
    print('update in access code called');
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .update({"accessCode": accessCode});
  }

  Future addListenerInfoToDB(
      String listenerId, Map<String, dynamic> listenerInfoMap) async {
    return FirebaseFirestore.instance
        .collection("listeners")
        .doc(listenerId)
        .get()
        .then((value) {
      // if (!value.exists) {
      //   listenerInfoMap.addAll({
      //     'isListener': true,
      //     'id': listenerId,
      //     "typing": false,
      //   });

      //   return FirebaseFirestore.instance
      //       .collection("listeners")
      //       .doc(listenerId)
      //       .update(listenerInfoMap);
      // }
      return FirebaseFirestore.instance
          .collection("listeners")
          .doc(listenerId)
          .set(listenerInfoMap);
    });
  }

  Future<Stream<QuerySnapshot>> getUserByUserName(String username) async {
    return FirebaseFirestore.instance
        .collection("listeners")
        .where("username", isEqualTo: username)
        .get()
        .asStream();
  }

  Future addMessage(String chatRoomId, Map messageInfoMap) async {
    // final map = await FirebaseFirestore.instance
    //     .collection("chatRooms")
    //     .limitToLast(1)
    //     .get();
    // if (map == null || map.size == 0) {
    //   return await FirebaseFirestore.instance
    //       .collection("chatRooms")
    //       .doc(chatRoomId)
    //       .collection("chats")
    //       .doc(messageId)
    //       .set(messageInfoMap);
    // }
    return await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc()
        .set(messageInfoMap);
  }

  Future checkFreeChatCrossed(String username) async {
    // Stream<int> count;
    QuerySnapshot snap;
    await FirebaseFirestore.instance
        .collection('chatRooms')
        .where("users", arrayContains: username)
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        for (int i = 0; i < value.size; i++) {
          snap = await FirebaseFirestore.instance
              .collection('chatRooms')
              .doc(value.docs[i].id)
              .collection('chats')
              .get();
        }
        // return count;
      }
    });
    // return count;
    return snap;
  }

  updateLastMessageSent(String chatRoomId, Map lastMessageInfoMap) {
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
  }

  updateOnlineStatus(
      String collection, String userId, bool onlineStatus) async {
    print("function to update online status called");
    return FirebaseFirestore.instance
        .collection(collection)
        .doc(userId)
        .update({"online": onlineStatus});
  }

  Future<void> updateTypingStatus(
      String collection, String chatRoomId, bool typingStatus) async {
    print("function to update typing status called");

    if (collection == "users") {
      return FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .update({"userTyping": typingStatus});
    }

    return FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .update({"listenerTyping": typingStatus});
  }

  Future<String> createChatRoom(
      String chatRoomId, String myUsername, String randomUser) async {
    print("function to create chat room called");
    String returnValue = 'UNDEFINED';
    bool dontShow = false;
    Map<String, dynamic> chatRoomInfoMap = {
      "users": [myUsername, randomUser],
      "dontShow": dontShow
    };
    await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .get()
        .then(
      (value) {
        if (value.exists) {
          if (value.data()["dontShow"] != false) returnValue = 'DONTSHOW';
        } else if (!value.exists) {
          FirebaseFirestore.instance
              .collection("chatRooms")
              .doc(chatRoomId)
              .set(chatRoomInfoMap)
              .whenComplete(() {
            returnValue = 'SHOW';
          });
        }
      },
    ).whenComplete(() {
      return false;
    });
    return returnValue;
  }

  Future<Stream<QuerySnapshot>> getChaTRoomMessages(
      String chatRoomId, int limit) async {
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("ts", descending: true)
        .limit(limit)
        .snapshots();
  }

  toggleCallActiveStatus(String chatRoomId, [bool callActive]) async {
    var temp = await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .get();
    //print(temp.data());
    await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .update({
      "callActive": callActive ?? !temp["callActive"] ?? false,
    });

    return temp;
  }

  getCallActiveStatus(chatRoomId) async {
    final temp = await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .get();

    return temp["callActive"];
  }

  // Future<Stream<QuerySnapshot>> getCallStatus(chatRoomId) async {
  //   return FirebaseFirestore.instance
  //       .collection("chatRooms")
  //       .doc(chatRoomId)
  //       .collection("call")
  //       .orderBy("ts", descending: true)
  //       .snapshots();
  // }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String myUserName = await SharedPreferenceHelper().getUserName();
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .orderBy("lastMessageTs", descending: true)
        .where("users", arrayContains: myUserName)
        .where("dontShow", isEqualTo: false)
        .snapshots();
  }

  Future<QuerySnapshot> getUserInfo(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .get();
  }

  Future<DocumentSnapshot> getUserInfoUserId(String userId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .get();
  }

  Future<DocumentSnapshot> checkUserExist(String id) async {
    return await FirebaseFirestore.instance.collection("users").doc(id).get();
  }

  Future<QuerySnapshot> getListenerInfo(String username) async {
    return await FirebaseFirestore.instance
        .collection("listeners")
        .where("username", isEqualTo: username)
        .get();
  }

  addFeelofDay(String userid, Map<String, dynamic> feelInfo) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .update({"feelOfDay": feelInfo});
  }

  Future<QuerySnapshot> getInstantListener() {
    return FirebaseFirestore.instance
        .collection("listeners")
        .where("online", isEqualTo: true)
        .where("imageUrl",
            isEqualTo:
                'https://cdn.pixabay.com/photo/2012/11/25/06/35/samuel-67197_960_720.jpg')
        .get();
  }

  Future<QuerySnapshot> getInstantListener2() {
    return FirebaseFirestore.instance
        .collection("listeners")
        .where("isActive", isEqualTo: true)
        .where("imageUrl",
            isEqualTo:
                'https://cdn.pixabay.com/photo/2012/11/25/06/35/samuel-67197_960_720.jpg')
        .get();
  }

  Future<int> getRating(String listenerUsername) async {
    int rate = 0;
    await FirebaseFirestore.instance
        .collection("listeners")
        .where("username", isEqualTo: listenerUsername)
        .get()
        .then((data) {
      print(data.docs[0].data()['rate']);
      rate = data.docs[0].data()['rate'] ?? 0;
    });
    return rate;
  }

  Future<int> getRateNo(String listenerUsername) async {
    int rateNo = 0;
    await FirebaseFirestore.instance
        .collection("listeners")
        .where("username", isEqualTo: listenerUsername)
        .get()
        .then((data) {
      print(data.docs[0].data()['rateNo']);
      rateNo = data.docs[0].data()['rateNo'] ?? 0;
    });
    return rateNo;
  }

  Stream<DocumentSnapshot> getChatRoomStream(String chatRoomId) {
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomId)
        .get()
        .asStream();
  }

  updateRating(String listenerid, int rating, int rateNo) {
    return FirebaseFirestore.instance
        .collection("listeners")
        .doc(listenerid)
        .update({"rate": rating, "rateNo": rateNo});
  }

  updateDontShowtoTRUE(String chatRoomid) {
    return FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(chatRoomid)
        .update({"dontShow": true});
  }

  Future<QuerySnapshot> findMentor(String tag) {
    return FirebaseFirestore.instance
        .collection('listeners')
        .where("tags", arrayContainsAny: ['$tag']).get();
  }

  addUserAsMentee(String user, String mentorUsername) {
    print("function to update mentees called");
    return FirebaseFirestore.instance
        .collection('listeners')
        .where("username", isEqualTo: mentorUsername)
        .get()
        .then((value) {
      FirebaseFirestore.instance
          .collection('listeners')
          .doc(value.docs[0].id)
          .update({
        'mentees': FieldValue.arrayUnion([user])
      });
      print("user added as mentee");
    });
  }

  addMentorToUser(String userId, Map<String, dynamic> mentorInfo) {
    return FirebaseFirestore.instance.collection('users').doc(userId).update({
      "hasMentor": true,
      "mentor": FieldValue.arrayUnion([mentorInfo])
    }).whenComplete(
        () => print('Mentor added to user ${mentorInfo.toString()}'));
  }

  addFcmToken(String uid, String fcmToken, bool listenerOrUser) {
    String listenerOrUserString;
    if (listenerOrUser) {
      // true is for listener
      listenerOrUserString = 'listeners';
    } else {
      //  false is for user
      listenerOrUserString = 'users';
    }
    print(uid);
    return FirebaseFirestore.instance
        .collection(listenerOrUserString)
        .doc(uid)
        .update({'fcmToken': fcmToken});
  }

  removeFcmToken(String uid, bool listenerOrUser) {
    String listenerOrUserString;
    if (listenerOrUser) {
      // true is for listener
      listenerOrUserString = 'listeners';
    } else {
      //  false is for user
      listenerOrUserString = 'users';
    }
    print(uid);
    return FirebaseFirestore.instance
        .collection(listenerOrUserString)
        .doc(uid)
        .update({'fcmToken': '', 'online': false});
  }

  Future<DocumentSnapshot> getUserData(String userId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .get();
  }

  Future<DocumentSnapshot> getBlogAssets() async {
    return await FirebaseFirestore.instance
        .collection("misc")
        .doc("assets")
        .get();
  }

  Future<void> setTaskList(
      List taskList, int completedIndex, String userId) async {
    await FirebaseFirestore.instance.collection("users").doc(userId).update({
      "taskList": taskList,
      "showTasks": true,
      "completedIndex": completedIndex,
    });
  }

  Future<void> setSleepData(
      Map<String, dynamic> sleepMap, String userId) async {
    await FirebaseFirestore.instance.collection("users").doc(userId).update({
      "sleepData": sleepMap,
      "showSleep": true,
    });
  }

  Future<void> setYesterdaySleepData(
      String hour, String minute, String userId) async {
    await FirebaseFirestore.instance.collection("users").doc(userId).update({
      "yesterdaySleepData": {
        "hour": hour,
        "minute": minute,
        "time": DateTime.now().toIso8601String(),
      }
    });
  }
}
