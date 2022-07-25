import 'dart:convert';
import 'package:http/http.dart' as http;

/// The API endpoint here accepts a raw FCM payload for demonstration purposes.
String constructFCMPayload(
    String token, String from, String receiver, String message) {
  return jsonEncode({
    "to": token,
    "data": {"sender": from, "receiver": receiver},
    "notification": {"title": "Message from $from", "body": message}
  });
}

Future<void> sendPushMessage(
    String token, String from, String receiver, String message) async {
  print("token2 $token");
  if (token == null) {
    print('Unable to send FCM message, no token exists.');
    return;
  }

  try {
    await http
        .post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAAj4UOGMU:APA91bFZuuHQZ-kqsEFPdlBYJaKjTsi5xUWb24WB94Cg9Gpfek3A2yTyC1ZacazFl2a8d1yiEcyRd88oTPiuFXbYFGgiJSuOCW3sF8-EIyIKj5i_R8xVWVVH_rrohIy9k5EA9VEeMNqV'
      },
      body: constructFCMPayload(token, from, receiver, message),
    )
        .then((value) {
      print("fcm stuff");
      print(value.body.toString());
    }).catchError((e) {
      print(e);
    });
    print('FCM request for device sent!');
  } catch (e) {
    print(e);
  }
}
