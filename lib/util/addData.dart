import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddData extends StatefulWidget {
  @override
  _AddDataState createState() => _AddDataState();
}

class _AddDataState extends State<AddData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
            child: Text('send data'),
            onPressed: () async {
              Map<String, dynamic> json = {
                "l0VNs0RkdFcMzNxGUh3zfe8FXOt1": {
                  "email": "avni.tyagi17@gmail.com",
                  "username": "hkijgtf317",
                  "fcmToken": "",
                  "isListener": false,
                  "imageUrl":
                      "https://firebasestorage.googleapis.com/v0/b/hearus-4f2fe.appspot.com/o/assets%2FHearUs.png?alt=media&token=982a7e34-9f70-471e-bab4-600874d94f2b",
                  "online": false,
                  "id": "l0VNs0RkdFcMzNxGUh3zfe8FXOt1",
                  "hasMentor": false,
                  "whereInfo": "Hear Us",
                  "typing": false,
                  "feelOfDay": {
                    "feel": 'happy',
                    "date": DateTime.now().subtract(
                      Duration(days: 1),
                    ),
                  }
                },
              };
              json.forEach((key, value) async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(key)
                    .set(value)
                    .whenComplete(() {
                  print('data Added in firebase');
                  print(json.toString());
                  print(key);
                  value.forEach((k, v) {
                    print('$k : $v');
                  });
                });
              });
            }),
      ),
    );
  }
}
