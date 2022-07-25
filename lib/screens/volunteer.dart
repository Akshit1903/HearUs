import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VolunteerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Volunteer at Hear Us",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: WebView(
        initialUrl:
            "https://docs.google.com/forms/d/e/1FAIpQLScyw6dJPAc3fgdYDK3nez9_KD1DUJMu_UkcoFJTxzbh3Q83cQ/viewform?button=",
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
