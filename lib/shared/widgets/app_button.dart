import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;
  final double radius;
  final double height;
  final double? elevation;
  final Widget? suffix;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? style;
  final bool enabled;
  final bool loading;
  final TextAlign? textAlign;
  final EdgeInsets? margin;
  final double? width;

  const AppButton({
    Key? key,
    this.onPressed,
    this.margin,
    this.text,
    this.radius = 8,
    this.height = 50,
    this.elevation,
    this.suffix,
    this.borderColor,
    this.backgroundColor,
    this.textColor,
    this.style,
    this.enabled = true,
    this.loading = false,
    this.textAlign,
    this.width,
  }) : super(key: key);

  factory AppButton.icon({
    required VoidCallback? onPressed,
    required Widget suffix,
    String? text,
    double? radius,
    double? height,
    Color? backgroundColor = AppColors.grey400,
    Color? textColor = Colors.black,
    TextStyle? style,
  }) {
    return AppButton(
      suffix: suffix,
      onPressed: onPressed,
      radius: radius ?? 8,
      height: height ?? 56,
      text: text,
      backgroundColor: backgroundColor,
      textColor: textColor,
      style: style,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height.h,
      child: ElevatedButton(
        onPressed: loading || !enabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[500],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: borderColor == null
                ? BorderSide.none
                : BorderSide(
                    color: borderColor!,
                  ),
          ),
          elevation: elevation,
        ),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : suffix != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      suffix!,
                      AppSpacing.h16(),
                      Text(
                        text!,
                        style: style ??
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                  fontSize: 14,
                                ),
                      ),
                    ],
                  )
                : Text(
                    text!,
                    textAlign: textAlign,
                    style: style ??
                        Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: textColor ?? Colors.white,
                              fontSize: 14,
                            ),
                  ),
      ),
    );
  }
} 