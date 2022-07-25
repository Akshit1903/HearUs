import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import './size_config.dart';
import '../../../style/colors.dart';

class DialButton extends StatelessWidget {
  final String iconSrc, text;
  final VoidCallback press;
  bool isSelected;
  DialButton({this.iconSrc, this.text, this.press, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      child: FlatButton(
        padding: EdgeInsets.symmetric(
          vertical: 20,
        ),
        onPressed: press,
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: isSelected
                  ? AppColor().buttonColor
                  : AppColor().mainBackColor,
              child: SvgPicture.asset(
                iconSrc,
                color: Colors.white,
                height: 36,
              ),
            ),
            //VerticalSpacing(of: 5),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            )
          ],
        ),
      ),
    );
  }
}
