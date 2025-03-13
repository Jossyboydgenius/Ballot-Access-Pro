import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';

class PinCodeField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final int length;
  final double fieldWidth;
  final double fieldHeight;
  final TextStyle? textStyle;

  const PinCodeField({
    super.key,
    required this.controller,
    this.onChanged,
    this.length = 6,
    this.fieldWidth = 45,
    this.fieldHeight = 45,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        length,
        (index) => SizedBox(
          width: fieldWidth.w,
          height: fieldHeight.h,
          child: TextFormField(
            controller: TextEditingController(
              text: controller.text.length > index ? controller.text[index] : '',
            ),
            onChanged: (value) {
              if (value.length == 1) {
                if (index < length - 1) {
                  FocusScope.of(context).nextFocus();
                }
                String newText = controller.text;
                if (index >= newText.length) {
                  newText += value;
                } else {
                  newText = newText.substring(0, index) + value + newText.substring(index + 1);
                }
                controller.text = newText;
                onChanged?.call(newText);
              } else if (value.isEmpty && index > 0) {
                FocusScope.of(context).previousFocus();
                String newText = controller.text;
                if (newText.isNotEmpty) {
                  newText = newText.substring(0, newText.length - 1);
                  controller.text = newText;
                  onChanged?.call(newText);
                }
              }
            },
            textAlign: TextAlign.center,
            style: textStyle ?? TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 