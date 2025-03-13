// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIconData {
  static const String _basePath = 'assets/svgs/';
  static const String logo = '${_basePath}logo.svg';
  static const String successmark = '${_basePath}successmark.svg';
}

class AppIcons extends StatelessWidget {
  final VoidCallback? onPressed;
  final String icon;
  final double size;
  final Color? color;
  const AppIcons({
    super.key,
    this.onPressed,
    this.color,
    required this.icon,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SvgPicture.asset(
        icon,
        height: size,
        width: size,
        color: color,
      ),
    );
  }
} 