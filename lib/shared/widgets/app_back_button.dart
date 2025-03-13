import 'package:flutter/material.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';

class AppBackButton extends StatelessWidget {
  final bool isBorder;

  const AppBackButton({
    super.key,
    this.isBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          border: isBorder ? Border.all(color: AppColors.grey200) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          size: 20,
        ),
      ),
    );
  }
} 