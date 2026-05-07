import 'package:flutter/material.dart';
import '../../data/models/recipe_model.dart';
import '../constants/app_colors.dart';
import 'recipe_image.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool compact;
  final bool favorite;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
    this.onFavorite,
    this.compact = false,
    this.favorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final imgSize = compact ? 78.0 : 90.0;
    final imgRadius = compact ? 16.0 : 20.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Gambar ────────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(imgRadius),
              child: RecipeImage(
                imagePath: recipe.imagePath,
                width: imgSize,
                height: imgSize,
                fit: BoxFit.cover,
                borderRadius: imgRadius,
              ),
            ),
            const SizedBox(width: 14),

            // ── Info ──────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: AppColors.terracotta),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${recipe.province} • ${recipe.island}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _Pill(
                        text: recipe.difficulty,
                        icon: Icons.local_fire_department_outlined,
                      ),
                      _Pill(
                        text: '${recipe.cookTimeMinutes} mnt',
                        icon: Icons.timer_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Trailing ──────────────────────────────────────────────
            const SizedBox(width: 6),
            if (onFavorite != null)
              _FavoriteButton(active: favorite, onTap: onFavorite!)
            else
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.spiceBrown, size: 22),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final IconData icon;
  const _Pill({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.spiceBrown.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.spiceBrown),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.spiceBrown,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _FavoriteButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: active
              ? AppColors.terracotta.withOpacity(0.12)
              : AppColors.cream,
          shape: BoxShape.circle,
          border: Border.all(
            color: active
                ? AppColors.terracotta.withOpacity(0.50)
                : AppColors.spiceBrown.withOpacity(0.22),
            width: 1.6,
          ),
        ),
        child: Icon(
          active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: active ? AppColors.terracotta : AppColors.muted,
          size: 18,
        ),
      ),
    );
  }
}