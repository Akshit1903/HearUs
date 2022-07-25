import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String error;
  ErrorPage({@required this.error});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('ERROR', style: TextStyle(color: Colors.red, fontSize: 30)),
            SizedBox(
              height: 50,
            ),
            Text(error,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.purple, fontSize: 20)),
            SizedBox(
              height: 100,
            ),
            Text('Thank you!',
                style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 30,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
