import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';

class AppRichText extends StatelessWidget {
  final String title;
  final String subTitle;
  final TextStyle? titleStyle;
  final TextStyle? subTitleStyle;
  final GestureRecognizer? recognizer;

  const AppRichText({
    super.key,
    required this.title,
    required this.subTitle,
    this.titleStyle,
    this.subTitleStyle,
    this.recognizer,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: title,
        style: titleStyle ?? AppTextStyle.regular14,
        children: [
          TextSpan(
            text: subTitle,
            style: subTitleStyle ?? AppTextStyle.semibold14,
            recognizer: recognizer,
          ),
        ],
      ),
    );
  }
} 