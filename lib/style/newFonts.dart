import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewAppTextStyle {
  final TextStyle psychoListMainHeadingStyle = GoogleFonts.alegreya(
      textStyle: TextStyle(
          fontSize: 27, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)));
  final TextStyle psychoListMainBodyStyle = GoogleFonts.alegreyaSans(
      textStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.normal,
          color: Color(0xFFFFFFFF)));
  final TextStyle psychoIntrobodyStyle = GoogleFonts.alegreyaSans(
      textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: Color(0x1E1C61).withOpacity(0.65)));
}
