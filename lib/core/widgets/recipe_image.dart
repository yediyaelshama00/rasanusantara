import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class RecipeImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const RecipeImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    Widget image;

    // Coba load sebagai asset
    image = Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _placeholder(),
    );

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: image,
      );
    }

    return image;
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.cream,
      child: const Center(
        child: Icon(Icons.restaurant_rounded, color: AppColors.muted, size: 28),
      ),
    );
  }
}