import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListenerActivitySwitch extends StatefulWidget {
  String uid;
  ListenerActivitySwitch(this.uid);
  @override
  _ListenerActivitySwitchState createState() => _ListenerActivitySwitchState();
}

class _ListenerActivitySwitchState extends State<ListenerActivitySwitch> {
  bool _isActive = false;
  @override
  Widget build(BuildContext context) {
    print("uid");
    print(widget.uid);
    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("listeners")
            .doc(widget.uid)
            .get(),
        builder: (ctx, snap) {
          if (snap.hasData) {
            if (snap.data.data().containsKey("isActive")) {
              _isActive = snap.data["isActive"];
            }
          }
          return Column(
            children: [
              Switch(
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                  value: _isActive,
                  onChanged: (val) async {
                    setState(() {
                      _isActive = val;
                    });
                    FirebaseFirestore.instance
                        .collection("listeners")
                        .doc(widget.uid)
                        .update({"isActive": _isActive});
                  }),
              Text(
                _isActive ? "Active" : "Inactive",
                style: TextStyle(color: _isActive ? Colors.green : Colors.red),
              ),
            ],
          );
        });
  }
}
