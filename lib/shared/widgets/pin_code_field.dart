import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';

class PinCodeField extends StatelessWidget {
  final int length;
  final Function(String) onCompleted;
  final Function(String) onChanged;
  final double boxWidth;
  final double boxHeight;
  final double spacing;
  final Color boxColor;
  final Color boxBorderColor;
  final Color textColor;

  const PinCodeField({
    super.key,
    required this.length,
    required this.onCompleted,
    required this.onChanged,
    this.boxWidth = 50,
    this.boxHeight = 55,
    this.spacing = 5,
    this.boxColor = Colors.white,
    this.boxBorderColor = AppColors.grey200,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          length,
          (index) => SizedBox(
            width: boxWidth.w,
            height: boxHeight.h,
            child: TextFormField(
              onChanged: (value) {
                if (value.length == 1) {
                  if (index < length - 1) {
                    FocusScope.of(context).nextFocus();
                  }
                  String currentPin = '';
                  for (var i = 0; i < length; i++) {
                    currentPin += (i == index) ? value : '';
                  }
                  onChanged(currentPin);
                  if (currentPin.length == length) {
                    onCompleted(currentPin);
                  }
                } else if (value.isEmpty && index > 0) {
                  FocusScope.of(context).previousFocus();
                }
              },
              style: TextStyle(
                color: textColor,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: boxColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: boxBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: boxBorderColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 