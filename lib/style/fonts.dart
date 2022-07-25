import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../style/colors.dart';

class AppTextStyle {
  final TextStyle headingStyle = GoogleFonts.alegreya(
      textStyle: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: AppColor().textColor));
  final TextStyle headingStyleWhite = GoogleFonts.alegreya(
      textStyle: TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ));
  final TextStyle headingStyleWhiteSmall = GoogleFonts.alegreya(
      textStyle: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ));
  final TextStyle bodyTextFinal = GoogleFonts.alegreya(
      textStyle: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ));

  final TextStyle tileHeadingStyle = GoogleFonts.alegreyaSans(
      textStyle: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white));
  final TextStyle tileHeadingStyleWhite = GoogleFonts.alegreyaSans(
      textStyle: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white));

  final TextStyle bodyStyle = GoogleFonts.alegreyaSans(
      textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: AppColor().textColor));

  final TextStyle bodyStyleBold = GoogleFonts.alegreyaSans(
      textStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColor().textColor));

  final TextStyle bodyStyleWhite = GoogleFonts.alegreyaSans(
      textStyle: TextStyle(
          fontSize: 17, fontWeight: FontWeight.normal, color: Colors.white));

  final TextStyle termsStyle = GoogleFonts.alegreyaSans(
      textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: AppColor().textColor));

  final TextStyle httpbodyStyle = GoogleFonts.alegreyaSans(
      textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: AppColor().httpLinkColor));

  final TextStyle chatSenderStyle = GoogleFonts.alegreyaSans(
      textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColor().textColor));

  final TextStyle subtitleMsgStyle = GoogleFonts.alegreyaSans(
      textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: AppColor().textColor));

  final TextStyle subtitleStyle = GoogleFonts.alegreyaSans(
      textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.black.withOpacity(0.75)));

  final TextStyle subtitleStyleWhite = GoogleFonts.alegreyaSans(
      textStyle: TextStyle(
          fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white));

  final TextStyle psychoListHeadStyle = GoogleFonts.alegreyaSans(
      textStyle: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1C61)));

  final TextStyle psychoListbodyStyle = GoogleFonts.alegreyaSans(
      textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: Color(0xFF253334)));

  final TextStyle lastMessageStyle = GoogleFonts.alegreyaSans(
      textStyle: TextStyle(
          fontSize: 13, fontWeight: FontWeight.normal, color: Colors.white));
}
