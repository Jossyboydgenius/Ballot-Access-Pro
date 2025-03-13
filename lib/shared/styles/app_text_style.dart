import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';

abstract class AppTextStyle {
  /// Base text style
  static const TextStyle _baseTextStyle = TextStyle(
    fontFamily: 'Marcellus',
    fontWeight: AppFontWeight.regular,
    color: AppColors.lightBlack,
  );

  ///Marcellus 10
  static TextStyle get regular10 => _baseTextStyle.copyWith(fontSize: 10);

  ///Marcellus medium 10
  static TextStyle get medium10 =>
      regular10.copyWith(fontWeight: AppFontWeight.medium);

  ///Marcellus 12
  static TextStyle get regular12 => _baseTextStyle.copyWith(fontSize: 12);

  ///Marcellus medium 12
  static TextStyle get medium12 =>
      regular12.copyWith(fontWeight: AppFontWeight.medium);

  ///Marcellus semibold 12
  static TextStyle get semibold12 =>
      regular12.copyWith(fontWeight: AppFontWeight.semiBold);

  ///Marcellus medium 14
  static TextStyle get medium14 => regular10.copyWith(
        fontWeight: AppFontWeight.medium,
        fontSize: 14.spMin,
      );

  ///Marcellus medium 16
  static TextStyle get medium16 => regular10.copyWith(
        fontWeight: AppFontWeight.medium,
        fontSize: 16.spMin,
      );

  ///Marcellus 14
  static TextStyle get regular14 => _baseTextStyle.copyWith(fontSize: 14);

  ///Marcellus light 14
  static TextStyle get light14 =>
      regular14.copyWith(fontWeight: AppFontWeight.light);

  ///Marcellus semibold 14
  static TextStyle get semibold14 =>
      regular14.copyWith(fontWeight: AppFontWeight.semiBold);

  ///Marcellus bold 14
  static TextStyle get bold14 =>
      regular14.copyWith(fontWeight: AppFontWeight.bold);

  ///Marcellus 15
  static TextStyle get regular15 => _baseTextStyle.copyWith(fontSize: 15);

  ///Marcellus medium 15
  static TextStyle get medium15 =>
      regular15.copyWith(fontWeight: AppFontWeight.medium);

  ///Marcellus semibold 15
  static TextStyle get semibold15 =>
      regular15.copyWith(fontWeight: AppFontWeight.semiBold);

  ///Marcellus 16
  static TextStyle get regular16 => _baseTextStyle.copyWith(fontSize: 16);

  ///Marcellus light 16
  static TextStyle get light16 =>
      regular16.copyWith(fontWeight: AppFontWeight.light);

  ///Marcellus semibold 16
  static TextStyle get semibold16 =>
      regular16.copyWith(fontWeight: AppFontWeight.semiBold);

  ///Marcellus bold 16
  static TextStyle get bold16 =>
      regular16.copyWith(fontWeight: AppFontWeight.bold);

  ///Marcellus 18
  static TextStyle get regular18 => _baseTextStyle.copyWith(fontSize: 18);

  ///Marcellus semibold 18
  static TextStyle get semibold18 =>
      regular18.copyWith(fontWeight: AppFontWeight.semiBold);

  ///Marcellus bold 18
  static TextStyle get bold18 =>
      regular18.copyWith(fontWeight: AppFontWeight.bold);

  ///Marcellus 20
  static TextStyle get regular20 => _baseTextStyle.copyWith(fontSize: 20);

  ///Marcellus medium 20
  static TextStyle get medium20 =>
      regular20.copyWith(fontWeight: AppFontWeight.medium);

  ///Marcellus semibold 20
  static TextStyle get semibold20 =>
      regular20.copyWith(fontWeight: AppFontWeight.semiBold);

  ///Marcellus bold 20
  static TextStyle get bold20 =>
      regular20.copyWith(fontWeight: AppFontWeight.bold);

  ///Marcellus semibold 24
  static TextStyle get semibold24 => regular16.copyWith(
        fontWeight: AppFontWeight.semiBold,
        fontSize: 24.spMin,
      );

  ///Marcellus bold 24
  static TextStyle get bold24 => _baseTextStyle.copyWith(
        fontWeight: AppFontWeight.bold,
        fontSize: 24.spMin,
      );

  ///Marcellus regular 24
  static TextStyle get regular24 => _baseTextStyle.copyWith(
        fontSize: 24.spMin,
        fontWeight: AppFontWeight.regular,
      );

  ///Marcellus bold 30
  static TextStyle get bold30 => _baseTextStyle.copyWith(
        fontSize: 30.spMin,
        fontWeight: AppFontWeight.bold,
      );
}

abstract class AppFontWeight {
  /// FontWeight value of `w900`
  static const FontWeight black = FontWeight.w900;

  /// FontWeight value of `w800`
  static const FontWeight extraBold = FontWeight.w800;

  /// FontWeight value of `w700`
  static const FontWeight bold = FontWeight.w700;

  /// FontWeight value of `w600`
  static const FontWeight semiBold = FontWeight.w600;

  /// FontWeight value of `w500`
  static const FontWeight medium = FontWeight.w500;

  /// FontWeight value of `w400`
  static const FontWeight regular = FontWeight.w400;

  /// FontWeight value of `w300`
  static const FontWeight light = FontWeight.w300;

  /// FontWeight value of `w200`
  static const FontWeight extraLight = FontWeight.w200;

  /// FontWeight value of `w100`
  static const FontWeight thin = FontWeight.w100;
} 