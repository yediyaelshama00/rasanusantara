import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionTitle({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(action!, style: const TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.w800)),
          ),
      ],
    );
  }
}
