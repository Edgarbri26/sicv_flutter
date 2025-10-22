import 'package:flutter/material.dart';
import 'package:sicv_flutter/core/theme/app_colors.dart';

enum TypeButton { primary, secundary}

class ButtonApp extends StatelessWidget {
  final void Function() onPressed;
  final Text title;
  final Icon? icon;
  final TypeButton typeButton;
  const ButtonApp({
    super.key,
    required this.onPressed,
    required this.title,
    this.icon,
    required this.typeButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            typeButton == TypeButton.primary
                ? LinearGradient(
                  colors: [AppColors.primary, AppColors.error],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
                : LinearGradient(
                  colors: [AppColors.secondary, AppColors.secondary],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: icon,
        label: title,
        onPressed: onPressed,
      ),
    );
  }
}
