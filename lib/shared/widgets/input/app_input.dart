import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';

class AppInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? labelText;
  final String? hintText;
  final bool? obscureText;
  final bool readOnly;
  final bool autoValidate;
  final bool isPassword;
  final int? maxLength;
  final VoidCallback? onTap;
  final Color color;
  final double height;
  final Widget? suffix;
  final int? maxLines;
  final Color inputColor;
  final BorderRadius? customBorderRadius;
  final double? customHeight;
  final InputBorder? customBorder;
  final Color? customInputColor;
  final FocusNode? focusNode;

  const AppInput({
    super.key,
    this.controller,
    this.initialValue,
    this.validator,
    this.labelText,
    this.hintText,
    this.obscureText,
    this.onChanged,
    this.onFieldSubmitted,
    this.isPassword = false,
    this.inputFormatters,
    this.keyboardType,
    this.maxLength,
    this.readOnly = false,
    this.onTap,
    this.color = AppColors.grey100,
    this.height = 56,
    this.suffix,
    this.textInputAction,
    this.autoValidate = false,
    this.maxLines,
    this.inputColor = Colors.white,
    this.customBorderRadius,
    this.customHeight,
    this.customBorder,
    this.customInputColor,
    this.focusNode,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  bool obscuring = false;
  final formFieldKey = GlobalKey<FormFieldState>();
  late FocusNode focusNode;

  @override
  void initState() {
    focusNode = widget.focusNode ?? FocusNode();
    obscuring = widget.obscureText ?? false;
    controller = widget.controller ?? TextEditingController();
    if (widget.initialValue != null) {
      controller.text = widget.initialValue!;
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void toggleObscuring() {
    setState(() {
      obscuring = !obscuring;
    });
  }

  late TextEditingController controller;
  String? errorText;
  bool hasError = false;
  int numberOfLines = 1;

  int? get getMaxLines => widget.maxLines != null
      ? (numberOfLines > widget.maxLines! ? widget.maxLines : numberOfLines)
      : numberOfLines;

  double? get getHeight => (numberOfLines <= 1 && !hasError)
      ? widget.customHeight ?? widget.height.h
      : (numberOfLines <= 1 && hasError)
          ? 80
          : null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: getHeight,
          child: TextFormField(
            key: formFieldKey,
            focusNode: focusNode,
            maxLines: getMaxLines,
            controller: controller,
            inputFormatters: widget.inputFormatters,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            maxLength: widget.maxLength,
            onTap: widget.onTap,
            readOnly: widget.readOnly,
            obscureText: widget.obscureText != null ? obscuring : false,
            onFieldSubmitted: (value) {
              _calculateLinesOnSubmitted();
              widget.onFieldSubmitted?.call(value);
            },
            onTapOutside: (event) {
              FocusScope.of(context).unfocus();
            },
            validator: (val) {
              final response = widget.validator?.call(val);
              errorText = response;
              setState(() {});
              return response;
            },
            onChanged: (val) {
              if (widget.autoValidate) {
                formFieldKey.currentState!.validate();
              }
              widget.onChanged?.call(val);
              _calculateLineOnChanged(val, context);
            },
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: 14.spMin,
                ),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: widget.customInputColor ?? widget.inputColor,
              labelText: widget.labelText,
              hintText: widget.hintText,
              errorStyle: const TextStyle(fontSize: 0),
              counterText: '',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              counterStyle: const TextStyle(fontSize: 0),
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey300,
                    fontSize: 14.spMin,
                  ),
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey300,
                    fontSize: 14.spMin,
                  ),
              suffixIcon: widget.suffix ??
                  (widget.obscureText != null
                      ? IconButton(
                          onPressed: toggleObscuring,
                          icon: Icon(
                            obscuring
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.grey800,
                          ),
                        )
                      : null),
              border: widget.customBorder ??
                  OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: AppColors.grey200,
                    ),
                    borderRadius: widget.customBorderRadius ??
                        const BorderRadius.all(Radius.circular(8)),
                  ),
              enabledBorder: widget.customBorder ??
                  OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: AppColors.grey200,
                    ),
                    borderRadius: widget.customBorderRadius ??
                        const BorderRadius.all(Radius.circular(8)),
                  ),
            ),
          ),
        ),
        if (errorText != null) AppSpacing.v8(),
        if (errorText != null)
          Text(
            errorText!,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: const ColorScheme.light().error),
          )
      ],
    );
  }

  void _calculateLineOnChanged(String val, BuildContext context) {
    if (widget.keyboardType == TextInputType.multiline) {
      final count = val.split('\n').length;
      int lines = (val.length /
              (MediaQuery.of(context).size.width *
                  (numberOfLines == 1 ? 0.079 : 0.088).w))
          .round();
      setState(() {
        numberOfLines = (lines == 0 ? 1 : lines) + (count == 1 ? 0 : count - 1);
      });
    }
  }

  void _calculateLinesOnSubmitted() {
    if (widget.keyboardType == TextInputType.multiline && numberOfLines == 1) {
      numberOfLines += 1;
      controller.text += '\n';
      focusNode.requestFocus();
      setState(() {});
    }
  }
} 