import './constants.dart';
import './size_config.dart';
import 'package:flutter/material.dart';
import '../../style/colors.dart';

import 'components/body.dart';
import '../../services/agora.dart';

class DialScreen extends StatefulWidget {
  static const routeName = '/dial';

  @override
  State<DialScreen> createState() => _DialScreenState();
}

class _DialScreenState extends State<DialScreen> {
  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> chatScreenMap =
        ModalRoute.of(context).settings.arguments;

    final callerName = chatScreenMap["name"];
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: AppColor().mainBackColor,
      body: Body(callerName, chatScreenMap["chatRoomId"],
          chatScreenMap["callEndMessage"], chatScreenMap["callEndFunction"]),
    );
  }
}
