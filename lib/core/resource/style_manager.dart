import 'package:flutter/material.dart';

import 'font_manager.dart';

TextStyle _getTextStyle(
  double fontSize,
  String fontFamily,
  FontWeight fontWeight,
  Color color,
) {
  return TextStyle(fontSize: fontSize, fontFamily: fontFamily, color: color);
}

//light text style
TextStyle getLight300Style12({
  double fontSize = FontSize.s12,
  FontWeight fontWeight = FontWeightManager.light300,
  required Color color,
}) {
  return _getTextStyle(fontSize, FontConstants.fontFamily, fontWeight, color);
}

//regular  text style
TextStyle getRegular400Style12({
  double fontSize = FontSize.s12,
  FontWeight fontWeight = FontWeightManager.regular400,
  required Color color,
}) {
  return _getTextStyle(fontSize, FontConstants.fontFamily, fontWeight, color);
}

//mediun text style
TextStyle getMedium500Style12({
  double fontSize = FontSize.s12,
  FontWeight fontWeight = FontWeightManager.medium500,
  required Color color,
}) {
  return _getTextStyle(fontSize, FontConstants.fontFamily, fontWeight, color);
}

//semi bold text style
TextStyle getSemiBold600Style12({
  double fontSize = FontSize.s12,
  FontWeight fontWeight = FontWeightManager.semiBold600,
  required Color color,
}) {
  return _getTextStyle(fontSize, FontConstants.fontFamily, fontWeight, color);
}

//bold text style
TextStyle getBold700Style18({
  double fontSize = FontSize.s18,
  FontWeight fontWeight = FontWeightManager.bold700,
  required Color color,
}) {
  return _getTextStyle(fontSize, FontConstants.fontFamily, fontWeight, color);
}
