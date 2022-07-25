import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FeedbackScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Feedback Form"),
      ),
      body: WebView(
        initialUrl:
            "https://docs.google.com/forms/d/e/1FAIpQLSfqTc5kZYY-AyfLfqY-VwRxoI0QZbHsNViKsymGw3i5DxFSpg/viewform?usp=sf_link",
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
